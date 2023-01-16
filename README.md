# Asteroids

## Runs on
* Commander X16: https://www.commanderx16.com/forum/viewtopic.php?t=6025
* You may run the pre-built ASTEROIDS.PRG on the root of the project or build it yourself

## Tools
All tools must be on your path
* RetroAssembler https://enginedesigns.net/
* ImageMagick https://imagemagick.org
* X16PngConverter https://cx16forum.com/forum/download/file.php?id=796

## Build
* Change into the "src" directory and run "copyassets.cmd". NOTE: This is for Windows and will need some tweaking for Linux.  ImageMagick and X16PngConverter must be on your path.
```
copyassets.cmd
```
* Change back to the root of the project
```
retroassembler.exe -g .\src\main.asm
```
