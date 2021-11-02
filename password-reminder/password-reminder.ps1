# Active Directory Password Reminder
#
# @author:  https://github.com/linusniederer
# @changes: 22.10.2021
# 

Class PasswordReminder {

    # Password guidelines
    [int] $maxPasswordAge   = 180 
    [int] $warnLevel1       = 15
    [int] $warnLevel2       = 5
    [int] $warnLevel3       = 1

    # Email configuration
    [string] $smtpServer    = "owa.opacc.ch"
    [string] $mailFrom      = "passwordreminder@opacc.ch"
    [string] $mailSubject   = "Dein Passwort f��r die Dom�ne opacc.local l�uft bald ab!"
    [string] $mailTemplate  = "C:\Admin\Scripts\opacc-tools\password-reminder\template.html"


    # Constructor of class
    PasswordReminer() {
       # nothing to do here
    }

    # Fuction to get all ADUsers on Active Directory
    [void] checkUserPasswords() {
        
        $adUsers = Get-ADUser "linusniederer" -Properties DisplayName,PasswordLastSet,mail

        foreach( $adUser in $adUsers ) {

            $today = Get-Date 
            $passwordExpireDate = $adUser.PasswordLastSet.AddDays( + $this.maxPasswordAge )
            $daysBeforePWchange = ($passwordExpireDate - $today).Days

            if ( $daysBeforePWchange -eq $this.warnLevel1 -or $daysBeforePWchange -eq $this.warnLevel2 -or $daysBeforePWchange -eq $this.warnLevel3 -or $daysBeforePWchange -lt $this.warnLevel3 ) {

                <# Send mail if:
                #   days before change are equal to one of the warning levels
                #   days before change are lower than the warning level 3
                #>
                $passwordExpireDate = $passwordExpireDate.toString("dd.MM.yyyy")
                $mailBody = $this.createMail($adUser.DisplayName, $passwordExpireDate, $daysBeforePWchange)
                $this.sendMail($adUser.mail, $mailBody)
            }                           
        }
    }

    # Function to send password expiring email
    [void] sendMail($mailAddress, $mailBody) {
        Send-MailMessage -SmtpServer $this.smtpServer -To $mailAddress -From $this.mailFrom -Body $mailBody -BodyAsHtml -Subject $this.mailSubject -encoding ([System.Text.Encoding]::UTF8)
    }

    # Function to create mail template
    [string] createMail($displayName, $expireDate, $expireDays ) {

        $template = Get-Content -Path $this.mailTemplate
        return $template.Replace("[USERNAME]", $displayName).Replace("[DATE]", $expireDate).Replace("[DAYS]", $expireDays)
    }
}

# Run Script
$passwordReminder = [PasswordReminder]::new()
$passwordReminder.checkUserPasswords()
