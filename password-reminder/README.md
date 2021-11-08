# Active Directory Password Reminder

This PowerShell script can be used to send automatic password reminder emails. The script can be used on any environment.

## PowerShell Module

To use the script, it is mandatory that the Active Directory PowerShell module is installed on the server. 
On servers running Active Directory, this module is installed by default.

On other servers the module can be installed with the following PowerShell command as administrator:

```powershell
Add-WindowsFeature RSAT-AD-PowerShell
```

## Adapt to the environment

Before the script can be used, some variables in the script must be changed. These are located on lines 9 to 22.

```powershell
# Password guidelines
[int] $maxPasswordAge   = 180 
[int] $warnLevel1       = 15
[int] $warnLevel2       = 5
[int] $warnLevel3       = 1

# Active Directory configuration
[array] $organizationalUnits = @("", "") # add organizational units here

# Email configuration
[string] $smtpServer    = "" # add smtp server here
[string] $mailFrom      = "" # add from address here
[string] $mailSubject   = "" # add mail subject here
[string] $mailTemplate  = "" # add path to html template here
```

## Generate task scheduling
The script should be added for use in task scheduling. The script should be executed via the batch file, because PowerShell scripts can cause problems in execution.
