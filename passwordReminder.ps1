# Active Directory Password Reminder
#
# @author:  https://github.com/linusniederer
# @changes: 22.10.2021
# 

Class PasswordReminder {

    # Active Directory Configuration
    $activeDirectory        = ""

    # Password guidelines
    [int] $maxPasswordAge   = 360 
    [int] $warnLevel1       = 15
    [int] $warnLevel2       = 5
    [int] $warnLevel3       = 1

    # Email configuration
    [string] $smtpServer    = "owa.opacc.ch"
    [string] $mailFrom      = "passwordreminder@opacc.ch"
    [string] $mailSubject   = "Dein Passwort für die Domäne opacc.local läuft bald ab!"


    # Constructor of class
    PasswordReminer() {
       # nothing to do here
    }

    # Fuction to get all ADUsers on Active Directory
    [void] checkUserPasswords() {
        
        $adUsers = Get-ADUser "linusniederer" -Properties DisplayName,PasswordLastSet,mail

        $today = Get-Date 
        $passwordExpireDate = $adUsers.PasswordLastSet.AddDays( + $this.maxPasswordAge )
        $daysBeforePWchange = ($passwordExpireDate - $today).Days

        if ( $daysBeforePWchange -eq $this.warnLevel1 -or $daysBeforePWchange -eq $this.warnLevel2 -or $daysBeforePWchange -eq $this.warnLevel3 -or $daysBeforePWchange -lt $this.warnLevel3 ) {

           <# Send mail if:
            #   days before change are equal to one of the warning levels
            #   days before change are lower than the warning level 3
            #>
            $passwordExpireDate = $passwordExpireDate.toString("dd.MM.yyyy")
            $mailBody = $this.mailTemplate($adUsers.DisplayName, $passwordExpireDate, $daysBeforePWchange)
            $this.sendMail($adUsers.mail, $mailBody)
        } 
    }

    # Function to send password expiring email
    [void] sendMail($mailAddress, $mailBody) {
        Send-MailMessage -SmtpServer $this.smtpServer -To $mailAddress -From $this.mailFrom -Body $mailBody -BodyAsHtml -Subject $this.mailSubject -encoding ([System.Text.Encoding]::UTF8)
    }

    # Function to create mail template
    [string] mailTemplate($displayName, $expireDate, $expireDays ) {
        $mailHTML = "
            <html>
                <head>
                </head>
                <body>
                    Hallo $displayName,
                    <br>
                    Dein Windows-Passwort läuft am $expireDate ab.
                    <br>
                    Du hast $expireDays Tage bis dein Passwort abläuft. Bitte ändere es rechtzeitig.
                    <br>
                    Freundliche Grüsse
                    <br>
                    Opacc Systemtechnik
                </body>
            </html>
        "
       return $mailHTML
    }
}

# Run Script
$passwordReminder = [PasswordReminder]::new()
$passwordReminder.checkUserPasswords()
