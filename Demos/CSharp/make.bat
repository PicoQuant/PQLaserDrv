@echo off

rem set path to your C# compiler
set CS="C:\Program Files (x86)\Mono\bin\mcs"

echo Compiling 'ReadAllDataByCSharp.exe' ...
call %CS% ReadAllDataByCSharp.cs Sepia2_Import.cs

echo.
echo Compiling 'SetSomeDataByCSharp.exe' ...
call %CS% SetSomeDataByCSharp.cs Sepia2_Import.cs

echo.
pause

