@echo off
setlocal enabledelayedexpansion

cls

REM Check Internet Connection
ping -n 1 google.com >nul 2>&1
if errorlevel 0 (
    echo|set /p="Checking internet connection......"
	ping 127.0.0.1 -n 2 > nul
	echo available
    echo.
    goto checkadbinstalled
) else (
    echo Internet connection is not available...
    echo Please try this tool again later
    pause
    exit /b
)
echo|set /p="Stopping ADB..."
adb kill-server
echo Done^!

:checkadbinstalled

where adb.exe > files\logs\adblocation.txt 2>&1
set "checkadblevel=%errorlevel%"

echo. >> files\logs\adblocation.txt
REM Remove "adb.exe" from the end of each line. Credit: https://unix.stackexchange.com/questions/674338/delete-last-n-characters-from-lines-within-file
files\programs\sed.exe -i "s/.\{0,7\}[[:space:]]*$//" files\logs\adblocation.txt

if %checkadblevel%==1 (
    echo ADB is not installed yet...
    goto downloadadb
) else (
    echo.

    goto adbalreadyinstalled
    )


:adbalreadyinstalled
echo.

for /f "usebackq delims=" %%b in ("files\logs\adblocation.txt") do (
    echo Found ADB in: %%b
	echo.
	REM I use the full path because I found it like that in a StackOverflow answer. 
	%SystemRoot%\System32\choice.exe /C YN /N /M "Delete this ADB before installing an updated one (reccomended)?[Y/N]: "
	if !errorlevel!==2 (
	pause
	exit /b 
	) else if !errorlevel!==1 (
	echo Checking file permissions...
	set delrequiresuac=0
	FOR %%c IN (%%badb.exe %%bAdbWinApi.dll %%bAdbWinUsbApi.dll %%bfastboot.exe) DO (
		FOR /F "tokens=* USEBACKQ" %%d IN (`files\programs\stat.exe -c %%a %%c`) DO (

		files\programs\chmod.exe %%d %%c >nul 2>&1

		if !errorlevel!==0 (
		  REM Not sure if this comment is needed...
		) else ( 
		  set /a "delrequiresuac+=1"
		  echo !delrequiresuac!
		)
	))
	)
	

	if !delrequiresuac!==0 (

	REM Use rm because dir doesnt have proper errorlevels
	files\programs\rm.exe %%badb.exe %%bAdbWinApi.dll %%bAdbWinUsbApi.dll %%bfastboot.exe>nul 2>&1
	if !errorlevel!==0 ( 
	echo Files deleted successfully...
	) else (
	echo ADB installation failed. This will likely not be an issue. 
	)
	REM Needs UAC
	) else (
	echo Administrator priveleges required for !delrequiresuac!...
	ping 127.0.0.1 -n 3 > nul
	files\programs\gsudo.exe files\programs\rm.exe %%badb.exe %%bAdbWinApi.dll %%bAdbWinUsbApi.dll %%bfastboot.exe
	if !errorlevel!==0 ( 
	echo Files deleted successfully
	) else if !errorlevel!==999 (
	echo You must grant administrator permissions... Try again
	ping 127.0.0.1 -n 3 > nul
	echo.
	call deletefilesloop %%b
	) else ( 
	echo Error occured. This likely will not be a problem, so please ignore it...
	) 
	)
	)
	goto installadb


:deletefilesloop

echo Found ADB in: %1
echo.
%SystemRoot%\System32\choice.exe /C YN /N /M "Delete this ADB before installing an updated one (reccomended)?[Y/N]: "
if !errorlevel!==2 (
pause
exit /b 
) else if !errorlevel!==1 (
echo Checking file permissions...
set delrequiresuac=0
FOR %%c IN (%1adb.exe %1AdbWinApi.dll %1AdbWinUsbApi.dll %1fastboot.exe) DO (
	FOR /F "tokens=* USEBACKQ" %%d IN (`files\programs\stat.exe -c %%a %%c`) DO (
	files\programs\chmod.exe %%d %%c >nul 2>&1
	if !errorlevel!==0 (
	  REM Not sure if this comment is needed...
	) else ( 
	  set /a "delrequiresuac+=1"
	  echo !delrequiresuac!
	)
))
)
	if !delrequiresuac!==0 (

	REM Use rm because dir doesnt have proper errorlevels
	files\programs\rm.exe %1adb.exe %1AdbWinApi.dll %1AdbWinUsbApi %1fastboot.exe>nul 2>&1
	if !errorlevel!==0 ( 
	echo Files deleted successfully...
	) else (
	echo ADB installation failed. This will likely not be an issue. 
	)
	REM Needs UAC
	) else (
	echo Administrator priveleges required for !delrequiresuac!...
	ping 127.0.0.1 -n 3 > nul
	files\programs\gsudo.exe files\programs\rm.exe %1adb.exe %1AdbWinApi.dll %1AdbWinUsbApi %1fastboot.exe 
	if !errorlevel!==0 ( 
	echo Files deleted successfully
	) else if !errorlevel!==999 (
	echo You must grant administrator permissions... Try again
	ping 127.0.0.1 -n 3 > nul
	echo.
	call :deletefilesloop %1
	) else ( 
	echo Error occured. This likely will not be a problem, so please ignore it...
	) 
	)
	)

