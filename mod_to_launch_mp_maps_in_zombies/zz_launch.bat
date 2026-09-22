@echo off
setlocal

title Launching MP Maps in Zombies

for /f "usebackq eol=# tokens=1,* delims==" %%a in ("%~dp0.env") do set "%%a=%%b"

python "%~dp0scripts\launch.py" --oat-base "%OAT_BASE%" --oat-game "%OAT_GAME%" --gsc-tool "%GSC_TOOL%" --player-name "%PLAYER_NAME%" --plutonium-dir "%PLUTONIUM_DIR%" %*
exit /b %ERRORLEVEL%
