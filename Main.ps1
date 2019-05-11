#EDIT THESE VALUES

#[REQUIRED]
#Where is your script file (.PS1) located?
$scriptFile = "C:\GitHub\Get-O365DirSyncElapsed\Get-O365DirSyncElapsed.ps1"

#[REQUIRED]
#Threshold in hours (eg. 1, 1.5, 2.00)
$threshold = 1

#[OPTIONAL]
#Where do we put the transcript log?
$logDirectory = "C:\GitHub\Get-O365DirSyncElapsed\Log"

#[REQUIRED]
#Which XML file contains your Office 365 Login?
#If you don't have this yet, run this: Get-Credential | Export-CliXML <file.xml>
$credentialFile = "C:\GitHub\Get-O365DirSyncElapsed\myCredential.xml"

#======================================
#start EMAIL SECTION
#======================================

#[REQUIRED]
#If we will send the email summary, what is the sender email address we should use?
#This must be a valid, existing mailbox and address in Office 365
#The account you use for the Credential File must have "Send As" permission on this mailbox
$sender = "HealthMonitor@LazyExchangeAdmin.com"

#[REQUIRED]
#Who are the recipients?
#Multiple recipients can be added (eg. "recipient1@domain.com","recipient2@domain.com")
$recipients = "HealthMonitor@LazyExchangeAdmin.com","June@LazyExchangeAdmin.com"

#[REQUIRED]
#your SMTP relay server
$smtpServer = "smtp.office365.com"

#[REQUIRED]
#your SMTP relay server port
$smtpPort = "587"

#[OPTIONAL - use only if your SMTP Relay requires authentication]
#Which XML file contains your SMTP relay authentication? - IF APPLICABLE
#If you don't have this yet, run this: Get-Credential | Export-CliXML <file.xml>
#Or if you are using the same account to login to Office 365, just point to the same XML file
$smtpCredentialFile = "C:\GitHub\Get-O365DirSyncElapsed\myCredential.xml"

#[OPTIONAL - use only if SMTP Relay requires SSL]
#Indicate whether or not SSL will be used
$smtpSSL = $true
#======================================
#end EMAIL SECTION
#======================================


#======================================
#DO NOT TOUCH THE BELOW CODES
#======================================
$credential = Import-Clixml $credentialFile
if ($smtpCredentialFile) {$smtpCredential = Import-Clixml $smtpCredentialFile}

$params = @{
    credential = $credential
    smtpServer = $smtpServer
    smtpPort = $smtpPort
    sender = $sender
    smtpSSL = $smtpSSL
    recipients = $recipients
	threshold = $threshold
}
if ($smtpCredentialFile)  {$params += @{smtpCredential = $smtpCredential}}
if ($logDirectory) {$params += @{logDirectory = $logDirectory}}
#======================================

& "$scriptFile" @params