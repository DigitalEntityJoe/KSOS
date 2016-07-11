@ECHO OFF

IF EXIST "C:\Program Files (x86)\Kaspersky Lab\Kaspersky Small Office Security 15.0.2" GOTO eof
IF EXIST "C:\Program Files\Kaspersky Lab\Kaspersky Small Office Security 15.0.2" GOTO eof

xcopy "\\SERVERNAME\KSOS\KSOSINSTALL" C:\KSOSInstall\

C:\KSOSInstall\KSOSEmailAV.cmd

exit
