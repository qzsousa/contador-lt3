@echo off

set SNMP=C:\coletar-lt3\backend\snmpget.exe
set OID=1.3.6.1.2.1.43.10.2.1.4.1.1
set ARQ=C:\Impressoras\contador.txt

:: DATA E HORA LIMPA
for /f "tokens=1,2 delims= " %%a in ("%date% %time%") do (
    set DATA=%%a
    set HORA=%%b
)
set HORA=%HORA:~0,5%

:: IMP1
for /f "tokens=2 delims==" %%a in ('%SNMP% -v:2c -c:public -r:10.180.176.26 -o:%OID% ^| find "Value"') do (
    echo IMP1 %DATA% %HORA% %%a >> %ARQ%
)

:: IMP2
for /f "tokens=2 delims==" %%a in ('%SNMP% -v:2c -c:public -r:10.180.176.25 -o:%OID% ^| find "Value"') do (
    echo IMP2 %DATA% %HORA% %%a >> %ARQ%
)

:: IMP3
for /f "tokens=2 delims==" %%a in ('%SNMP% -v:2c -c:public -r:10.180.176.28 -o:%OID% ^| find "Value"') do (
    echo IMP3 %DATA% %HORA% %%a >> %ARQ%
)

:: IMP4
for /f "tokens=2 delims==" %%a in ('%SNMP% -v:2c -c:public -r:10.180.176.24 -o:%OID% ^| find "Value"') do (
    echo IMP4 %DATA% %HORA% %%a >> %ARQ%
)
