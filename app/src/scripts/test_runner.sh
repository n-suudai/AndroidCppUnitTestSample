#!/bin/bash

DIRNAME=$(dirname "$0")
CURRENT=$(cd "$DIRNAME" || exit 1;pwd)

pushd "$CURRENT" > log.txt || exit 1

cleanup() {
    rm -rf "TestResult/$TARGET_TEST_FILENAME"
    popd >> log.txt || exit 1
}

if [ ! -d "TestResult" ]; then
    mkdir "TestResult"
fi

TEST_EXECUTABLE_FILE=$1
TARGET_TEST_FILENAME=$(basename "$1")

SUCCEEDED_FILENAME=$TARGET_TEST_FILENAME_SUCCEEDED.txt
DESTINATION_DIRECTORY=/data/local/tmp/my_test/$TARGET_TEST_FILENAME

shift

ARGS=$1
while [ "$1" != "" ]
do
    shift
    ARGS="$ARGS $1"
done

echo "SHELL=$SHELL" >> log.txt
echo "ARGS=$ARGS" >> log.txt

cp "$TEST_EXECUTABLE_FILE" .

{

adb push "$TARGET_TEST_FILENAME" "$DESTINATION_DIRECTORY/$TARGET_TEST_FILENAME"

adb shell "cd $DESTINATION_DIRECTORY && chmod 775 ./$TARGET_TEST_FILENAME"

adb shell "cd $DESTINATION_DIRECTORY && ./$TARGET_TEST_FILENAME $ARGS > output.txt && touch $SUCCEEDED_FILENAME"

adb shell ls "/data/local/tmp/ring"

adb pull "$DESTINATION_DIRECTORY/" "TestResult"

adb shell rm -rf "$DESTINATION_DIRECTORY"

} >> log.txt


cat "TestResult/$TARGET_TEST_FILENAME/output.txt"

if [ ! -e "TestResult/$TARGET_TEST_FILENAME/$SUCCEEDED_FILENAME" ]; then
    cleanup && exit 1
else
    cleanup && exit 0
fi
