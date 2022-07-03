cmake_minimum_required(VERSION 3.18.1)

if (${MY_LIB_BUILD_TEST})
    enable_testing()
endif()

project("androidcppunittestsample")

add_library(
        androidcppunittestsample

        SHARED
        native-lib.cpp
)

find_library(
        log-lib

        log
)

target_link_libraries(
        androidcppunittestsample

        ${log-lib}
)

if (${MY_LIB_BUILD_TEST})
    add_subdirectory(../../test/cpp ${CMAKE_CURRENT_BINARY_DIR}/test)
endif()
