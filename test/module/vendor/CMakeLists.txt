addtest(uvw_test uvw_test.cpp)
target_link_libraries(uvw_test
    uvw
    )

addtest(rxcpp_subject_usage rxcpp_subject_usage.cpp)
target_link_libraries(rxcpp_subject_usage
    rxcpp
    )

addtest(tbb_test tbb_test.cpp)
target_link_libraries(tbb_test
    tbb
    )
