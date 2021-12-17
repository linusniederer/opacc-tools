# Timeout for Sophos Client Authenticator
#
# @author:  https://github.com/linusniederer
# @changes: 13.12.2021
# 

Class Authenticator {

    # Config
    [int] $timeoutAfter     = 1   # timeout in hours
    [string] $processName   = "CAA"
    
    [string] $killTitle     = "Sophos Client Authenticator Timeout"
    [string] $killMSG       = "Der Client Authenticator wurde aufgrund der Dauer beendet!"

    # Constructor of class
    Authenticator() {
        while( $true ) {
            $this.getProcess()
            Start-Sleep -s 30
        }
    }

    # Function to get process information
    [void] getProcess() {

        $process = Get-Process | Where-Object { $_.ProcessName -eq $this.processName }

        if( $process -ne $NULL ) {
            $startTime = $process.StartTime
            $currentTime = (Get-Date)

            $difference = New-TimeSpan -Start $startTime -End $currentTime

            if( $difference.Minutes -ge $this.timeoutAfter ) {
                Write-Host "Kill process with ID $($process.ID)"
                $this.killProcess( $process.ID )
            }
        }
    }

    # Function to kill proceess
    [void] killProcess( $id ) {
        Stop-Process -Id $id
    }
}

# Run Script as Windows Service
function Main() {
    $authenticator = [Authenticator]::new()
}