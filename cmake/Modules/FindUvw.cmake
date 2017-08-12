add_library(uv UNKNOWN IMPORTED)
add_library(uvw INTERFACE IMPORTED)

find_path(Uv_INCLUDE_DIR uv.h)
mark_as_advanced(Uv_INCLUDE_DIR)

find_library(Uv_LIBRARY uv)
mark_as_advanced(Uv_LIBRARY)

find_path(Uvw_INCLUDE_DIR uvw.hpp)
mark_as_advanced(Uvw_INCLUDE_DIR)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(Uvw DEFAULT_MSG
    Uv_INCLUDE_DIR
    Uv_LIBRARY
    Uvw_INCLUDE_DIR
    )

if (NOT UVW_FOUND)
  externalproject_add(libuv_libuv
      URL https://github.com/libuv/libuv/archive/v1.13.1.tar.gz
      CONFIGURE_COMMAND ./autogen.sh && ./configure
      BUILD_IN_SOURCE 1
      BUILD_COMMAND $(MAKE)
      INSTALL_COMMAND "" # remove install step
      TEST_COMMAND "" # remove test step
      UPDATE_COMMAND "" # remove update step
      )
  externalproject_get_property(libuv_libuv source_dir)
  set(Uv_INCLUDE_DIR ${source_dir}/include)
  set(Uv_LIBRARY ${source_dir}/.libs/libuv.a)
  file(MAKE_DIRECTORY ${Uv_INCLUDE_DIR})

  add_dependencies(uv libuv_libuv)

  externalproject_add(skypjack_uvw
      GIT_REPOSITORY "https://github.com/skypjack/uvw.git"
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND "" # remove install step
      TEST_COMMAND "" # remove test step
      UPDATE_COMMAND "" # remove update step
      )
  externalproject_get_property(skypjack_uvw source_dir)
  set(Uvw_INCLUDE_DIR ${source_dir}/src)
  file(MAKE_DIRECTORY ${Uvw_INCLUDE_DIR})

  add_dependencies(skypjack_uvw uv)
  add_dependencies(uvw skypjack_uvw)
endif ()

set_target_properties(uv PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${Uv_INCLUDE_DIR}
    IMPORTED_LOCATION ${Uv_LIBRARY}
    INTERFACE_LINK_LIBRARIES "pthread"
    )

set_target_properties(uvw PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${Uvw_INCLUDE_DIR};${Uv_INCLUDE_DIR}"
    INTERFACE_LINK_LIBRARIES "uv;pthread"
    )
