add_library(ed25519 UNKNOWN IMPORTED)

find_path(Ed25519_INCLUDE_DIR ed25519.h)
mark_as_advanced(Ed25519_INCLUDE_DIR)

find_library(Ed25519_LIBRARY ed25519)
mark_as_advanced(Ed25519_LIBRARY)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(Ed25519 DEFAULT_MSG
    Ed25519_INCLUDE_DIR Ed25519_LIBRARY
    )

if (NOT Ed25519_FOUND)
  externalproject_add(mizukisonoko_ed25519
      GIT_REPOSITORY https://github.com/MizukiSonoko/ed25519
      GIT_TAG 3a5c02cbd91f84983a1622ed6bc14de6264b8361
      BUILD_IN_SOURCE 1
      BUILD_COMMAND $(MAKE)
      CONFIGURE_COMMAND "" # remove configure step
      INSTALL_COMMAND "" # remove install step
      TEST_COMMAND "" # remove test step
      UPDATE_COMMAND "" # remove update step
      )
  externalproject_get_property(mizukisonoko_ed25519 source_dir)
  set(Ed25519_INCLUDE_DIR ${source_dir}/src)
  set(Ed25519_LIBRARY ${source_dir}/lib/libed25519.a)
  file(MAKE_DIRECTORY ${Ed25519_INCLUDE_DIR})

  add_dependencies(ed25519 mizukisonoko_ed25519)
endif ()

set_target_properties(ed25519 PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${Ed25519_INCLUDE_DIR}
    IMPORTED_LOCATION ${Ed25519_LIBRARY}
    )
