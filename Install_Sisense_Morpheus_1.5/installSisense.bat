echo off
set sisense_installer=%1
set username=%2
set password=%3
set website_name=%4
set website_port=%5
set sisenseDataDir=C:\ProgramData\Sisense

IF NOT defined website_name set website_name=SisenseWeb
IF NOT defined website_port set website_port=8083

echo sisense_installer: %sisense_installer%
echo username: %username%
echo password: %password%
echo website_name: %website_name%
echo website_port: %website_port%

IF not exist %sisenseDataDir% mkdir %sisenseDataDir%

del C:\Temp\PrismFeature.xml
bitsadmin.exe /transfer "Download PrismFeature.xml" http://download.sisense.com/PrismInstallations/PrismExtensions/PrismIIS/PrismFeature.xml C:\Temp\PrismFeature.xml
if %errorlevel% neq 0 ( echo "Error: failed to download PrismFeture.xml" && exit /b %errorlevel% )

IF exist %sisenseDataDir%\PrismFeature.xml move %sisenseDataDir%\PrismFeature.xml %sisenseDataDir%\PrismFeature.xml.bak
move C:\Temp\PrismFeature.xml %sisenseDataDir%\PrismFeature.xml

echo %sisense_installer% -username=%username% -password=%password% -webname=%website_name% -webport=%website_port%
%sisense_installer% -q -username=%username% -password=%password% -webname=%website_name% -webport=%website_port%

if %errorlevel% neq 0 ( echo "Error: failed to install SiSense" && exit /b %errorlevel% )

echo Sisense installation completed successfully..

start chrome http://localhost:%website_port%






























REM echo off
REM set sisense_installer=%1
REM set username=%2
REM set password=%3
REM set website_name=%4
REM set website_port=%5
REM set sisenseDataDir=C:\ProgramData\Sisense

REM IF NOT defined website_name set website_name=SisenseWeb
REM IF NOT defined website_port set website_port=8083

REM echo sisense_installer: %sisense_installer%
REM echo username: %username%
REM echo password: %password%
REM echo website_name: %website_name%
REM echo website_port: %website_port%

REM REM IF not exist %sisenseDataDir% mkdir %sisenseDataDir%

REM REM del C:\Temp\PrismFeature.xml
REM REM bitsadmin.exe /transfer "Download PrismFeature.xml" http://download.sisense.com/PrismInstallations/PrismExtensions/PrismIIS/PrismFeature.xml C:\Temp\PrismFeature.xml
REM REM if %errorlevel% neq 0 ( echo "Error: failed to download PrismFeture.xml" && exit /b %errorlevel% )

REM REM IF exist %sisenseDataDir%\PrismFeature.xml move %sisenseDataDir%\PrismFeature.xml %sisenseDataDir%\PrismFeature.xml.bak
REM REM move C:\Temp\PrismFeature.xml %sisenseDataDir%\PrismFeature.xml

REM echo %sisense_installer% -username=%username% -password=%password% -webname=%website_name% -webport=%website_port%
REM %sisense_installer% -q -username=%username% -password=%password% -webname=%website_name% -webport=%website_port%

REM if %errorlevel% neq 0 ( echo "Error: failed to install SiSense" && exit /b %errorlevel% )

REM echo Sisense installation completed successfully saiDOCKER ..

REM REM start chrome http://localhost:%website_port%







