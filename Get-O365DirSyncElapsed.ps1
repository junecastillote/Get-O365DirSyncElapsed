
<#PSScriptInfo

.VERSION 1.2

.GUID 9b474c7e-2715-4317-b8c0-88b0a5af3617

.AUTHOR June Castillote

.COMPANYNAME www.lazyexchangeadmin.com

.COPYRIGHT june.castillote@gmail.com

.TAGS

.LICENSEURI

.PROJECTURI https://github.com/junecastillote/Get-O365DirSyncElapsed

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#> 


<# 

.DESCRIPTION 
script to query the last DirSync update time and send an email alert to specified recipients when a specified threshold is breached.

.EXAMPLE
$credential = (Get-Credential) ; .\Get-O365DirSyncElapsed.ps1 -credential $credential -logDirectory .\log -sender sender@domain.com -recipients recipient1@domain.com,recipient2@domain.com -smtpServer smtp.office365.com -smtpPort 587 -smtpCredential $credential -smtpSSL -threshold 1

Manually entering Office 365 credential

.EXAMPLE
$credential = Import-CliXML .\credential.xml ; .\Get-O365DirSyncElapsed.ps1 -credential $credential -logDirectory .\log -sender sender@domain.com -recipients recipient1@domain.com,recipient2@domain.com -smtpServer smtp.office365.com -smtpPort 587 -smtpCredential $credential -smtpSSL -threshold 1

Importing Office 365 Credential from an encrypted XML file.
#>

Param(
        # office 365 credential
        # you can pass the credential using variable ($credential = Get-Credential)
        # then use parameter like so: -credential $credential
        # OR created an encrypted XML (Get-Credential | export-clixml <file.xml>)
        # then use parameter like so: -credential (import-clixml <file.xml>)
        [Parameter(Mandatory=$true)]
        [pscredential]$credential,

        #path to the log directory (eg. c:\scripts\logs)
        [Parameter()]
        [string]$logDirectory,
        
        #Sender Email Address
        [Parameter(Mandatory=$true)]
        [string]$sender,

        #Recipient Email Addresses - separate with comma
        [Parameter(Mandatory=$true)]
		[string[]]$recipients,
		
		#smtpServer
        [Parameter(Mandatory=$true)]
        [string]$smtpServer,

        #smtpPort
        [Parameter(Mandatory=$true)]
        [string]$smtpPort,

        #credential for SMTP server (if applicable)
        [Parameter()]
        [pscredential]$smtpCredential,

        #switch to indicate if SSL will be used for SMTP relay
        [Parameter()]
        [switch]$smtpSSL,

        #Delete older files (in days)
        [Parameter()]
		[int]$removeOldFiles,

		#Threshold in Hours to trigger alert.
		[Parameter(Mandatory=$true)]
		[int]$threshold
)

#=================================================================================
#	1.0 - April 19, 2018
#		- Initial Release
#	1.1 - August 20, 2018
#		- Changed Time Stamp from UTC to Local Time, including the Time Zone ID
#		- Required PowerShell v5.1
#=================================================================================

$script_root = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

#MSOnline Module check
if (!(Get-Module -ListAvailable MSOnline))
{
	Write-Host "ERROR: This script requires the MSOnline Module, but it isnot currently intalled on your machine." 
	Write-Host "ERROR: Please install it first by running 'Install-Module MSOnline' inside PowerShell as an admin." 
	EXIT
}

#Import Functions
if (!(Test-Path "$script_root\xFunctions.ps1"))
{
	Write-Host "ERROR: This script requires functions that are present in another script" 
	Write-Host "ERROR: Please download this file (1.0): https://raw.githubusercontent.com/junecastillote/xFunctions/master/xFunctions.ps1" 
	Write-Host "ERROR: Then save it in $script_root, before trying to run the script again." 
	EXIT
}
else {	
	. "$script_root\xFunctions.ps1"
}

#Get script version and url
if ($PSVersionTable.psversion.Major -lt 5) 
{
#	$functionInfo = Get-ScriptInfo -Path "$script_root\xFunctions.ps1"
	$scriptInfo = Get-ScriptInfo -Path $MyInvocation.MyCommand.Definition
	$timeZoneInfo = Get-TimeZoneInfo -Computer ($env:COMPUTERNAME)
}
else 
{
	#$functionInfo = Test-ScriptFileInfo -Path "$script_root\xFunctions.ps1"
	$scriptInfo = Test-ScriptFileInfo -Path $MyInvocation.MyCommand.Definition
	$timeZoneInfo = Get-TimeZone
}
#============================

#Set Paths-------------------------------------------------------------------------------------------
$today = Get-Date
[string]$fileSuffix = '{0:dd-MMM-yyyy_hh-mm_tt}' -f $today
$logFile = "$($logDirectory)\Log_$($fileSuffix).txt"

#Create folders if not found
if ($logDirectory)
{
    if (!(Test-Path $logDirectory)) 
    {
        New-Item -ItemType Directory -Path $logDirectory | Out-Null
        #start transcribing----------------------------------------------------------------------------------
        Start-TxnLogging $logFile
        #----------------------------------------------------------------------------------------------------
    }
	else
	{
		Start-TxnLogging $logFile
	}
}
#----------------------------------------------------------------------------------------------------

Write-Host (get-date -Format "dd-MMM-yyyy hh:mm:ss tt") ": Connecting to Office 365"

try {

		Import-Module MSOnline
		Connect-MsolService -Credential $credential
	}
catch
	{
		Write-Warning $_.Exception.Message
		EXIT
	}

Write-Host (get-date -Format "dd-MMM-yyyy hh:mm:ss tt") ": Retrieve Last Update Time"
$timeZone = $timeZoneInfo.DisplayName.Split(" ")[0]

if (!($LastDirSyncTime = (Get-MsolCompanyInformation).LastDirSyncTime))
{
	$LastDirSyncTime = (Get-Date).AddHours(-2)
}

$timeNow = (Get-Date).ToLocalTime()
$dirSyncElapsedTime = (New-TimeSpan -Start $LastDirSyncTime.ToLocalTime() -End $timeNow).TotalHours
Write-Host (get-date -Format "dd-MMM-yyyy hh:mm:ss tt") ": Alert Threshold = $threshold(H)"
Write-Host (get-date -Format "dd-MMM-yyyy hh:mm:ss tt") ": Time Now = $($timeNow.ToString("dd-MMM-yyyy hh:mm:ss tt")) $($timeZone)"
Write-Host (get-date -Format "dd-MMM-yyyy hh:mm:ss tt") ": Last DirSync Time = $($LastDirSyncTime.ToString("dd-MMM-yyyy hh:mm:ss tt")) $($timeZone)"
Write-Host (get-date -Format "dd-MMM-yyyy hh:mm:ss tt") ": Total Elapsed Time = $($dirSyncElapsedTime.ToString('N2'))(H)"

if ($dirSyncElapsedTime -gt $threshold)
{
	$mailBody = @(
		"<p>Last DirSync Time - $($LastDirSyncTime.ToString("dd-MMM-yyyy hh:mm:ss tt")) $($timeZone) - was over $($dirSyncElapsedTime.ToString('N2'))(H) ago</p>"
		"<p><a href=""$($scriptInfo.ProjectURI)"">$($MyInvocation.MyCommand.Definition.ToString().Split("\")[-1].Split(".")[0]) $($scriptInfo.version)</a></p>"
	)

	$mailParams = @{
		From = $sender
		To = $recipients
		Subject = "ALERT!!!: [$((Get-msOlCompanyInformation).DisplayName)] Office365 DirSync Last Update Time is Outdated"
		Body = ($mailBody -join "`n")
		smtpServer = $smtpServer
		Port = $smtpPort
		useSSL = $smtpSSL
		BodyAsHtml = $true
		Priority = "High"
	}

	if ($smtpCredential) 
	{
		$mailParams += @{
			credential = $smtpCredential
		}
	}

	Write-Host (get-date -Format "dd-MMM-yyyy hh:mm:ss tt") ": Sending email to" ($recipients -join ",") -ForegroundColor Green
	Send-MailMessage @mailParams
}

Stop-TxnLogging