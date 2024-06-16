set oldCD=%CD%
cd assets
FOR /F "tokens=* delims=*" %%g IN ('dir /b /s /a:d') DO (
    forfiles /M "*.ogg" /P %%g /C "cmd /Q /C for %%I in (@FNAME) do (%oldCD%\tools\ffmpeg -i %%I.ogg -n -vn -ar 44100 -ac 2 -b:a 1411k %%I.wav && echo %%I)"
)
cd %oldCD%
pause