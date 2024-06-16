@echo off
:main
set /p "TopText=Top Text: "
set /p "BottomText=Bottom Text: "
echo.
echo %TopText%
echo %BottomText%
echo.
choice /c yn /n /m "Add to introText.txt? (Y,N): "
if %ERRORLEVEL%==2 call:main
if %ERRORLEVEL%==1 (
echo %TopText%--%BottomText%>>%CD%\assets\preload\data\introText.txt
echo Added!
call:goAgain
)
goto:eof

:goAgain
echo.
choice /c yn /n /m "Add another? (Y,N): "
if %ERRORLEVEL%==1 call:main
goto:eof