@echo off
set oldCD=%CD%
cd assets
FOR /F "tokens=* delims=*" %%g IN ('dir /b /s /a:d') DO (
    forfiles /M "*.wav" /P %%g /C "cmd /Q /C for %%I in (@FNAME) do (%oldCD%\tools\ffmpeg -i %%I.wav -n -vn -ar 22050 -ac 2 -b:a 92k %%I-lq.mp3 && echo %%I)"
)
cd %oldCD%

color 2
echo Completed!
pause>nul

