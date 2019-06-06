echo off
set sisense_installer=%1
set username=%2
set password=%3
set morpheus_installer_dir=%4
set website_name=%5
set website_port=%6

IF NOT defined website_name set website_name=SisenseWeb
IF NOT defined website_port set website_port=8083

echo sisense_installer: %sisense_installer%
echo username: %username%
echo password: %password%
echo website_name: %website_name%
echo website_port: %website_port%

call installSisense.bat %sisense_installer% %username% %password% %website_name% %website_port%

call installMorpheus.bat %morpheus_installer_dir% %username% %password% %website_port%