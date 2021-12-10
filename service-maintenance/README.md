# OpaccERP Service Maintenance

This PowerShell script can be used to manage the services on the OpaccERP across multiple servers.

Four different batch scripts are available for running the application. These batch scripts can be added to the task scheduler to automate various tasks.

```batch
start ./OpaccServiceInfo.bat
start ./OpaccServiceMaintenance.bat
start ./OpaccServicesStart.bat
start ./OpaccServicesStop.bat
```

# Changelog

## Version 1.0.1 - 10. Dec. 2021
### Added
- Adding SimpleIndex service support

## Version 1.0.0 - 19. Oct. 2021
### Added
- Application tested and released