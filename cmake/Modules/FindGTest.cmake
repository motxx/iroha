add_library(gtest UNKNOWN IMPORTED)
add_library(gmock UNKNOWN IMPORTED)

find_path(GTest_INCLUDE_DIR gtest/gtest.h)
mark_as_advanced(GTest_INCLUDE_DIR)

find_library(GTest_LIBRARY gtest)
mark_as_advanced(GTest_LIBRARY)

find_library(GTest_MAIN_LIBRARY gtest_main)
mark_as_advanced(GTest_MAIN_LIBRARY)

find_path(GMock_INCLUDE_DIR gmock/gmock.h)
mark_as_advanced(GMock_INCLUDE_DIR)

find_library(GMock_LIBRARY gmock)
mark_as_advanced(GMock_LIBRARY)

find_library(GMock_MAIN_LIBRARY gmock_main)
mark_as_advanced(GMock_MAIN_LIBRARY)

find_package(PackageHandleStandardArgs REQUIRED)
find_package_handle_standard_args(GTest DEFAULT_MSG
    GTest_INCLUDE_DIR
    GTest_LIBRARY
    GTest_MAIN_LIBRARY
    GMock_INCLUDE_DIR
    GMock_LIBRARY
    GMock_MAIN_LIBRARY
    )

if (NOT GTEST_FOUND)
  ExternalProject_Add(google_test
      GIT_REPOSITORY "https://github.com/google/googletest.git"
      GIT_TAG ec44c6c1675c25b9827aacd08c02433cccde7780
      CMAKE_ARGS -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -Dgtest_force_shared_crt=ON
      -Dgtest_disable_pthreads=OFF
      INSTALL_COMMAND "" # remove install step
      UPDATE_COMMAND "" # remove update step
      TEST_COMMAND "" # remove test step
      )
  ExternalProject_Get_Property(google_test source_dir binary_dir)
  set(GTest_INCLUDE_DIR ${source_dir}/googletest/include)
  set(GMock_INCLUDE_DIR ${source_dir}/googlemock/include)

  set(GTest_MAIN_LIBRARY ${binary_dir}/googlemock/gtest/libgtest_main.a)
  set(GTest_LIBRARY ${binary_dir}/googlemock/gtest/libgtest.a)

  set(GMock_MAIN_LIBRARY ${binary_dir}/googlemock/libgmock_main.a)
  set(GMock_LIBRARY ${binary_dir}/googlemock/libgmock.a)

  file(MAKE_DIRECTORY ${GTest_INCLUDE_DIR})
  file(MAKE_DIRECTORY ${GMock_INCLUDE_DIR})

  add_dependencies(gtest google_test)
  add_dependencies(gmock google_test)
endif ()

set_target_properties(gtest PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${GTest_INCLUDE_DIR}
    INTERFACE_LINK_LIBRARIES "pthread;${GTest_MAIN_LIBRARY}"
    IMPORTED_LOCATION ${GTest_LIBRARY}
    )

set_target_properties(gmock PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${GMock_INCLUDE_DIR}
    INTERFACE_LINK_LIBRARIES "pthread;${GMock_MAIN_LIBRARY}"
    IMPORTED_LOCATION ${GMock_LIBRARY}
    )
