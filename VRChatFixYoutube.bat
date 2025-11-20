@echo off
set "HOSTS_FILE=%SystemRoot%\System32\drivers\etc\hosts"
set "TARGET=www.youtube.com"

echo 入力: Y = 追加/更新 D = 削除
echo Enter: Y = Add/Update D = Delete
set /p mode=入力 / Input: 
echo.

if /i "%mode%"=="Y" goto ADD
if /i "%mode%"=="D" goto DELETE
echo 操作はキャンセルされました。
echo Operation cancelled.
pause
exit /b

:ADMIN_CHECK
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo エラー: 管理者権限でこのスクリプトを実行してください！
    echo Error: Please run this script as Administrator!
    pause
    exit /b 1
)
exit /b 0

:DELETE
call :ADMIN_CHECK
if errorlevel 1 exit /b

findstr /i "%TARGET%" "%HOSTS_FILE%" >nul
if %errorlevel%==0 (
    copy "%HOSTS_FILE%" "%HOSTS_FILE%.bak" >nul
    findstr /i /v "%TARGET%" "%HOSTS_FILE%" > "%HOSTS_FILE%.tmp"
    move /y "%HOSTS_FILE%.tmp" "%HOSTS_FILE%" >nul
    echo 削除完了！
    echo Deletion complete!
) else (
    echo %TARGET% のエントリーは存在しません。
    echo No entry for %TARGET% found in hosts file.
)
pause
exit /b

:ADD
call :ADMIN_CHECK
if errorlevel 1 exit /b

findstr /i "%TARGET%" "%HOSTS_FILE%" >nul
if %errorlevel%==0 (
    echo 既に %TARGET% のエントリーが存在します:
    echo Entry for %TARGET% already exists:
    findstr /i "%TARGET%" "%HOSTS_FILE%"
    echo 上書きしますか? (y/n^):
    set /p "overwrite=Overwrite? (y/n): "
    if /i "%overwrite%"=="Y" (
        echo.
        echo 操作はキャンセルされました。
        echo Operation cancelled.
        exit /b
    ) else (
        rem 継続
    )
)
echo.

:: IPv4アドレスの取得 / Get IPv4 address by ping
set "IP="
for /f "tokens=2 delims=[]" %%A in ('ping -4 -n 1 %TARGET% ^| findstr "["') do (
    set "IP=%%A"
)
if "%IP%"=="" (
    echo IPv4アドレスの取得に失敗しました。
    echo Failed to get IPv4 address.
    exit /b
)

echo IP Address: %IP%
copy "%HOSTS_FILE%" "%HOSTS_FILE%.bak" >nul
findstr /i /v "%TARGET%" "%HOSTS_FILE%" > "%HOSTS_FILE%.tmp"
move /y "%HOSTS_FILE%.tmp" "%HOSTS_FILE%" >nul
echo %IP% %TARGET% >> "%HOSTS_FILE%"
echo hostsファイルを更新しました:
echo Hosts file updated:
findstr /i "%TARGET%" "%HOSTS_FILE%"

echo.
echo 操作完了！
echo Operation completed!
exit /b