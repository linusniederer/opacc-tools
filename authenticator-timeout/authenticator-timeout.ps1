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

    [bool] $isRunning


    # Constructor of class
    Authenticator() {
        # nothing to do here
    }

    # Function to get process information
    [void] getProcess() {




    }



}



# Run Script
$authenticator = [Authenticator]::new()
