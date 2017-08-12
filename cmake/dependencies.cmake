include(ExternalProject)
set(EP_PREFIX "${PROJECT_SOURCE_DIR}/external")
set_directory_properties(PROPERTIES
    EP_PREFIX ${EP_PREFIX}
    )

# Project dependencies.
find_package(Threads REQUIRED)

# Object transport
find_package(Protobuf)

# gRPC
find_package(GRPC)

# Crypto signatures and SHA3 hash
find_package(Ed25519)

# testing is an option. Look at the main CMakeLists.txt for details.
if (TESTING)
  find_package(GTest)
endif ()

# Logging
find_package(Spdlog)

# JSON serialization and deserialization
find_package(Rapidjson)

# Optional type
find_package(OptionalLite)

find_package(Uvw)

find_package(CppRedis)

find_package(LibPqxx)

find_package(GFlags)

find_package(RxCpp)

find_package(TBB)
