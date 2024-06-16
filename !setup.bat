@echo off
mkdir tools > nul
echo Downloading FFMPEG...
cd tools
curl -kOL https://github.com/letsgoawaydev/ffmpeg/releases/download/ffmpeg/ffmpeg.exe
cd.. 
setup-msvc-win
haxelib install hmm
haxelib run hmm install
pause