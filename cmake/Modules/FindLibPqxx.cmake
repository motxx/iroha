add_library(pqxx UNKNOWN IMPORTED)

find_package(PostgreSQL QUIET)
if (NOT PostgreSQL_LIBRARY)
  message(FATAL_ERROR "libpq not found")
endif ()

find_path(LibPqxx_INCLUDE_DIR pqxx/pqxx)
mark_as_advanced(LibPqxx_INCLUDE_DIR)

find_library(LibPqxx_LIBRARY pqxx)
mark_as_advanced(LibPqxx_LIBRARY)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(LibPqxx DEFAULT_MSG
    LibPqxx_INCLUDE_DIR
    LibPqxx_LIBRARY
    )

if (NOT LIBPQXX_FOUND)
  externalproject_add(jtv_libpqxx
      GIT_REPOSITORY https://github.com/jtv/libpqxx.git
      GIT_TAG 5b17abce5ac2b1a2f8278718405b7ade8bb30ae9
      CONFIGURE_COMMAND ./configure --disable-documentation --with-pic CXXFLAGS=${CMAKE_CXX_FLAGS}
      BUILD_IN_SOURCE 1
      BUILD_COMMAND $(MAKE)
      INSTALL_COMMAND "" # remove install step
      TEST_COMMAND "" # remove test step
      UPDATE_COMMAND "" # remove update step
      )
  externalproject_get_property(jtv_libpqxx source_dir)
  set(LibPqxx_INCLUDE_DIR ${source_dir}/include)
  set(LibPqxx_LIBRARY ${source_dir}/src/.libs/libpqxx.a)
  file(MAKE_DIRECTORY ${LibPqxx_INCLUDE_DIR})

  add_dependencies(pqxx jtv_libpqxx)
endif ()

set_target_properties(pqxx PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${LibPqxx_INCLUDE_DIR}
    IMPORTED_LOCATION ${LibPqxx_LIBRARY}
    INTERFACE_LINK_LIBRARIES "pq"
    )
