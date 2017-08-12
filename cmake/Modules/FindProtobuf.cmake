add_library(protobuf UNKNOWN IMPORTED)
add_executable(protoc IMPORTED)

find_path(Protobuf_INCLUDE_DIR google/protobuf/service.h)
mark_as_advanced(Protobuf_INCLUDE_DIR)

find_library(Protobuf_LIBRARY protobuf)
mark_as_advanced(Protobuf_LIBRARY)

find_program(Protobuf_protoc_EXECUTABLE protoc)
mark_as_advanced(Protobuf_protoc_EXECUTABLE)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(Protobuf DEFAULT_MSG
    Protobuf_INCLUDE_DIR
    Protobuf_LIBRARY
    Protobuf_protoc_EXECUTABLE
    )

if (NOT PROTOBUF_FOUND)
  externalproject_add(google_protobuf
      GIT_REPOSITORY https://github.com/google/protobuf
      GIT_TAG a6189acd18b00611c1dc7042299ad75486f08a1a
      CONFIGURE_COMMAND ./autogen.sh && ./configure
      BUILD_IN_SOURCE 1
      BUILD_COMMAND $(MAKE)
      INSTALL_COMMAND ""
      TEST_COMMAND "" # remove test step
      UPDATE_COMMAND "" # remove update step
      )
  externalproject_get_property(google_protobuf source_dir)
  set(Protobuf_INCLUDE_DIR ${source_dir}/src)
  set(Protobuf_LIBRARY_DIR ${source_dir}/src/.libs)
  set(Protobuf_LIBRARY ${source_dir}/src/.libs/libprotobuf.a)
  set(Protobuf_protoc_EXECUTABLE_DIR ${source_dir}/src)
  set(Protobuf_protoc_EXECUTABLE ${source_dir}/src/protoc)
  file(MAKE_DIRECTORY ${Protobuf_INCLUDE_DIR})

  add_dependencies(protoc google_protobuf)
  add_dependencies(protobuf google_protobuf protoc)
endif ()

set_target_properties(protobuf PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${Protobuf_INCLUDE_DIR}
    IMPORTED_LOCATION ${Protobuf_LIBRARY}
    )

set_target_properties(protoc PROPERTIES
    IMPORTED_LOCATION ${Protobuf_protoc_EXECUTABLE}
    )
