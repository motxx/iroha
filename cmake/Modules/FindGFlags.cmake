add_library(gflags UNKNOWN IMPORTED)

find_path(GFlags_INCLUDE_DIR gflags/gflags.h)
mark_as_advanced(GFlags_INCLUDE_DIR)

find_library(GFlags_LIBRARY gflags)
mark_as_advanced(GFlags_LIBRARY)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(GFlags DEFAULT_MSG
    GFlags_INCLUDE_DIR
    GFlags_LIBRARY
    )

if (NOT GFLAGS_FOUND)
  externalproject_add(gflags_gflags
      GIT_REPOSITORY https://github.com/gflags/gflags
      GIT_TAG f8a0efe03aa69b3336d8e228b37d4ccb17324b88
      INSTALL_COMMAND "" # remove install step
      TEST_COMMAND "" # remove test step
      UPDATE_COMMAND "" # remove update step
      )
  externalproject_get_property(gflags_gflags binary_dir)
  set(GFlags_INCLUDE_DIR ${binary_dir}/include)
  set(GFlags_LIBRARY ${binary_dir}/lib/libgflags.a)
  file(MAKE_DIRECTORY ${GFlags_INCLUDE_DIR})

  add_dependencies(gflags gflags_gflags)
endif ()

set_target_properties(gflags PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${GFlags_INCLUDE_DIR}
    IMPORTED_LOCATION ${GFlags_LIBRARY}
    IMPORTED_LINK_INTERFACE_LIBRARIES "pthread"
    )
