add_library(tbb UNKNOWN IMPORTED)

find_path(TBB_INCLUDE_DIR tbb/tbb.h)
mark_as_advanced(TBB_INCLUDE_DIR)

find_library(TBB_LIBRARY tbb)
mark_as_advanced(TBB_LIBRARY)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(TBB DEFAULT_MSG
    TBB_INCLUDE_DIR
    TBB_LIBRARY
    )

if (NOT TBB_FOUND)
  ExternalProject_Add(01org_tbb
      GIT_REPOSITORY https://github.com/01org/tbb
      GIT_TAG eb6336ad29450f2a64af5123ca1b9429ff6bc11d
      BUILD_IN_SOURCE 1
      BUILD_COMMAND $(MAKE) tbb_build_prefix=build
      CONFIGURE_COMMAND "" # remove configure step
      INSTALL_COMMAND "" # remove install step
      TEST_COMMAND "" # remove test step
      UPDATE_COMMAND "" # remove update step
      )
  ExternalProject_Get_Property(01org_tbb source_dir)
  set(TBB_INCLUDE_DIR ${source_dir}/include)
  if (CMAKE_BUILD_TYPE MATCHES Debug)
    set(TBB_LIBRARY ${source_dir}/build/build_debug/libtbb_debug.so.2)
  else()
    set(TBB_LIBRARY ${source_dir}/build/build_release/libtbb.so.2)
  endif ()
  file(MAKE_DIRECTORY ${TBB_INCLUDE_DIR})

  add_dependencies(tbb 01org_tbb)
endif ()

set_target_properties(tbb PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${TBB_INCLUDE_DIR}
    IMPORTED_LOCATION ${TBB_LIBRARY}
    )
