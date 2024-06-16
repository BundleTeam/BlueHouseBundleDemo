@echo off
set oldCD=%CD%
cd assets
FOR /F "tokens=* delims=*" %%g IN ('dir /b /s /a:d') DO (
    forfiles /M "*-lq.mp3" /P %%g /C "cmd /Q /C for %%I in (@FNAME) do (del %%I.mp3)"
)
cd %oldCD%

color 2
echo Completed!
pause>nul

