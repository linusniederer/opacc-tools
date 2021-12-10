# OpaccServiceScript
# Korrekter Start/Stop der Opacc-Services
#
# @author:  Linus Niederer
# @changes: 19.10.2021
# 


# Start Parameter
# START, STOP, RESTART

Param( $action )
if( $action -ne $null ) { $action = $action.ToLower() }


class OpaccServices {

    [bool] $writeLog            = $true # Change to log information
    [String] $opaccInstallationXML

    # Array to Store Nodes and Services
    [array] $serviceBusNodes    = @()
    [array] $serviceBusServices = @()

    # Regex patterns to declaire service types
    [string] $regexService      = "Opacc[.]{1}.*[.]{1}(Service[:]{1}|Services[.]Warehouse|Services[.]{1}Service[.]{1}Host)"
    [string] $regexAgent        = "Opacc[.]{1}.*[.]{1}(?=Agent[:]{1})"
    [string] $regexServiceBus   = "Opacc[.]{1}ServiceBus[.]{1}App"
    # [string] $regexFrontend     = "Opacc[.]{1}OxasFrontend[.]{1}WebApp"
    [string] $regexFrontend     = "Opacc[.]OxasFrontend"

    # Array of service types
    [array] $serviceTypes       = @("Service", "Frontend", "Agent", "ServiceBus")

    [array] $startSequence      = @("Frontend", "ServiceBus", "Service", "Agent")
    [array] $stopSequence       = @("Agent", "Service", "ServiceBus", "Frontend")
    

    # Constructor of Class
    OpaccServices() {
        if( $this.checkScriptPath() ) {
            $this.getServiceBusNodes()
            $this.getOpaccServices()
        }
    }

    # Method to change Script Path
    hidden [bool] checkScriptPath() {
        $currentPath = Get-Location
        
        if( $currentpath -match "IP\\sys") {
            $path = $currentPath -split "\\Insyde\\"
            $this.opaccInstallationXML = "$($path[0])\Insyde\OpaccOneInstallation.xml"
        } else {
            if( $this.opaccInstallationXML -ne $null ) {
                return $true
            } else {
                # OpaccOneInstallation.xml Path not found!
                $this.toString("Error: OpaccOneInstallation.xml not found!")
                return $false
            }
        }

        return $true;
    }

    # Method to get ServiceBusNodes from OpaccOneInstallation.xml
    hidden [void] getServiceBusNodes() {
        $xml = New-Object System.XML.XMLDocument
        $xml.Load( $this.opaccInstallationXML )
        $this.serviceBusNodes.Clear()
        
        foreach( $xmlValue in $xml.Configuration.Installation.ServiceBusCluster ) {
            $serviceBusNodeName = $xmlValue.ServiceBusNode.Name
            $serviceBusNodeDNS  = $xmlValue.ServiceBusNode.InternalIpAddressOrHostName

            if($serviceBusNodeName -ne 'localhost') {
                if(-Not $this.isDuplicated( $this.serviceBusNodes, $serviceBusNodeName )) {
                    $nodeObject = New-Object -TypeName psobject
                    $nodeObject | Add-Member -MemberType NoteProperty -Name Name -Value $serviceBusNodeName
                    $nodeObject | Add-Member -MemberType NoteProperty -Name DNS -Value $serviceBusNodeDNS
        
                    $this.serviceBusNodes += $nodeObject        
                }
            }
        }

        $this.toString('Found the following nodes:')
        $this.ToString( $this.serviceBusNodes.Name )
    }

    # Method to get OpaccServices from ServiceBusNodes
    [void] getOpaccServices() {

        $this.toString('Found the following services:')
        $this.serviceBusServices.Clear()

        foreach( $serviceBusNode in $this.serviceBusNodes.DNS ) {
            
            $services = Get-Service -ComputerName $serviceBusNode | Where-Object { $_.Name -match 'Opacc.' }

            foreach( $service in $services ) {
                if( -Not $this.isDuplicated( $this.serviceBusServices, $service.Name )) {
                    
                    switch -Regex ($service.Name) {
                        $this.regexService    { $this.addServiceObject($service, $serviceBusNode, "Service") }
                        $this.regexAgent      { $this.addServiceObject($service, $serviceBusNode, "Agent") }
                        $this.regexFrontend   { $this.addServiceObject($service, $serviceBusNode, "Frontend") }
                        $this.regexServiceBus { $this.addServiceObject($service, $serviceBusNode, "ServiceBus") }
                    }

                }
            }
        }                    
    }

    # Method to start OpaccServices on ServiceBusNodes
    [void] startOpaccServices() {

        $this.toString('Starting services on all nodes...')

        foreach($serviceType in $this.startSequence) {

            $services = $this.serviceBusServices | Where-Object { $_.Type -eq $serviceType }
            $this.toString("Starting service type [$serviceType]")

            # services starten
            foreach ($service in $services) {
                Start-Job -Name $service.Name -scriptblock { 
                    param($serviceBusNode, $serviceName)     
                    Start-Service -InputObject $(get-service -ComputerName $serviceBusNode -Name $serviceName)
                } -Argumentlist $service.ServiceBus, $service.Name
            }

            # wait for all jobs to be finished
            Get-Job | Wait-Job -Timeout 30
        }  

        $this.getOpaccServices()
    }

    # Method to stop OpaccServices on ServiceBusNodes
    [void] stopOpaccServices() {

        $this.toString('Stoping services on all nodes...')

        foreach($serviceType in $this.stopSequence) {

            $services = $this.serviceBusServices | Where-Object { $_.Type -eq $serviceType }
            $this.toString("Stoping service type [$serviceType]")

            # services starten
            foreach ($service in $services) {
                Start-Job -Name $service.Name -scriptblock { 
                    param($serviceBusNode, $serviceName)     
                    Stop-Service -InputObject $(get-service -ComputerName $serviceBusNode -Name $serviceName)
                } -Argumentlist $service.ServiceBus, $service.Name
            }

            # wait for all jobs to be finished
            Get-Job | Wait-Job -Timeout 30
        }  

        $this.getOpaccServices()
    }

    # Method to restart OpaccServices on ServiceBusNodes
    [void] restartOpaccServices() {
        $this.stopOpaccServices()
        Start-Sleep -s 5
        $this.startOpaccServices()
    }

    # Method to add data to serviceObject
    hidden [void] addServiceObject($service, $serviceBusNode, $serviceType) {
        $serviceObject = New-Object -TypeName psobject

        $serviceObject | Add-Member -MemberType NoteProperty -Name ServiceBus -Value $serviceBusNode
        $serviceObject | Add-Member -MemberType NoteProperty -Name Name -Value $service.Name
        $serviceObject | Add-Member -MemberType NoteProperty -Name Type -Value $serviceType
        $serviceObject | Add-Member -MemberType NoteProperty -Name Status -Value $service.Status
        
        $this.serviceBusServices += $serviceObject
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
            if (!(Test-Path "./log/OpaccServiceMaintenance.log")) {
                New-Item -path "./log/OpaccServiceMaintenance.log" -value "$timestamp #> $message" -Force
            } else {
                Add-Content -Path './log/OpaccServiceMaintenance.log' -Value "$timestamp #> $message"
            }
        }
    }
}

# Call to static property
$OpaccServices = [OpaccServices]::new()

switch($action) {
    'start'     { $OpaccServices.startOpaccServices() }
    'stop'      { $OpaccServices.stopOpaccServices() }
    'restart'   { $OpaccServices.restartOpaccServices() }
}

Clear-Host

# Show all services and their status
$OpaccServices.serviceBusServices | Sort-Object -Property Type, Status, Name, Node | Format-Table
$OpaccServices.serviceBusNodes
