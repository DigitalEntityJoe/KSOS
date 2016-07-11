You do not need to configure the CMD files at all.   

YOU MUST CONFIGURE THE KSOSConfigs.txt FILE FORE EACH COMPANY YOU ARE INSTALLING THIS FOR!!! 
This was ONLY created for KSOS Version 15.0.2 - if you have another version you will need to change the primary CMD

breakdown of the KSOSConfigs file are as follows.  Please keep in mind that there is no spaces at the end of a line and every line must only contain the following info. 

KSOSConfigs.txt = 
line 1= activation key
line 2= email address for console management (center.kaspersky.com)(MAY BE OVERWRITTEN BY IMPORT)
line 3= email address for notifications of installs 
line 4= password for KSOS (change settings/uninstall)
line 5= mail server THAT YOU OWN (port 25 is used)

If you want to import yourcustomized settings then you will need to export your settings and put this in the folder right next to this text doc. 
this file should be named KSOSImport.dat



How to use and run, 
1. edit the STARTKSOS with the server and folder that you have the KSOSINSTALL Folder.
2. save the STARTKSOS.CMD file and put it in a shared location like \\DC\SYSVOL\Scripts
3. add it to the startup script you run or however you want to deploy it automatically. 
4. edit the KSOSConfigs.txt file with all of your information. 
5. put ksos15.0.2.361abcen_8389.exe in the KSOSINSTALL Folder
6. DEPLOY!!!

Enjoy! 

-JW