FILE( GLOB CPPS [^.]*.cpp )
FILE( GLOB HPPS [^.]*.hpp [^.]*.h [^.]*.inl)

message("SHOW REMOTE HEADERS: ${HPPS}")
GLOBAL_ADD_INCLUDE( rtt/remote ${HPPS})
GLOBAL_ADD_SRC( ${CPPS})

