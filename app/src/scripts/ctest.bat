echo off
setlocal

set CURRENT_DIR=%~dp0

rem 初めの引数はABIの指定
pushd %CURRENT_DIR%\%1


rem 1. CMakeのビルドディレクトリへ移動

rem cmake_binary_dir.txt からビルドディレクトリを読み取る
set BUILD_DIR=

for /f %%A in (cmake_binary_dir.txt) do (
        set BUILD_DIR=%BUILD_DIR%%%A
)

rem ビルドディレクトリへ移動
pushd %BUILD_DIR%


rem 2. ctestコマンドの実行

rem 初めの引数はABIの指定に使っているのでシフトする
shift

rem 残りの引数をすべて ctest へ渡す
ctest %*


rem 3. テスト結果に合わせてスクリプトの終了コードを変更

rem 実行結果で分岐
if %ERRORLEVEL% equ 0 (
	goto :TEST_SUCCEEDED
) else (
	goto :TEST_FAILED
)

rem 成功
:TEST_SUCCEEDED
popd
popd
endlocal
exit /b 0

rem 失敗
:TEST_FAILED
popd
popd
endlocal
exit /b -1
