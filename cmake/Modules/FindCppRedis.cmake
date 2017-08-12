add_library(cpp_redis UNKNOWN IMPORTED)

find_path(CppRedis_INCLUDE_DIR cpp_redis/cpp_redis)
mark_as_advanced(CppRedis_INCLUDE_DIR)

find_library(CppRedis_LIBRARY cpp_redis)
mark_as_advanced(CppRedis_LIBRARY)

find_library(Tacopie_LIBRARY tacopie)
mark_as_advanced(CppRedis_LIBRARY)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(CppRedis DEFAULT_MSG
    CppRedis_INCLUDE_DIR
    CppRedis_LIBRARY
    Tacopie_LIBRARY
    )

if (NOT CppRedis_FOUND)
  externalproject_add(cylix_cpp_redis
      GIT_REPOSITORY https://github.com/Cylix/cpp_redis
      GIT_TAG 727aa5f06c8ce498168cbab5a023cad5b9c00bc0
      CMAKE_ARGS -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      INSTALL_COMMAND "" # remove install step
      UPDATE_COMMAND "" # remove update step
      TEST_COMMAND "" # remove test step
      )
  externalproject_get_property(cylix_cpp_redis source_dir binary_dir)
  set(Tacopie_SOURCE_DIR ${source_dir}/tacopie)
  set(CppRedis_INCLUDE_DIR ${source_dir}/includes)
  set(CppRedis_LIBRARY ${binary_dir}/lib/libcpp_redis.a)
  set(Tacopie_LIBRARY ${binary_dir}/lib/libtacopie.a)
  file(MAKE_DIRECTORY ${CppRedis_INCLUDE_DIR})

  externalproject_add(cylix_tacopie
      GIT_REPOSITORY https://github.com/Cylix/tacopie
      GIT_TAG 290dc38681f346adae41d3cc8feabbe534424675
      SOURCE_DIR ${Tacopie_SOURCE_DIR}
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND "" # remove install step
      UPDATE_COMMAND "" # remove update step
      TEST_COMMAND "" # remove test step
      )

  add_dependencies(cylix_cpp_redis cylix_tacopie)
  add_dependencies(cpp_redis cylix_cpp_redis)
endif ()

set_target_properties(cpp_redis PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${CppRedis_INCLUDE_DIR}
    IMPORTED_LOCATION ${CppRedis_LIBRARY}
    INTERFACE_LINK_LIBRARIES "${Tacopie_LIBRARY};pthread"
    )
