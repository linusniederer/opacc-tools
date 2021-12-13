# Timeout for Sophos Client Authenticator
#
# @author:  https://github.com/linusniederer
# @changes: 13.12.2021
# 

Class Authenticator {

    # Config
    [int] $timeoutAfter     = 8   # timeout in hours
    [string] $processName   = "CAA"
    [bool] $autostart       = $true

    # Constructor of class
    Authenticator() {
        while( $true ) {
            $this.getProcess()
            Start-Sleep -s 60
        }
    }

    # Function to get process information
    [void] getProcess() {

        $process = Get-Process | Where-Object { $_.ProcessName -eq $this.processName }
        $startTime = $process.StartTime
        $currentTime = (Get-Date)

        $difference = New-TimeSpan -Start $startTime -End $currentTime

        if( $difference.Hours -gt 8 ) {
            Write-Host "Kill process with ID $($process.ID)"
            Stop-Process -Id $process.Id

        } else {
            Write-Host "Nothing to do process is running for $difference"
        }
    }
}



# Run Script
$authenticator = [Authenticator]::new()
