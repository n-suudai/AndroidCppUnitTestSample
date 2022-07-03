#!/bin/bash

DIRNAME=$(dirname "$0")
CURRENT=$(cd "$DIRNAME" || exit 1;pwd)

pushd "$CURRENT/$1" > "$CURRENT/test_log.txt" || exit 1

cleanup() {
    popd >> "$CURRENT/test_log.txt" || exit 1
}

BUILD_DIR=$(cat cmake_binary_dir.txt)

pushd "$BUILD_DIR" >> "$CURRENT/test_log.txt" || exit 1

shift
ctest "$@" || exit 1

popd >> "$CURRENT/test_log.txt" || exit 1

cleanup || exit 1

exit 0
