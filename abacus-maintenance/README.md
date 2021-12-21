# Abacus Service Maintenance

This PowerShell script can be used to manage the Abacus services.

Four different batch scripts are available for running the application. These batch scripts can be added to the task scheduler to automate various tasks.

```batch
start ./AbacusServiceInfo.bat
start ./AbacusServicesStart.bat
start ./AbacusServicesStop.bat
start ./AbacusServiceMaintenance.bat
```

## AbacusServiceInfo.bat
This script can be used to get all Abacus services installed on the current server. The services found on the server are displayed in a table with the corresponding node and status.

This script has no effect on the status of individual services.

## AbacusServicesStart.bat
This script starts all Abacus services on the server if they are not already started. Finally, the status of all services are displayed in a table if the script was not executed via task scheduling.

## AbacusServiceStop.bat
This script stops all Abacus services on the server if they are not already stopped. Finally, the status of all services are displayed in a table if the script was not executed via task scheduling.

## AbacusServiceMaintenance.bat
This script stops all Abacus services on the server and starts them again after a timeout of 5 seconds. Finally, the status of all services are displayed in a table if the script was not executed via task scheduling.


# Changelog

## Version 1.0.0 - 21. Dec. 2021
### Added
- Application tested and released