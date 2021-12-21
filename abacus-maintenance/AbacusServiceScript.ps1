# Abacus Service Maintenance
#
# @author:  Linus Niederer
# @created: 21.12.2021
#
# changelog: https://github.com/linusniederer/opacc-tools/tree/main/abacus-maintenance#changelog
# 

# Parameter
# START, STOP, RESTART

Param( $action )
if( $action -ne $null ) { $action = $action.ToLower() }


class AbacusServices {

    [bool] $writeLog            = $false # Change to write log information

    # Array to services
    [array] $serverServices = @()

    # Regex patterns to declaire service types
    [string] $regexCTree        = "ABACUS CTree Server"
    [string] $regexWarehouse    = "AbaDataWarehouse"
    [string] $regexEngine       = "AbaEngine"
    [string] $regexMetrics      = "AbaMetricsService"
    [string] $regexMonitor      = "AbaMonitorService"
    [string] $regexWrap         = "AbaWrapService"

    # Array of service types
    [array] $serviceTypes       = @("Wrap", "Engine", "Warehouse", "Metrics", "Monitor", "CTree")

    [array] $startSequence      = @("CTree", "Engine", "Warehouse", "Metrics", "Monitor", "Wrap")
    [array] $stopSequence       = @("Wrap", "Engine", "Warehouse", "Metrics", "Monitor", "CTree")
    

    # Constructor of Class
    AbacusServices() {
        $this.getAbacusServices()
    }

    # Method to get AbacusServices from server
    [void] getAbacusServices() {

        $this.toString('Found the following services:')
        $this.serverServices.Clear()

        $services = Get-Service

        foreach( $service in $services ) {
            if( -Not $this.isDuplicated( $this.serverServices, $service.Name )) {
                switch -Regex ($service.Name) {
                    $this.regexCTree        { $this.addServiceObject($service, "CTree") }
                    $this.regexWarehouse    { $this.addServiceObject($service, "Warehouse") }
                    $this.regexEngine       { $this.addServiceObject($service, "Engine") }
                    $this.regexMetrics      { $this.addServiceObject($service, "Metrics") }
                    $this.regexMonitor      { $this.addServiceObject($service, "Monitor") }
                    $this.regexWrap         { $this.addServiceObject($service, "Wrap") }
                }
            }
        }
               
    }

    # Method to start AbacusServices on server
    [void] startAbacusServices() {

        $this.toString('Starting services on server ...')

        foreach($serviceType in $this.startSequence) {

            $services = $this.serverServices | Where-Object { $_.Type -eq $serviceType }
            $this.toString("Starting service type [$serviceType]")

            # services start
            foreach ($service in $services) {
                Start-Job -Name $service.Name -scriptblock { 
                    param($serviceName)     
                    Start-Service -InputObject $(get-service -Name $serviceName)
                } -Argumentlist $service.Name
            }

            # wait for all jobs to be finished
            Get-Job | Wait-Job -Timeout 30
        }  

        $this.getAbacusServices()
    }

    # Method to stop AbacusServices on server
    [void] stopAbacusServices() {

        $this.toString('Stoping services on all nodes...')

        foreach($serviceType in $this.stopSequence) {

            $services = $this.serverServices | Where-Object { $_.Type -eq $serviceType }
            $this.toString("Stoping service type [$serviceType]")

            # services stop
            foreach ($service in $services) {
                Start-Job -Name $service.Name -scriptblock { 
                    param($serviceName)      
                    Stop-Service -InputObject $(get-service -Name $serviceName)
                } -Argumentlist $service.Name
            }

            # wait for all jobs to be finished
            Get-Job | Wait-Job -Timeout 30
        }  

        $this.getAbacusServices()
    }

    # Method to restart AbacusServices on server
    [void] restartAbacusServices() {
        $this.stopAbacusServices()
        Start-Sleep -s 5
        $this.startAbacusServices()
    }

    # Method to add data to serviceObject
    hidden [void] addServiceObject($service, $serviceType) {
        $serviceObject = New-Object -TypeName psobject

        $serviceObject | Add-Member -MemberType NoteProperty -Name Name -Value $service.Name
        $serviceObject | Add-Member -MemberType NoteProperty -Name Type -Value $serviceType
        $serviceObject | Add-Member -MemberType NoteProperty -Name Status -Value $service.Status
        
        $this.serverServices += $serviceObject
    }

    # Method to find out whether ServiceBusNodes already exists
    hidden [bool] isDuplicated($object, $string) {
        foreach($row in $object.Name) {
            if($string -eq $row) {
                return $true
            }
        }

        return $false
    }

    # Override toString method
    hidden [void] toString($message) {
        $timestamp = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
        
        # define color filter
        if($message -like '*error*') { Write-Host -ForegroundColor 'Red' "$timestamp #> $message" }
        elseIf($message -like '*success*') { Write-Host -ForegroundColor 'Green' "$timestamp #> $message" }
        elseIf($message -like '*warning*') { Write-Host -ForegroundColor 'Yellow' "$timestamp #> $message" }
        else { Write-Host "$timestamp #> $message" }

        # write log if defined
        if($this.writeLog) {
            if (!(Test-Path "./log/AbacusServiceMaintenance.log")) {
                New-Item -path "./log/AbacusServiceMaintenance.log" -value "$timestamp #> $message" -Force
            } else {
                Add-Content -Path './log/AbacusServiceMaintenance.log' -Value "$timestamp #> $message"
            }
        }
    }
}

# Call to static property
$AbacusServices = [AbacusServices]::new()

switch($action) {
    'start'     { $AbacusServices.startAbacusServices() }
    'stop'      { $AbacusServices.stopAbacusServices() }
    'restart'   { $AbacusServices.restartAbacusServices() }
}

Clear-Host

# Show all services and their status
$AbacusServices.serverServices | Sort-Object -Property Type, Status, Name, Node | Format-Table
