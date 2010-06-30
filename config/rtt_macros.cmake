#
# Include and link against required stuff
#

#
# RTT supplies header files which should be included when 
# using RTT. Each subdir should use this macro
# to supply its header-files.
#
# Usage: GLOBAL_ADD_INCLUDE( RELATIVE_LOCATION hpp1, hpp2 ...)
MACRO( GLOBAL_ADD_INCLUDE COMPONENT_LOCATION )
  INSTALL(FILES ${ARGN} DESTINATION include/${COMPONENT_LOCATION} COMPONENT headers)
ENDMACRO( GLOBAL_ADD_INCLUDE COMPONENT_LOCATION )

#
# Sources should add themselves by calling 'GLOBAL_ADD_SRC' 
# instead of 'ADD_LIBRARY' in CMakeLists.txt.
#
# This gives a centralised location where all sources are registered
# and lets us make the library in just one place.
#
#
# Usage: GLOBAL_ADD_SRC( src1 src2 src3 )
#
MACRO( GLOBAL_ADD_SRC )
  STRING(LENGTH "${ARGN}" NOTEMPTY)
  IF(NOTEMPTY)
    SET (ENV{GLOBAL_LIBRARY_SRCS} "$ENV{GLOBAL_LIBRARY_SRCS}${ARGN};" )
  ENDIF(NOTEMPTY) 
ENDMACRO( GLOBAL_ADD_SRC )

#
# Usage: ADD_RTT_TYPEKIT( name version file1.cpp [file2.cpp...] )
#
# Requires: OROCOS_TARGET, 
#           PROJ_BINARY_DIR (optional, if given plugin is also installed in PROJ_BINARY_DIR/orocos/types ),
#           RTT_DEFINITIONS (optional, added as COMPILE_DEFINITIONS to target's properties).
#
# The resulting CMake target's name is '${name}-${OROCOS_TARGET}_plugin'
# The resulting filename is '${name}-${OROCOS_TARGET}[.dll|.so|...]'
#
macro(ADD_RTT_TYPEKIT name version)
  ADD_LIBRARY(${name}-${OROCOS_TARGET}_plugin SHARED ${ARGN})
  SET_TARGET_PROPERTIES( ${name}-${OROCOS_TARGET}_plugin PROPERTIES
    VERSION "${version}"
    OUTPUT_NAME ${name}-${OROCOS_TARGET}
    COMPILE_DEFINITIONS "${RTT_DEFINITIONS}"
    CLEAN_DIRECT_OUTPUT 1)

  target_link_libraries(${name}-${OROCOS_TARGET}_plugin orocos-rtt-${OROCOS_TARGET}_dynamic)
  
  # Note: typkits don't get the symlinks
  install(TARGETS ${name}-${OROCOS_TARGET}_plugin
          LIBRARY DESTINATION lib/orocos/types NAMELINK_SKIP)

  get_target_property(TYPEKITLIB_DIR ${name}-${OROCOS_TARGET}_plugin LOCATION)

  if (PROJ_BINARY_DIR)
    add_custom_command(TARGET ${name}-${OROCOS_TARGET}_plugin POST_BUILD
          COMMAND cmake -E make_directory ${PROJ_BINARY_DIR}/rtt/types
          COMMAND cmake -E copy ${TYPEKITLIB_DIR} ${PROJ_BINARY_DIR}/rtt/types)
  endif(PROJ_BINARY_DIR)
  
endmacro(ADD_RTT_TYPEKIT name)

#
# Usage: ADD_RTT_PLUGIN( name version file1.cpp [file2.cpp...] )
#
# Requires: OROCOS_TARGET, 
#           PROJ_BINARY_DIR (optional, if given plugin is also installed in PROJ_BINARY_DIR/orocos/plugins ),
#           RTT_DEFINITIONS (optional, added as COMPILE_DEFINITIONS to target's properties).
#
# The resulting CMake target's name is '${name}-${OROCOS_TARGET}_plugin'
# The resulting filename is '${name}-${OROCOS_TARGET}[.dll|.so|...]'
#
macro(ADD_RTT_PLUGIN name version)
  ADD_LIBRARY(${name}-${OROCOS_TARGET}_plugin SHARED ${ARGN})
  SET_TARGET_PROPERTIES( ${name}-${OROCOS_TARGET}_plugin PROPERTIES
    VERSION "${version}"
    OUTPUT_NAME ${name}-${OROCOS_TARGET}
    COMPILE_DEFINITIONS "${RTT_DEFINITIONS}"
    CLEAN_DIRECT_OUTPUT 1)

  target_link_libraries(${name}-${OROCOS_TARGET}_plugin orocos-rtt-${OROCOS_TARGET}_dynamic)
  
  # Note: plugins do get the symlinks
  install(TARGETS ${name}-${OROCOS_TARGET}_plugin
          LIBRARY DESTINATION lib/orocos/plugins)

  get_target_property(PLUGINLIB_DIR ${name}-${OROCOS_TARGET}_plugin LOCATION)

  if (PROJ_BINARY_DIR)
    add_custom_command(TARGET ${name}-${OROCOS_TARGET}_plugin POST_BUILD
          COMMAND cmake -E make_directory ${PROJ_BINARY_DIR}/rtt/plugins
          COMMAND cmake -E copy ${PLUGINLIB_DIR} ${PROJ_BINARY_DIR}/rtt/plugins)
  endif(PROJ_BINARY_DIR)
  
endmacro(ADD_RTT_PLUGIN name)

