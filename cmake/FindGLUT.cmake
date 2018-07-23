# GLUT Find Module

if(NOT GLUT_DIR)
  set(GLUT_DIR ${FS_PACKAGES_DIR}/glut/3.7)
endif()

find_path(GLUT_INCLUDE_DIR HINTS ${GLUT_DIR} NAMES GL/glut.h PATH_SUFFIXES include)
find_library(GLUT_LIBRARY HINTS ${GLUT_DIR} NAMES libglut.a PATH_SUFFIXES lib)
find_library(X11_LIBRARY NAMES X11)
find_library(XMU_LIBRARY NAMES Xmu)
find_package_handle_standard_args(GLUT DEFAULT_MSG GLUT_INCLUDE_DIR GLUT_LIBRARY X11_LIBRARY XMU_LIBRARY)
set(GLUT_LIBRARIES ${GLUT_LIBRARY} ${X11_LIBRARY} ${XMU_LIBRARY})