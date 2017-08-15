# Temporary comment-outed for compilation
#compile_proto_to_cpp     (api.proto)
#compile_proto_to_grpc_cpp(api_service.proto)

compile_proto_to_cpp(block.proto)
compile_proto_to_cpp(primitive.proto)
compile_proto_to_cpp(commands.proto)
compile_proto_to_cpp(queries.proto)
compile_proto_to_cpp(responses.proto)
compile_proto_to_grpc_cpp(endpoint.proto)
compile_proto_to_grpc_cpp(peer_service.proto)
compile_proto_to_grpc_cpp(yac.proto)
compile_proto_to_grpc_cpp(ordering.proto)
compile_proto_to_grpc_cpp(loader.proto)

add_library(schema
    block.pb.cc
    commands.pb.cc
    primitive.pb.cc
    queries.pb.cc
    responses.pb.cc
    )
target_link_libraries(schema
    protobuf
    )

add_library(endpoint
    endpoint.pb.cc
    endpoint.grpc.pb.cc
    )
target_link_libraries(endpoint
    protobuf
    grpc++
    schema
    )

add_library(peer_service_grpc
    peer_service.pb.cc
    peer_service.grpc.pb.cc
    )
target_link_libraries(peer_service_grpc
    protobuf
    grpc++
    )

add_library(yac_grpc
    yac.pb.cc
    yac.grpc.pb.cc
    )
target_link_libraries(yac_grpc
    protobuf
    grpc++
    )

add_library(ordering_grpc
    ordering.pb.cc
    ordering.grpc.pb.cc
    )
target_link_libraries(ordering_grpc
    protobuf
    grpc++
    schema
    )

add_library(loader_grpc
    loader.pb.cc
    loader.grpc.pb.cc
    )
target_link_libraries(loader_grpc
    protobuf
    grpc++
    schema
    )
