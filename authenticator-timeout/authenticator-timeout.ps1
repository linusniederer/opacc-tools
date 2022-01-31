# Timeout for Sophos Client Authenticator
#
# @author:  https://github.com/linusniederer
# @changes: 13.12.2021
# 

Class Authenticator {

    # Config
    [string] $timeoutTime   = "22:00"
    [string] $processName   = "CAA"
    
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

        if( $process -ne $NULL -and  (Get-Date -Format "HH:mm") -eq $this.timeoutTime ) {
            Write-EventLog -LogName "Application" -Source "ClientAuthenticatorTimeout" -EventID 10 -Message "Kill process with ID $($process.ID)" -EntryType Information
            $this.killProcess( $process.ID )
            Write-EventLog -LogName "Application" -Source "ClientAuthenticatorTimeout" -EventID 10 -Message "Killed process with ID $($process.ID)" -EntryType Warning
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