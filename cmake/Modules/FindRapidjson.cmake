add_library(rapidjson INTERFACE IMPORTED)

find_path(Rapidjson_INCLUDE_DIR rapidjson/rapidjson.h)
mark_as_advanced(Rapidjson_INCLUDE_DIR)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(Rapidjson DEFAULT_MSG
    Rapidjson_INCLUDE_DIR
    )

if (NOT RAPIDJSON_FOUND)
  externalproject_add(miloyip_rapidjson
      GIT_REPOSITORY https://github.com/miloyip/rapidjson
      GIT_TAG f54b0e47a08782a6131cc3d60f94d038fa6e0a51
      BUILD_COMMAND "" # remove build step, header only lib
      CONFIGURE_COMMAND "" # remove configure step
      INSTALL_COMMAND "" # remove install step
      TEST_COMMAND "" # remove test step
      UPDATE_COMMAND "" # remove update step
      )
  externalproject_get_property(miloyip_rapidjson source_dir)
  set(Rapidjson_INCLUDE_DIR "${source_dir}/include")

  file(MAKE_DIRECTORY ${Rapidjson_INCLUDE_DIR})

  add_dependencies(rapidjson miloyip_rapidjson)
endif ()

set_target_properties(rapidjson PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${Rapidjson_INCLUDE_DIR}
    )
