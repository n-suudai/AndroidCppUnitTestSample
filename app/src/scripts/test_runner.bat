@echo off
setlocal

set CURRENT_DIRECTORY=%~dp0
pushd %CURRENT_DIRECTORY% > nul

rem テスト結果格納用のフォルダを作成
if not exist TestResult (
	md TestResult
)

rem 一つ目の引数は実行ファイルのパス
set TEST_EXECUTABLE_FILE=%1
set TARGET_TEST_FILENAME=%1

rem ファイル名だけを取り出す
call :Func_GetFileName %TARGET_TEST_FILENAME%

set SUCCEEDED_FILENAME=%TARGET_TEST_FILENAME%_SUCCEEDED.txt
set DESTINATION_DIRECTORY=/data/local/tmp/my_test/%TARGET_TEST_FILENAME%

goto :TESTING

rem ファイル名だけを取り出す
:Func_GetFileName
	set TARGET_TEST_FILENAME=%~nx1
exit /b


:TESTING

rem 1. 引数で渡された実行ファイルを端末にコピー

rem テストの実行ファイルを端末へアップロード
adb push %TEST_EXECUTABLE_FILE% %DESTINATION_DIRECTORY%/%TARGET_TEST_FILENAME% > nul



rem 2. 端末上で渡された引数とともに実行ファイルを起動

rem 一つ目の引数は実行ファイルのパスなのでシフトする
shift

rem 追加の引数がなければ終了
if "%1"=="" goto :ARGS_END

set SKIP_SPACE=false

rem シフト後の最初の引数を入れておく
set ARGS=%1
if "%ARGS%"=="--gtest_filter" (
    set ARGS=%ARGS%=
    set SKIP_SPACE=true
)

rem 更にシフト
shift

rem 残りの引数をループでシフトしながら取り出す
:ARGS_SHIFT

set ARGN=%1

if "%ARGN%"=="" goto :ARGS_END

if "%SKIP_SPACE%"=="true" (
    set ARGS=%ARGS%%ARGN%
    set SKIP_SPACE=false
    shift
    goto :ARGS_SHIFT
)

if "%ARGN%"=="--gtest_filter" (
    set ARGS=%ARGS% %ARGN%=
    set SKIP_SPACE=true
) else (
      set ARGS=%ARGS% %ARGN%
)

shift
goto :ARGS_SHIFT
:ARGS_END

rem ディレクトリ移動 && 実行権限付与
adb shell "cd %DESTINATION_DIRECTORY% && chmod 775 ./%TARGET_TEST_FILENAME%" > nul

rem ディレクトリ移動 && 実行 > output.txt へ標準出力を保存 && 成否判定用のファイルを作成
adb shell "cd %DESTINATION_DIRECTORY% && ./%TARGET_TEST_FILENAME% %ARGS% > output.txt && touch %SUCCEEDED_FILENAME%" > nul

rem テスト結果を TestResult へダウンロード
adb pull %DESTINATION_DIRECTORY% TestResult > nul

rem テスト実行に使用したディレクトリを削除
adb shell rm -rf %DESTINATION_DIRECTORY% > nul

rem テストの標準出力を転送
type TestResult\%TARGET_TEST_FILENAME%\output.txt


rem 3. テスト結果に合わせてスクリプトの終了コードを変更

rem テスト成功ファイルの存在チェック
if not exist TestResult\%TARGET_TEST_FILENAME%\%SUCCEEDED_FILENAME% (
	goto :TEST_FAILED
) else (
	goto :TEST_SUCCEEDED
)


rem 成功
:TEST_SUCCEEDED
del /Q TestResult\%TARGET_TEST_FILENAME%
popd
endlocal
exit /b 0


rem 失敗
:TEST_FAILED
del /Q TestResult\%TARGET_TEST_FILENAME%
popd
endlocal
exit /b -1
