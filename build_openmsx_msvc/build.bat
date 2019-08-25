if /i %1 == win32 (set VCTARGET=x86) else (set VCTARGET=%1)

if exist "%programfiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
  for /F "tokens=* USEBACKQ" %%F in (`"%programfiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -version 15.0 -property installationPath`) do set INSTALLPATH=%%F
)

call "%INSTALLPATH%\VC\Auxiliary\Build\vcvarsall.bat" %VCTARGET%

msbuild -p:Configuration=%2;Platform=%1 build\3rdparty\3rdparty.sln /m
if %ERRORLEVEL% NEQ 0 exit %ERRORLEVEL%
msbuild -p:Configuration=%2;Platform=%1 build\msvc\openmsx.sln /m
