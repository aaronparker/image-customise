---
title: Logging
summary:
authors:
    - Aaron Parker
---
Windows Enterprise Defaults logs actions to the following locations:

* The default log file path is: `C:\Windows\Logs\image-customise\WindowsEnterpriseDefaults.log`
* If the target device is enrolled into Microsoft Intune, the log file path will instead be: `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\WindowsEnterpriseDefaults.log`

Data is logged in Configuration Manager format, so it can be viewed with the Support Center Log File Viewer from the Configuration Manager Support Center tools:

[![Viewing the log file in the Microsoft Support Center log viewer](assets/img/logs.png)](assets/img/logs.png)
