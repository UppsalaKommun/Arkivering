@ echo off
::::::::::::::::::::::::::::::::::::::::::::
:: Set default values and clear variables ::
::::::::::::::::::::::::::::::::::::::::::::
set EXECUTEARCHIVING=1
set HTTrackPATH="%ProgramFiles%\WinHTTrack\httrack.exe"
set CONFIGFILE="%~dp0HTMLarchiver.conf"
set SITEFILE="%~dp0sites.txt"
set LOGFILE="%~dp0HTMLarchiver.log"
set READMEFILE="%~dp0README.txt"
set TEMPFILES=C:\temp\dump
set CONNECTIONS=8
set CONNECTIONSPERSECOND=10
set CONFHTTrackPATH=
set CONFSITEFILE=
set CONFLOGFILE=
set STORAGE=
set CONFTEMPFILES=
set CONFCONNECTIONS=
set CONFCONNECTIONSPERSECOND=

:::::::::::::::::::::::::::::::::::::::::::::
:: Create config file, if it doesn´t exist ::
:::::::::::::::::::::::::::::::::::::::::::::
if not exist %CONFIGFILE% ( 
	call :createConfigFile
	set EXECUTEARCHIVING=0
	)

::::::::::::::::::::::::::::::::::
:: Read values from config-file ::
::::::::::::::::::::::::::::::::::
call :getsetting %CONFIGFILE% "HTTrackPath" "" CONFHTTrackPATH
call :getsetting %CONFIGFILE% "sitefile" "" CONFSITEFILE
call :getsetting %CONFIGFILE% "logfile" "" CONFLOGFILE
call :getsetting %CONFIGFILE% "storage" "" STORAGE
call :getsetting %CONFIGFILE% "temp" "" CONFTEMPFILES
call :getsetting %CONFIGFILE% "connections" "" CONFCONNECTIONS
call :getsetting %CONFIGFILE% "connsPerSecond" "" CONFCONNECTIONSPERSECOND

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: For all values specified in %CONFIGFILE%, change from the default to the configured values ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if defined CONFHTTrackPATH set HTTrackPATH=%CONFHTTrackPATH%
if defined CONFSITEFILE set SITEFILE=%CONFSITEFILE%
if defined CONFLOGFILE set LOGFILE=%CONFLOGFILE%
if defined CONFTEMPFILES set TEMPFILES=%CONFTEMPFILES%
if defined CONFCONNECTIONS set CONNECTIONS=%CONFCONNECTIONS%
if defined CONFCONNECTIONSPERSECOND set CONNECTIONSPERSECOND=%CONFCONNECTIONSPERSECOND%

::::::::::::::::::::::::::::::::::::::::::::::::
:: Create necessary files, if they dont exist ::
::::::::::::::::::::::::::::::::::::::::::::::::
if not exist %READMEFILE% call :createReadmeFile
if not exist %SITEFILE% (
	call :createSiteFile
	set EXECUTEARCHIVING=0
	)	

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check that we are supposed to archive, and that HTTrack is available ::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if %EXECUTEARCHIVING% EQU 0 (
	call :logger At least one of the necessary files was missing. That is now corrected, please look thru the config-file and the site-file, to ensure that they reflect what you want HTMLarchiver to do.
	exit /B)

if exist %HTTrackPATH% ( 
	call :logger #######################
	call :logger # Archiving initiated #
	call :logger #######################
	call :logger All sites will be stored in %STORAGE%
	call :Archiving 
) else (
	call :logger HTTrack is not available at the path %HTTrackPATH%.
	call :logger Check that HTTrack is installed, and that the path is correct.
	call :logger The path can be specified in %CONFIGFILE%.)
goto :eof 


:::::::::::::::::::::::::::::::::::::::::::::
:: Search %CONFIGFILE% for requested value ::
:::::::::::::::::::::::::::::::::::::::::::::
:getsetting
for /f "eol=# tokens=1,2* delims==" %%i in ('findstr /b /l /i %~2= %1') DO set %~4=%%~j
goto :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Logging routine, put all arguments in a timestamped logfile ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:logger
echo %DATE% %TIME:~0,5% : %* >> %LOGFILE%
goto :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: For every line in %SITEFILE%, call the routine :MakeHTMLDump, with the line as argument ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Archiving
for /f "usebackq eol=# tokens=1 delims=" %%a in (%SITEFILE%) do call :MakeHTMLDump %%a
if exist %TEMPFILES% (
::	call :logger Removing temporary files...
::	rmdir /s /q %TEMPFILES%)
goto :eof

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Call the program httrack in mirror-mode, with the arguments collected above 
:: Filter parameters:
:: -r20 = Link depth is 20
:: -R10 = Number of retries is 10
:: -T119 = Timeout is 119s
:: -N2 = Defines structure: N2 = HTML in web/HTML, other in web/xxx where xxx is file format
:: -e0 = external link depth is 0
:: -P = Parse all links
:: -s2 = follow robots.txt to avoid archiving of search results page (may cause infinite archiving loop otherwise)
:: -%I = create a searchable index
:: -I = create an index
:: -f2 = logfile mode
:: -v = verbose, prints errors and messages
:: (-L2 = Long Names...)
:: -b1 = accept cookies 
:: -u2 = always check document type if unknown
:: -F "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)" = User agent field
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MakeHTMLDump
call :logger Starting archiving of the site %1...
%HTTrackPATH% --mirror -P 127.0.0.1:3128 %2 -O %STORAGE%\%1\%date%,%TEMPFILES% -c%CONNECTIONS% -%%c%CONNECTIONSPERSECOND% %3 -r20 -R3 -T119 -N5 -%%P -s2 -I -f -%%I -b1 -u2 -L2 -F "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)" -*.bmp -*.doc -*.dot -*.eps -*.exe -*.htc -*.lnk -*.mso -*.pdf -*.pot -*.ppt -*.rtf -*.tif -*.wmf -*.xls -*.xlt -*.vsd -*.zip -*.psd -*.pps -*.asx -*.docx -*.pptx -*.xlsx -*.wav -*.emf -*.dotx -*.xltx -*.f4v -*.mht -*.aspx?mode=print* -*/wa/* -*/wa/* +*/wa/images/*
call :logger Archiving of the site %1 is done!
goto :eof





:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::                                                     ::::
::::  File creation, nothing to see below this point :)  ::::
::::                                                     ::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::





:createReadmeFile
echo HTMLarchiver.bat kräver att programmet WinHTTrack finns installerat på datorn. > %READMEFILE%
echo Sökvägen till programmet kan anges i HTMLarchiver's konfigurationsfil. I annat fall antas >> %READMEFILE%
echo %ProgramFiles%\WinHTTrack\httrack.exe >> %READMEFILE%
echo. >> %READMEFILE%
echo Förutom detta krav behövs ytterligare två filer för att HTMLarchiver ska fungera: >> %READMEFILE%
echo HTMLarchiver.conf och sites.txt. >> %READMEFILE%
echo Dessa båda filer ska ligga i samma katalog som HTMLarchiver.bat. Om så inte är fallet kommer två exempelfiler att skapas. >> %READMEFILE%
echo Konfigurera dessa efter behag innan HTMLarchiver körs. >> %READMEFILE%
echo. >> %READMEFILE%
echo Det skapas även en logfil, HTMLarchiver.log om inte annat anges. >> %READMEFILE%
echo. >> %READMEFILE%
echo Exempelfilerna innehåller information kring konfigurationsalternativ, samt exempel på hur dessa ska användas. >> %READMEFILE%
echo. >> %READMEFILE%
echo Björn Rengerstam   2013-01-23 >> %READMEFILE%
goto :eof

:createConfigFile
echo # ===================================================================================================================== > %CONFIGFILE%
echo # Konfigurationsfil för scriptet HTMLarchiver >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # Rader som inleds med # räknas som kommentarer, och bortses ifrån. >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # Följande parametrar kan anges i denna fil: >> %CONFIGFILE%
echo # HTTrackPath >> %CONFIGFILE%
echo #   Sökvägen till filen httrack.exe (inklusive filnamnet). >> %CONFIGFILE%
echo #   Defaultvärde: "%ProgramFiles%\WinHTTrack\httrack.exe" >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # sitefile >> %CONFIGFILE%
echo #   Textfil med specifikation av vilka siter som ska arkiveras, och hur. >> %CONFIGFILE%
echo #   Defaultvärde: sites.txt >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # logfile >> %CONFIGFILE%
echo #   Loggfil till vilken information skrivs under körningen. >> %CONFIGFILE%
echo #   Defaultvärde: HTMLarchiver.log >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # storage >> %CONFIGFILE%
echo #   Lagringsplats för de arkiverade webbplatserna. >> %CONFIGFILE%
echo #   Defaultvärde: Inget, måste anges. >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # temp >> %CONFIGFILE%
echo #   Lagringsplats för temporära filer. >> %CONFIGFILE%
echo #   Defaultvärde: C:\temp\dump >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # connections >> %CONFIGFILE%
echo #   Antal samtidiga anslutningar till webbservern. >> %CONFIGFILE%
echo #   Defaultvärde: 8 >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # connsPerSecond >> %CONFIGFILE%
echo #   Maximalt antal anslutningar/sekund. >> %CONFIGFILE%
echo #   Defaultvärde: 10 >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # Ex: >> %CONFIGFILE%
echo # HTTrackPath=C:\Program\WinHTTrack\httrack.exe >> %CONFIGFILE%
echo # sitefile=sites2.txt >> %CONFIGFILE%
echo # storage=C:\HTML-dumpar >> %CONFIGFILE%
echo # temp=C:\temp\dump >> %CONFIGFILE%
echo # connections=8 >> %CONFIGFILE%
echo # connsPerSecond=10 >> %CONFIGFILE%
echo # >> %CONFIGFILE%
echo # ===================================================================================================================== >> %CONFIGFILE%
echo sitefile=sites.txt >> %CONFIGFILE%
echo storage=C:\HTML-dumpar >> %CONFIGFILE%
echo temp=C:\temp\dump >> %CONFIGFILE%
echo connections=5 >> %CONFIGFILE%
echo connsPerSecond=7 >> %CONFIGFILE%
goto :eof

:createSiteFile
echo # ===================================================================================================================== > %SITEFILE%
echo # Siter som ska arkiveras. >> %SITEFILE%
echo # >> %SITEFILE%
echo # Rader som inleds med # räknas som kommentarer, och bortses ifrån. >> %SITEFILE%
echo # >> %SITEFILE%
echo # Raderna i denna fil ska vara på formen sitenamn url filter. >> %SITEFILE%
echo # Sitenamnet används i sökvägen där filerna sparas, url är sitens startplats, och filter används för vissa specialfall. >> %SITEFILE%
echo # För information om filter, se dokumentationen för filter i HTTrack. >> %SITEFILE%
echo # ===================================================================================================================== >> %SITEFILE%
echo example.com example.com >> %SITEFILE%
