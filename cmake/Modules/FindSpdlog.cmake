add_library(spdlog INTERFACE IMPORTED)

find_path(Spdlog_INCLUDE_DIRS spdlog/spdlog.h)
mark_as_advanced(Spdlog_INCLUDE_DIRS)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(spdlog DEFAULT_MSG
    Spdlog_INCLUDE_DIRS
    )

if (NOT SPDLOG_FOUND)
  externalproject_add(gabime_spdlog
      GIT_REPOSITORY https://github.com/gabime/spdlog
      GIT_TAG f85a08622e20b74bff34381cafcb8ef8167b29d0
      CONFIGURE_COMMAND "" # remove configure step
      BUILD_COMMAND "" # remove build step
      INSTALL_COMMAND "" # remove install step
      TEST_COMMAND "" # remove test step
      UPDATE_COMMAND "" # remove update step
      )
  externalproject_get_property(gabime_spdlog source_dir)
  set(Spdlog_INCLUDE_DIRS ${source_dir}/include)
  file(MAKE_DIRECTORY ${Spdlog_INCLUDE_DIRS})

  add_dependencies(spdlog gabime_spdlog)
endif ()

set_target_properties(spdlog PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${Spdlog_INCLUDE_DIRS}
    )
