cmake_minimum_required(VERSION 2.8.3)

#
# Parses arguments or options
#
# From: http://www.cmake.org/Wiki/CMakeMacroParseArguments
#
# For each item in options, PARSE_ARGUMENTS will create a variable
# with that name, prefixed with prefix_. So, for example, if prefix is
# MY_MACRO and options is OPTION1;OPTION2, then PARSE_ARGUMENTS will
# create the variables MY_MACRO_OPTION1 and MY_MACRO_OPTION2. These
# variables will be set to true if the option exists in the command
# line or false otherwise.
#
# For each item in arg_names, PARSE_ARGUMENTS will create a variable
# with that name, prefixed with prefix_. Each variable will be filled
# with the arguments that occur after the given arg_name is encountered
# up to the next arg_name or the end of the arguments. All options are
# removed from these lists. PARSE_ARGUMENTS also creates a
# prefix_DEFAULT_ARGS variable containing the list of all arguments up
# to the first arg_name encountered.
#
MACRO(ORO_PARSE_ARGUMENTS prefix arg_names option_names)
  SET(DEFAULT_ARGS)
  FOREACH(arg_name ${arg_names})  
    SET(${prefix}_${arg_name})
  ENDFOREACH(arg_name)
  FOREACH(option ${option_names})
    SET(${prefix}_${option} FALSE)
  ENDFOREACH(option)

  SET(current_arg_name DEFAULT_ARGS)
  SET(current_arg_list)
  FOREACH(arg ${ARGN})
    SET(larg_names ${arg_names})
    LIST(FIND larg_names "${arg}" is_arg_name)     
    IF (is_arg_name GREATER -1)
      SET(${prefix}_${current_arg_name} ${current_arg_list})
      SET(current_arg_name ${arg})
      SET(current_arg_list)
    ELSE (is_arg_name GREATER -1)
      SET(loption_names ${option_names})
      LIST(FIND loption_names "${arg}" is_option)            
      IF (is_option GREATER -1)
         SET(${prefix}_${arg} TRUE)
      ELSE (is_option GREATER -1)
         SET(current_arg_list ${current_arg_list} ${arg})
      ENDIF (is_option GREATER -1)
    ENDIF (is_arg_name GREATER -1)
  ENDFOREACH(arg)
  SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO(ORO_PARSE_ARGUMENTS)

#
# Parses an Autoproj or rosbuild manifest.xml file and stores the dependencies in RESULT.
# Relies on xpath. If no manifest is found, returns an empty RESULT.
#
# Usage: orocos_get_manifest_deps DEPS)
#
function( orocos_get_manifest_deps RESULT)
  if ( NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/manifest.xml )
    message(STATUS "[orocos_get_manifest_deps] Note: this package has no manifest.xml file. No dependencies can be auto-configured.")
    return()
  endif ( NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/manifest.xml )

  find_program(XPATH_EXE xpath )
  if (NOT XPATH_EXE)
    if (ORO_USE_ROSBUILD OR ORO_USE_CATKIN)
      message(SEND_ERROR "[orocos_get_manifest_deps] xpath not found. Can't read dependencies in manifest.xml or package.xml file.")
    else ()
      message(WARNING "[orocos_get_manifest_deps] xpath not found. Can't read dependencies in manifest.xml file.")
    endif ()
  else(NOT XPATH_EXE)
    execute_process(COMMAND ${XPATH_EXE} ERROR_VARIABLE XPATH_USAGE)
    IF (NOT XPATH_USAGE MATCHES ".*(-e query).*")
      execute_process(COMMAND ${XPATH_EXE} ${CMAKE_CURRENT_SOURCE_DIR}/manifest.xml "package/depend/@package" RESULT_VARIABLE RES OUTPUT_VARIABLE DEPS)
      SET(REGEX_STR " package=\"([^\"]+)\"")
    ELSE (NOT XPATH_USAGE MATCHES ".*(-e query).*")
      execute_process(COMMAND ${XPATH_EXE} -q -e "package/depend/@package" ${CMAKE_CURRENT_SOURCE_DIR}/manifest.xml RESULT_VARIABLE RES OUTPUT_VARIABLE DEPS)
      SET(REGEX_STR " package=\"([^\"]+)\"\n")
    ENDIF (NOT XPATH_USAGE MATCHES ".*(-e query).*")
    if (NOT RES EQUAL 0)
      message(SEND_ERROR "Error: xpath found but returned non-zero:${DEPS}")
    endif (NOT RES EQUAL 0)

    string(REGEX REPLACE "${REGEX_STR}" "\\1;" RR_RESULT "${DEPS}")

    #message("Deps are: '${DEPS}'")
    set(${RESULT} ${RR_RESULT} PARENT_SCOPE)
    #message("Dependencies are: '${${RESULT}}'")
  endif (NOT XPATH_EXE)

endfunction( orocos_get_manifest_deps RESULT)

#
# Find a package, pick up its compile and link flags. It does this by locating
# and reading the .pc file generated by that package. In case no such .pc file
# exists (or is not found), it is assumed that no flags are necessary.
#
# This macro is called by orocos_use_package()
#
# It sets these variables for each package:
#   ${PACKAGE}_LIBRARIES        The fully resolved link libraries for this package.
#   ${PACKAGE}_INCLUDE_DIRS     The include directories for this package.
#   ${PACKAGE}_LIBRARY_DIRS     The library directories for this package.
#   ${PACKAGE}_CFLAGS_OTHER     The compile flags other than -I for this package.
#   ${PACKAGE}_LDFLAGS_OTHER    The linker flags other than -L and -l for thfully resolved link libraries for this package.
#   ${PACKAGE}_<LIB>_LIBRARY    Each fully resolved link library <LIB> in the above list.
# 
# Usage: orocos_find_package( pkg-name [OROCOS_ONLY] [REQUIRED] [VERBOSE]")
#
macro( orocos_find_package PACKAGE )

  oro_parse_arguments(ORO_FIND
    ""
    "OROCOS_ONLY;REQUIRED;VERBOSE"
    ${ARGN}
    )

  if ( "${PACKAGE}" STREQUAL "rtt")
  else()
    # Try to use rosbuild to find PACKAGE
    if(ORO_USE_ROSBUILD)
      # use rospack to find package directories of *all* dependencies.
      # We need these because a .pc file may depend on another .pc file in another package.
      # This package + the packages this package depends on:
      rosbuild_find_ros_package(${PACKAGE})

      if(DEFINED ${PACKAGE}_PACKAGE_PATH AND EXISTS "${${PACKAGE}_PACKAGE_PATH}/manifest.xml")
        # call orocos_use_package recursively for dependees
        rosbuild_invoke_rospack(${PACKAGE} ${PACKAGE} DEPENDS1 depends1)
        if(${PACKAGE}_DEPENDS1)
          string(REPLACE "\n" ";" ${PACKAGE}_DEPENDS1 ${${PACKAGE}_DEPENDS1})
          foreach(dependee ${${PACKAGE}_DEPENDS1})
            # Avoid using a package that has already been found
            if(NOT ORO_${dependee}_FOUND)
              orocos_find_package(${dependee} ${ARGN})
            endif()
          endforeach()
        endif()

        # add PACKAGE_PATH/lib/pkgconfig to the PKG_CONFIG_PATH
        set(ENV{PKG_CONFIG_PATH} "${${PACKAGE}_PACKAGE_PATH}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
      endif()
    endif()

    # Now we are ready to get the flags from the .pc files:
    set(MODULE_NAMES ${PACKAGE}-${OROCOS_TARGET})
    if(NOT ORO_FIND_OROCOS_ONLY)
      list(APPEND MODULE_NAMES ${PACKAGE})
    endif()

    # Disable caching in FindPkgConfig.cmake as otherwise changes in
    # Orocos .pc files are not detected before the cmake cache is deleted
    set(${PACKAGE}_COMP_${OROCOS_TARGET}_FOUND FALSE)

    pkg_search_module(${PACKAGE}_COMP_${OROCOS_TARGET} ${MODULE_NAMES})
    if (${PACKAGE}_COMP_${OROCOS_TARGET}_FOUND)
      # Add DESTDIR to INCLUDE_DIRS and set CMAKE_FIND_ROOT_PATH if the DESTDIR environment variable is defined
      if(DEFINED ENV{DESTDIR})
        set(${PACKAGE}_COMP_${OROCOS_TARGET}_INCLUDE_DIRS_WITHOUT_DESTDIR ${${PACKAGE}_COMP_${OROCOS_TARGET}_INCLUDE_DIRS})
        set(${PACKAGE}_COMP_${OROCOS_TARGET}_INCLUDE_DIRS)
        foreach(dir ${${PACKAGE}_COMP_${OROCOS_TARGET}_INCLUDE_DIRS_WITHOUT_DESTDIR})
          list(APPEND ${PACKAGE}_COMP_${OROCOS_TARGET}_INCLUDE_DIRS "$ENV{DESTDIR}${dir};${dir}")
        endforeach()

        set(CMAKE_FIND_ROOT_PATH "$ENV{DESTDIR}")
      endif()

      # Use find_libraries to find each library:
      unset(${PACKAGE}_LIBRARIES)
      foreach(COMP_LIB ${${PACKAGE}_COMP_${OROCOS_TARGET}_LIBRARIES})
        # Two options: COMP_LIB is an absolute path-to-lib (must start with ':') or just a libname:
        if ( ${COMP_LIB} MATCHES "^:(.+)" )
          if (EXISTS "${CMAKE_MATCH_1}" )
            # absolute path (shared lib):
            set( ${PACKAGE}_${COMP_LIB}_LIBRARY "${CMAKE_MATCH_1}" )
          endif()
        elseif (EXISTS "${COMP_LIB}" )
          # absolute path (static lib):
          set( ${PACKAGE}_${COMP_LIB}_LIBRARY "${COMP_LIB}" )
        else()
          # libname:
          find_library(${PACKAGE}_${COMP_LIB}_LIBRARY NAMES ${COMP_LIB} HINTS ${${PACKAGE}_COMP_${OROCOS_TARGET}_LIBRARY_DIRS})
        endif()

        if(NOT ${PACKAGE}_${COMP_LIB}_LIBRARY)
          message(SEND_ERROR "In package >>>${PACKAGE}<<< : could not find library ${COMP_LIB} in directory ${${PACKAGE}_COMP_${OROCOS_TARGET}_LIBRARY_DIRS}, although its .pc file says it should be there.\n\n Try to do 'make clean; rm -rf lib' and then 'make' in the package >>>${PACKAGE}<<<.\n\n")
        endif()

        list(APPEND ${PACKAGE}_LIBRARIES "${${PACKAGE}_${COMP_LIB}_LIBRARY}")
      endforeach(COMP_LIB ${${PACKAGE}_COMP_${OROCOS_TARGET}_LIBRARIES})

      # Add some output variables (note these are accessible outside of this scope since this is a macro)
      # We don't want to cache these
      set(ORO_${PACKAGE}_FOUND "${${PACKAGE}_COMP_${OROCOS_TARGET}_FOUND}")
      set(${PACKAGE}_FOUND ${ORO_${PACKAGE}_FOUND})
      set(${PACKAGE}_INCLUDE_DIRS "${${PACKAGE}_COMP_${OROCOS_TARGET}_INCLUDE_DIRS}")
      set(${PACKAGE}_LIBRARY_DIRS "${${PACKAGE}_COMP_${OROCOS_TARGET}_LIBRARY_DIRS}")
      set(${PACKAGE}_LIBRARIES "${${PACKAGE}_LIBRARIES}")
      # The flags are space separated, so no need to quote here:
      set(${PACKAGE}_CFLAGS_OTHER ${${PACKAGE}_COMP_${OROCOS_TARGET}_CFLAGS_OTHER})
      set(${PACKAGE}_LDFLAGS_OTHER ${${PACKAGE}_COMP_${OROCOS_TARGET}_LDFLAGS_OTHER})

    else()
      if(ORO_FIND_REQUIRED)
        message(FATAL_ERROR "[UseOrocos] Could not find package '${PACKAGE}'.")
      else()
        if(ORO_FIND_VERBOSE)
          message(WARNING "[UseOrocos] Could not find package '${PACKAGE}'. It does not provide a .pc file for exporting its build/link flags (or one of it 'Requires' dependencies was not found).")
        endif()
      endif()
    endif()
  endif()
endmacro( orocos_find_package PACKAGE )

#
# Find a package, pick up its include dirs and link with its libraries.
# It does this by locating and reading the .pc file generated by that package.
# In case no such .pc file exists (or is not found), it is assumed that no
# flags are necessary.
#
# This macro is called for you by UseOrocos-RTT.cmake for each dependency
# listed in your rosbuild or Autoproj manifest.xml file. 
#
# By default, this will add linker flags from all the dependencies to all
# targets in this scope unless OROCOS_NO_AUTO_LINKING is set to True.
# 
# Internally it calls orocos_find_package(), which exports serveral variables
# containing build flags exported by dependencies. See the
# orocos_find_package() documentation for more details.
#   
# It will also aggregate the following variables for all packages found in this
# scope:
#   USE_OROCOS_PACKAGES
#   USE_OROCOS_LIBRARIES
#   USE_OROCOS_INCLUDE_DIRS
#   USE_OROCOS_LIBRARY_DIRS
#   USE_OROCOS_CFLAGS_OTHER
#   USE_OROCOS_LDFLAGS_OTHER
#  
#   USE_OROCOS_COMPILE_FLAGS    All exported compile flags from packages within the current scope.
#   USE_OROCOS_LINK_FLAGS       All exported link flags from packages within the current scope.
#
# Usage: orocos_use_package( pkg-name [OROCOS_ONLY] [REQUIRED] [VERBOSE]")
#
macro( orocos_use_package PACKAGE )

  oro_parse_arguments(ORO_USE
    ""
    "OROCOS_ONLY;REQUIRED;VERBOSE"
    ${ARGN}
    )

  # Check a flag so we don't over-link
  if(NOT ${PACKAGE}_${OROCOS_TARGET}_USED)

    # Check if ${PACKAGE}_OROCOS_PACKAGE is defined in this workspace
    if((${PACKAGE}_OROCOS_PACKAGE AND NOT ORO_USE_OROCOS_ONLY) OR ${PACKAGE}-${OROCOS_TARGET}_OROCOS_PACKAGE)
      message(STATUS "[UseOrocos] Found orocos package '${PACKAGE}' in the same workspace.")

      # The package has been generated in the same workspace. Just use the exported targets and include directories.
      set(ORO_${PACKAGE}_FOUND True)
      set(${PACKAGE}_FOUND True)
      set(${PACKAGE}_INCLUDE_DIRS ${${PACKAGE}_EXPORTED_OROCOS_INCLUDE_DIRS} ${${PACKAGE}-${OROCOS_TARGET}_EXPORTED_OROCOS_INCLUDE_DIRS})
      set(${PACKAGE}_LIBRARY_DIRS ${${PACKAGE}_EXPORTED_OROCOS_LIBRARY_DIRS} ${${PACKAGE}-${OROCOS_TARGET}_EXPORTED_OROCOS_LIBRARY_DIRS})
      set(${PACKAGE}_LIBRARIES ${${PACKAGE}_EXPORTED_OROCOS_LIBRARIES} ${${PACKAGE}-${OROCOS_TARGET}_EXPORTED_OROCOS_LIBRARIES})

      # Use add_dependencies(target ${USE_OROCOS_EXPORTED_TARGETS}) to make sure that a target is built AFTER
      # all targets created by other packages that have been orocos_use_package'd in the current scope.
      list(APPEND USE_OROCOS_EXPORTED_TARGETS ${${PACKAGE}_EXPORTED_OROCOS_TARGETS} ${${PACKAGE}-${OROCOS_TARGET}_EXPORTED_OROCOS_TARGETS})

    else()
      # Get the package and dependency build flags
      orocos_find_package(${PACKAGE} ${ARGN})

      if(ORO_${PACKAGE}_FOUND)
        message(STATUS "[UseOrocos] Found orocos package '${PACKAGE}'.")
      elseif(${PACKAGE}_FOUND AND NOT ORO_USE_OROCOS_ONLY)
        message(STATUS "[UseOrocos] Found non-orocos package '${PACKAGE}'.")
      endif()
    endif()

    # Make sure orocos found it, instead of someone else
    if(ORO_${PACKAGE}_FOUND OR (${PACKAGE}_FOUND AND NOT ORO_USE_OROCOS_ONLY))

      if("$ENV{VERBOSE}" OR ${ORO_USE_VERBOSE})
        message(STATUS "[UseOrocos] Package '${PACKAGE}' exports the following variables to USE_OROCOS:")
        message(STATUS "[UseOrocos]   ${PACKAGE}_FOUND: ${${PACKAGE}_FOUND}")
        message(STATUS "[UseOrocos]   ${PACKAGE}_INCLUDE_DIRS: ${${PACKAGE}_INCLUDE_DIRS}")
        message(STATUS "[UseOrocos]   ${PACKAGE}_LIBRARY_DIRS: ${${PACKAGE}_LIBRARY_DIRS}")
        message(STATUS "[UseOrocos]   ${PACKAGE}_LIBRARIES: ${${PACKAGE}_LIBRARIES}")
      endif()

      # Include the aggregated include directories
      include_directories(${${PACKAGE}_INCLUDE_DIRS})

      # Set a flag so we don't over-link (Don't cache this, it should remain per project)
      set(${PACKAGE}_${OROCOS_TARGET}_USED true)

      # Store aggregated variables
      list(APPEND USE_OROCOS_PACKAGES "${PACKAGE}")
      list(APPEND USE_OROCOS_INCLUDE_DIRS "${${PACKAGE}_INCLUDE_DIRS}")
      list(APPEND USE_OROCOS_LIBRARIES "${${PACKAGE}_LIBRARIES}")
      list(APPEND USE_OROCOS_LIBRARY_DIRS "${${PACKAGE}_LIBRARY_DIRS}")
      list(APPEND USE_OROCOS_CFLAGS_OTHER "${${PACKAGE}_CFLAGS_OTHER}")
      list(APPEND USE_OROCOS_LDFLAGS_OTHER "${${PACKAGE}_LDFLAGS_OTHER}")

      # Remove duplicates from aggregated variables
      if(DEFINED USE_OROCOS_INCLUDE_DIRS)
        list(REMOVE_DUPLICATES USE_OROCOS_INCLUDE_DIRS)
      endif()
      if(DEFINED USE_OROCOS_LIBRARIES)
        list(REMOVE_DUPLICATES USE_OROCOS_LIBRARIES)
      endif()
      if(DEFINED USE_OROCOS_LIBRARY_DIRS)
        list(REMOVE_DUPLICATES USE_OROCOS_LIBRARY_DIRS)
      endif()
      if(DEFINED USE_OROCOS_CFLAGS_OTHER)
        list(REMOVE_DUPLICATES USE_OROCOS_CFLAGS_OTHER)
      endif()
      if(DEFINED USE_OROCOS_LDFLAGS_OTHER)
        list(REMOVE_DUPLICATES USE_OROCOS_LDFLAGS_OTHER)
      endif()
      if(DEFINED USE_OROCOS_EXPORTED_TARGETS)
        list(REMOVE_DUPLICATES USE_OROCOS_EXPORTED_TARGETS)
      endif()

      # Backwards compatibility
      # Add compiler and linker flags to the USE_OROCOS_XXX_FLAGS variables used in the orocos_add_x macros
      set(USE_OROCOS_COMPILE_FLAGS ${USE_OROCOS_CFLAGS_OTHER})
      set(USE_OROCOS_LINK_FLAGS ${USE_OROCOS_LDFLAGS_OTHER})
    endif()
  else()
    if("$ENV{VERBOSE}" OR ORO_USE_VERBOSE)
      message(STATUS "[UseOrocos] Package '${PACKAGE}' is already being used.")
    endif()
  endif()
endmacro()

macro(_orocos_list_to_string _string _list)
    set(${_string})
    foreach(_item ${_list})
        string(LENGTH "${${_string}}" _len)
        if(${_len} GREATER 0)
          set(${_string} "${${_string}} ${_item}")
        else(${_len} GREATER 0)
          set(${_string} "${_item}")
        endif(${_len} GREATER 0)
    endforeach(_item)
endmacro(_orocos_list_to_string)

macro(orocos_add_compile_flags target)
  set(args ${ARGN})
  separate_arguments(args)
  get_target_property(_flags ${target} COMPILE_FLAGS)
  if(NOT _flags)
    set(_flags ${ARGN})
  else(NOT _flags)
    separate_arguments(_flags)
    list(APPEND _flags "${args}")
  endif(NOT _flags)

  _orocos_list_to_string(_flags_str "${_flags}")
  set_target_properties(${target} PROPERTIES
                        COMPILE_FLAGS "${_flags_str}")
endmacro(orocos_add_compile_flags)

macro(orocos_add_link_flags target)
  set(args ${ARGN})
  separate_arguments(args)
  get_target_property(_flags ${target} LINK_FLAGS)
  if(NOT _flags)
    set(_flags ${ARGN})
  else(NOT _flags)
    separate_arguments(_flags)
    list(APPEND _flags "${args}")
  endif(NOT _flags)

  _orocos_list_to_string(_flags_str "${_flags}")
  set_target_properties(${target} PROPERTIES
                        LINK_FLAGS "${_flags_str}")
endmacro(orocos_add_link_flags)

macro(orocos_set_install_rpath target)
  set(_install_rpath ${ARGN} "${OROCOS-RTT_LIBRARY_DIRS};${CMAKE_INSTALL_PREFIX}/lib/orocos${OROCOS_SUFFIX}/${PROJECT_NAME};${CMAKE_INSTALL_PREFIX}/lib/orocos${OROCOS_SUFFIX}/${PROJECT_NAME}/types;${CMAKE_INSTALL_PREFIX}/lib/orocos${OROCOS_SUFFIX}/${PROJECT_NAME}/plugins;${CMAKE_INSTALL_PREFIX}/lib")

  # strip DESTDIR from all RPATH entries...
  if(DEFINED ENV{DESTDIR})
    string(REPLACE "$ENV{DESTDIR}" "" _install_rpath "${_install_rpath}")
  endif()

  # ... and remove duplicates
  if(DEFINED _install_rpath)
    list(REMOVE_DUPLICATES _install_rpath)
  endif()

  set_target_properties(${target} PROPERTIES
                        INSTALL_RPATH "${_install_rpath}")

  if(APPLE)
    if (CMAKE_VERSION VERSION_LESS "3.0.0")
      SET_TARGET_PROPERTIES( ${target} PROPERTIES
        INSTALL_NAME_DIR "@rpath"
        )
    else()
      # cope with CMake 3.x
      SET_TARGET_PROPERTIES( ${target} PROPERTIES
        MACOSX_RPATH ON)
    endif()
  endif()

  if("$ENV{VERBOSE}" OR ORO_USE_VERBOSE)
    message(STATUS "[UseOrocos] Setting RPATH of target '${target}' to '${_install_rpath}'.")
  endif()
endmacro(orocos_set_install_rpath)

