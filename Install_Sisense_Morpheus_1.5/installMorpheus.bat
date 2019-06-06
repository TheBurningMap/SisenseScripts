echo off
set morpheus_installer_dir=%1
set username=%2
set password=%3
set website_port=%4
set dashboard_port=11443
set morpheus_install_dir=C:\morpheus_1_5
set sisense_install_dir="C:\Program Files\Sisense"

IF NOT defined website_port set website_port=8083

echo username: %username%
echo password: %password%
echo website_port: %website_port%

echo Preparing config_input.txt

REM getAccessToken.ps1 will generate access token
REM arg1: Sisense_rest_username
REM arg2: Sisense_rest_password
REM arg3: website_port (default: 8083 port)
powershell -f getAccessToken.ps1 %username% %password% %website_port% >temp.txt
set /p access_token=<temp.txt
echo access_token : %access_token% 

REM getSharedSecret.ps1 will generate sharedSecret
REM arg1: access_token
REM arg2: website_port (default: 8083 port)
powershell -f getSharedSecret.ps1 %access_token% %website_port% >temp.txt
set /p sharedSecret=<temp.txt
echo sharedSecret : %sharedSecret%

echo {"dashboard": > Welcome.dash
type WelcomeScreenOfficial.dash >> Welcome.dash
echo. >> Welcome.dash
echo } >> Welcome.dash

REM importDashboard.ps1 will import dashboard to Sisense Console
REM arg1: access_token 
REM arg2: website_port (default: 8083 port) 
REM arg3: dashboard file to import 
powershell -f importDashboard.ps1 %access_token% %website_port% Welcome.dash >temp.txt
set /p dashboardID=<temp.txt
echo dashboardID : %dashboardID%
del Welcome.dash

REM Get everyone group ID
REM arg1: access_token 
REM arg2: website_port (default: 8083 port) 
powershell -f getEveryoneGroupID.ps1 %access_token% %website_port% >temp.txt
set /p group_Id=<temp.txt
echo group_Id : %group_Id%

REM Preparing json template to publish 'Welcome Screen Offical' dashboard to 'everyone'
copy /y publishGroup_template.json publishGroup.json
powershell -f prepareConfig_input.ps1 "#group_Id#" %group_Id% publishGroup.json

REM Publish welcome dashboard to everyone
REM arg1: access_token 
REM arg2: website_port (default: 8083 port)
REM arg3: dashboardID
REM arg4: ShareFile
powershell -f publishGroup.ps1 %access_token% %website_port% %dashboardID% publishGroup.json >temp.txt
del publishGroup.json

REM Get Domain_Name
powershell -f getHostname.ps1 >temp.txt
set /p host_name=<temp.txt
echo domain_name : %host_name%

REM Get CertificateThumbprint
powershell -f getCertThumbprint.ps1 >temp.txt
set /p cert_thumbprint=<temp.txt
echo cert_thumbprint : %cert_thumbprint%
del temp.txt

REM updateSSO.ps1 will update SSO fileds
REM arg1: access_token
REM arg2: website_port (default: 8083 port)
REM arg3: sso file
copy /y updateSSO_template.json updateSSO.json
powershell -f prepareConfig_input.ps1 "#host_name#" %host_name% updateSSO.json
powershell -f prepareConfig_input.ps1 "#dashboard_port#" %dashboard_port% updateSSO.json
powershell -f updateSSO.ps1 %access_token% %website_port% updateSSO.json
del updateSSO.json

copy /y config_input_template.txt config_input.txt
powershell -f prepareConfig_input.ps1 config_input.txt "#morpheus_install_dir#" %morpheus_install_dir% 
powershell -f prepareConfig_input.ps1 config_input.txt "#host_name#" %host_name%
powershell -f prepareConfig_input.ps1 config_input.txt "#dashboard_port#" %dashboard_port%
powershell -f prepareConfig_input.ps1 config_input.txt "#username#" %username%
powershell -f prepareConfig_input.ps1 config_input.txt "#password#" %password%
powershell -f prepareConfig_input.ps1 config_input.txt "#sharedSecret#" %sharedSecret%
powershell -f prepareConfig_input.ps1 config_input.txt "#dashboardID#" %dashboardID%
powershell -f prepareConfig_input.ps1 config_input.txt "#sisense_install_dir#" %sisense_install_dir%
powershell -f prepareConfig_input.ps1 config_input.txt "#cert_thumbprint#" %cert_thumbprint%

move config_input.txt %morpheus_installer_dir%

echo config_input.txt is ready and placed in %morpheus_installer_dir% location.
REM %morpheus_installer_dir%\installer.bat
REM if %errorlevel% neq 0 ( echo "Error: failed to install Morpheus" && exit /b %errorlevel% )
