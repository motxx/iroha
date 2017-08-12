add_library(rxcpp INTERFACE IMPORTED)

find_path(RxCpp_INCLUDE_DIR rxcpp/rx.hpp)
mark_as_advanced(RxCpp_INCLUDE_DIR)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(RxCpp DEFAULT_MSG
    RxCpp_INCLUDE_DIR
    )

if (NOT RXCPP_FOUND)
  externalproject_add(reactive_extensions_rxcpp
      GIT_REPOSITORY https://github.com/Reactive-Extensions/RxCpp
      GIT_TAG 08c47e42930168cedf76037f8c76d47565251599
      CONFIGURE_COMMAND ""
      BUILD_COMMAND ""
      INSTALL_COMMAND "" # remove install step
      UPDATE_COMMAND "" # remove update step
      TEST_COMMAND "" # remove test step
      )
  externalproject_get_property(reactive_extensions_rxcpp source_dir)
  set(RxCpp_INCLUDE_DIR ${source_dir}/Rx/v2/src)
  file(MAKE_DIRECTORY ${RxCpp_INCLUDE_DIR})

  add_dependencies(rxcpp reactive_extensions_rxcpp)
endif ()

set_target_properties(rxcpp PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${RxCpp_INCLUDE_DIR}
    )
