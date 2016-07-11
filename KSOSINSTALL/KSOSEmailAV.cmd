::@ECHO OFF

::----------------------------------------------::
:: CHECKING TO SEE IF KSOS IS ALREADY INSTALLED ::
::----------------------------------------------::

IF EXIST "C:\Program Files (x86)\Kaspersky Lab\Kaspersky Small Office Security 15.0.2" GOTO GOTIT
IF EXIST "C:\Program Files\Kaspersky Lab\Kaspersky Small Office Security 15.0.2" GOTO GOTIT

IF EXIST %~dp0KSOS_%COMPUTERNAME%.txt goto NORMRUN
IF NOT EXIST %~dp0KSOS_%COMPUTERNAME%.txt goto SKIP

:SKIP
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /d %~dpnx0 /f
echo INSTALLING >%~dp0KSOS_%COMPUTERNAME%.txt

::----------------------------------------------::
:: CHECKING TO SEE IF ADMIN PRIVLEDGES ARE USED ::
::----------------------------------------------::

:NORMRUN
CLS
echo We need Admin Rights, I'll Check that for you...

:checkPrivileges
NET FILE 1>NUL 2>NUL
if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
echo.
echo Nope, Not an Admin, I'll Fix that...
echo.
echo Click on Yes/OK if the UAC box pops up... thanks 

setlocal DisableDelayedExpansion
set "batchPath=%~0"
setlocal EnableDelayedExpansion
ECHO Set UAC = CreateObject^("Shell.Application"^) > "%temp%\OEgetPrivileges.vbs"
ECHO args = "ELEV " >> "%temp%\OEgetPrivileges.vbs"
ECHO For Each strArg in WScript.Arguments >> "%temp%\OEgetPrivileges.vbs"
ECHO args = args ^& strArg ^& " "  >> "%temp%\OEgetPrivileges.vbs"
ECHO Next >> "%temp%\OEgetPrivileges.vbs"
ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%temp%\OEgetPrivileges.vbs"
"%SystemRoot%\System32\WScript.exe" "%temp%\OEgetPrivileges.vbs" %*
exit /B

:gotPrivileges

if '%1'=='ELEV' shift /1
setlocal & pushd .
cd /d %~dp0

::ECHO Arguments: %1 %2 %3 %4 %5 %6 %7 %8 %9

::-----------------------------------------::
:: SETTINGS VARS FROM KSOSCONFIGS.TXT FILE ::
::-----------------------------------------::

:SETVARS
setlocal ENABLEDELAYEDEXPANSION
set vidx=0
for /F "tokens=*" %%A in (KSOSConfigs.txt) do (
    SET /A vidx=!vidx! + 1
    set Kvar!vidx!=%%A
)
::set var


::-----------------::
:: INSTALLING KSOS ::
::-----------------::

:KSOSINSTALL
ksos15.0.2.361abcen_8389.exe /s /pACTIVATIONCODE=%KVAR1% /pAGREETOEULA=1 /pSKIPPRODUCTCHECK=1 /pCREATE_DESKTOP_SHORTCUT=0 /pUSER_ID=%KVAR2% /pKLPASSWD=%KVAR4%

echo.
echo.

IF EXIST "C:\Program Files (x86)\Kaspersky Lab\Kaspersky Small Office Security 15.0.2" GOTO IMPORT64
IF EXIST "C:\Program Files\Kaspersky Lab\Kaspersky Small Office Security 15.0.2" GOTO IMPORT32

::----------------------------------::
:: IMPORTING PRECONFIGURED SETTINGS ::
::----------------------------------::

:IMPORT64
"C:\Program Files (x86)\Kaspersky Lab\Kaspersky Small Office Security 15.0.2\avp.com" password=ciao2
"C:\Program Files (x86)\Kaspersky Lab\Kaspersky Small Office Security 15.0.2\avp.com" IMPORT %~dp0KSOSImport.dat /password=ciao2
GOTO IMPORTDONE

:IMPORT32
"C:\Program Files\Kaspersky Lab\Kaspersky Small Office Security 15.0.2\avp.com" IMPORT %~dp0KSOSImport.dat
GOTO IMPORTDONE

:IMPORTDONE
IF EXIST "C:\Program Files (x86)\Kaspersky Lab\Kaspersky Small Office Security 15.0.2" GOTO OPENKSOS
IF EXIST "C:\Program Files\Kaspersky Lab\Kaspersky Small Office Security 15.0.2" GOTO OPENKSOS
IF NOT EXIST "C:\Program Files (x86)\Kaspersky Lab\Kaspersky Small Office Security 15.0.2" GOTO goto REBOOT

::------------::
::RUNNING KSOS::
::------------::

:OPENKSOS
echo All done. Now we are opening the Kaspersky Program

"C:\Program Files (x86)\Kaspersky Lab\Kaspersky Small Office Security 15.0.2\avpui.exe"
"C:\Program Files\Kaspersky Lab\Kaspersky Small Office Security 15.0.2\avpui.exe"

echo.
echo.

::--------------------------------::
::CHECKING ALL ANTIVIRUS INSTALLED::
::--------------------------------::

WMIC /OUTPUT:"AV_%COMPUTERNAME%.txt" /Node:localhost /Namespace:\\root\SecurityCenter2 Path AntiVirusProduct Get displayName 

type "AV_%COMPUTERNAME%.txt" | findstr /v displayName | findstr /v "Windows Defender" >"AVI-%COMPUTERNAME%.txt"

del "AV_%COMPUTERNAME%.txt"

SwithMail.exe /s /from "%COMPUTERNAME%@%USERDOMAIN%.com" /name "%COMPUTERNAME%" /server "mail.optonline.net" /p "25" /to "%KVAR3%" /rt "%COMPUTERNAME%@%USERDOMAIN%.com" /sub "%COMPUTERNAME% at %USERDOMAIN% installed KSOS existing AV is in Body" /btxt "%~dp0AVI-%COMPUTERNAME%.txt"

::-----------------::
::CLEANUP AND CLOSE::
::-----------------::

:CHECKREG
IF EXIST %~dp0KSOS_%COMPUTERNAME%.txt GOTO END
IF NOT EXIST %~dp0KSOS_%COMPUTERNAME%.txt GOTO ENDEND

:END
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /f
del %~dp0KSOS_%COMPUTERNAME%.txt
GOTO ENDEND

:GOTIT
ECHO ALREADY INSTALLED
GOTO ENDEND

:REBOOT
IF EXIST %~dp0KSOS_%COMPUTERNAME%.txt GOTO NOADD
IF NOT EXIST %~dp0KSOS_%COMPUTERNAME%.txt GOTO ADDREBOOT

:ADDREBOOT
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Run /v %~n0 /d %~dpnx0 /f
echo REBOOTING >%~dp0KSOS_%COMPUTERNAME%.txt
shutdown -r -t 0
GOTO ENDEND

:NOADD
shutdown -r -t 0
GOTO ENDEND

:ENDEND
EXIT