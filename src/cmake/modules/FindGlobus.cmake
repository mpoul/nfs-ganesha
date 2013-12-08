# - Find Globus library
# ThIS is only for Fedora 19 and testing purpose.

# Find the native Globus headers and libraries.
#  GLOBUS_INCLUDE_DIRS      - where to find globus, etc.
#  GLOBUS_LIBRARIES         - List of libraries when using globus.
#  GLOBUS_FOUND             - True if globus found.
SET(GLOBUS_FOUND 1)

FILE(TO_CMAKE_PATH "/usr/include" DIR)
SET(GLOBUS_INCLUDE_DIRS ${GLOBUS_INCLUDE_DIRS} "${DIR}")

SET(GLOBUS_LIBRARY_NAMES ${GLOBUS_LIBRARY_NAMES} "library_name_1")
SET(GLOBUS_LIBRARY_NAMES ${GLOBUS_LIBRARY_NAMES} "library_name_2")

FOREACH(name ${GLOBUS_LIBRARY_NAMES})
      # Look for this library.
      FIND_LIBRARY(GLOBUS_${name}_LIBRARY
        NAMES ${name}
      )
      # If any library is not found then the whole package is not found.
      IF(NOT GLOBUS_${name}_LIBRARY)
        SET(GLOBUS_FOUND 0)
      ENDIF(NOT GLOBUS_${name}_LIBRARY)

      # Build an ordered list of all the libraries needed.
      SET(GLOBUS_LIBRARIES ${GLOBUS_LIBRARIES} "${GLOBUS_${name}_LIBRARY}")
ENDFOREACH(name)

IF(GLOBUS_FOUND)
  MESSAGE(STATUS "Found globus headers: ${GLOBUS_INCLUDE_DIRS}")
  MESSAGE(STATUS "Found globus headers: ${GLOBUS_LIBRARIES}")
ENDIF(GLOBUS_FOUND)
