cmake_minimum_required(VERSION 3.18.1)

project(my_test LANGUAGES C CXX)

include(GoogleTest)

# WindowsではANDROID_NDKをそのまま使用すると
# バックスラッシュがエスケープ文字と認識されてしまうので置き換える
if("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
    string(
            REPLACE
            "\\"
            "/"
            NDK_DIR
            "${ANDROID_NDK}"
    )
else()
    set(
        NDK_DIR
        ${ANDROID_NDK}
    )
endif()

set(GOOGLETEST_ROOT
        ${NDK_DIR}/sources/third_party/googletest
        )

add_library(
        gtest_main
        STATIC
        ${GOOGLETEST_ROOT}/src/gtest_main.cc
        ${GOOGLETEST_ROOT}/src/gtest-all.cc
)

target_include_directories(
        gtest_main
        PRIVATE
        ${GOOGLETEST_ROOT}
)

target_include_directories(
        gtest_main
        PUBLIC
        ${GOOGLETEST_ROOT}/include
)


# テスト用の実行可能ターゲット
add_executable(
        my_test
        my_test.cpp
)

# ライブラリのリンク
target_link_libraries(
        my_test

        PRIVATE
        gtest_main
)

# CROSSCOMPILING_EMULATOR プロパティを設定
# ここで設定したスクリプトは「テストのリストアップ」、「テストの実行」時に使用される
if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Windows")
    set(MY_TEST_RUNNER
            ${CMAKE_SOURCE_DIR}/../../scripts/test_runner.bat
    )
else()
    set(MY_TEST_RUNNER
            ${CMAKE_SOURCE_DIR}/../../scripts/test_runner.sh
    )
endif()

set_target_properties(
        my_test

        PROPERTIES
        CROSSCOMPILING_EMULATOR
        ${MY_TEST_RUNNER}
)

# テストの登録
gtest_discover_tests(
        my_test
        DISCOVERY_TIMEOUT 20
        DISCOVERY_MODE PRE_TEST
)

# CMakeのビルドディレクトリを特定する
if("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
    string(
            REPLACE
            "/"
            "\\"
            MY_CMAKE_BINARY_DIR
            ${CMAKE_BINARY_DIR}
    )
else()
    string(
            REPLACE
            "\\"
            "/"
            MY_CMAKE_BINARY_DIR
            ${CMAKE_BINARY_DIR}
    )
endif()
file(
        WRITE
        ${CMAKE_SOURCE_DIR}/../../scripts/${ANDROID_ABI}/cmake_binary_dir.txt
        ${MY_CMAKE_BINARY_DIR}
)
