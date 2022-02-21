# OpaccERP Service Maintenance

This PowerShell script can be used to manage the services on the OpaccERP across multiple servers.

Four different batch scripts are available for running the application. These batch scripts can be added to the task scheduler to automate various tasks.

```batch
start ./OpaccServiceInfo.bat
start ./OpaccServicesStart.bat
start ./OpaccServicesStop.bat
start ./OpaccServiceMaintenance.bat
```

## OpaccServiceInfo.bat
This script can be used to get all services on the different ServiceBusNodes. The services found on the different ServiceBusNodes are displayed in a table with the corresponding node and status.

This script has no effect on the status of individual services.

## OpaccServicesStart.bat
This script starts all services on all nodes if they are not already started. Finally, the status of all services are displayed in a table if the script was not executed via task scheduling.

## OpaccServiceStop.bat
This script stops all services on all nodes if they are not already stopped. Finally, the status of all services are displayed in a table if the script was not executed via task scheduling.

## OpaccServiceMaintenance.bat
This script stops all services on all nodes and starts them again after a timeout of 5 seconds. Finally, the status of all services are displayed in a table if the script was not executed via task scheduling.


# Changelog

## Version 1.0.2 - 21. Feb. 2022
- Adapt regex pattern for Opacc.B2B.Messenger to agent regex filter
- Deactivate parallel starts for ServiceBus types

## Version 1.0.1 - 04. Feb. 2022
- Adapt regex pattern for Mof.Services.Whis to services regex filter

## Version 1.0.0 - 19. Oct. 2021
- Application tested and released