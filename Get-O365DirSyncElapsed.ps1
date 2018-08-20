#Requires -Version 5.1
<#	
	.NOTES
	===========================================================================
	 Created on:   	19-April-2018
	 Created by:   	Tito D. Castillote Jr.
					june.castillote@gmail.com
	 Filename:     	Get-O365DirSyncElapsed.ps1
	 Version:		1.1 (20-August-2018)
	===========================================================================

	.LINK
	https://www.lazyexchangeadmin.com/2018/08/monitor-office-365-lastdirsynctime.html

	.SYNOPSIS
	Use Get-O365DirSyncElapsed.ps1 to query the last DirSync update time and send an email alert to specified recipients

	.DESCRIPTION
	
#>

#=================================================================================
#	1.0 - April 19, 2018
#		- Initial Release
#	1.1 - August 20, 2018
#		- Changed Time Stamp from UTC to Local Time, including the Time Zone ID
#		- Required PowerShell v5.1
#=================================================================================

$WarningPreference = "SilentlyContinue"
$script_root = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
Start-Transcript -Path "$($script_root)\debugLog.txt" -Append

#Note: This uses an encrypted credential (XML). To store the credential:
#1. Login to the Server/Computer using the account that will be used to run the script/task
#2. Run this "Get-Credential | Export-CliXml ExOnlineStoredCredential.xml"
#3. Make sure that ExOnlineStoredCredential.xml is in the same folder as the script.
$onLineCredential = Import-Clixml "$($script_root)\ExOnlineStoredCredential.xml"

#mail variables - this example relays the email via O365 with authentication using port 587
$toAddress = "june.castillote@lazyexchangeadmin.com","june.castillote@gmail.com"
$fromAddress = "$($onLineCredential.Username)"
$mailSubject = "ALERT: Office365 DirSync Last Update Time"
$smtpServer = "smtp.office365.com"
$smtpPort = "587"

#dirsync threshold in hours
[int]$dirSyncElapsedTimeThreshold = 0

Write-Host (Get-Date) ": Connecting to Office 365"

try {

		Import-Module MSOnline
		Connect-MsolService -Credential $onLineCredential
	}
catch
	{
		Write-Warning $_.Exception.Message
		EXIT
	}

Write-Host (Get-Date) ": Retrieve Last Update Time"
$TimeZoneUTC = (Get-TimeZone).ToString().Split(" ")[0]
$TimeZoneID = (Get-TimeZone).ID


$info = Get-MsolCompanyInformation
$timeNow = (Get-Date).ToLocalTime()
$dirSyncElapsedTime = New-TimeSpan -Start $info.LastDirSyncTime.ToLocalTime() -End $timeNow
Write-Host (Get-Date) ": Time Now is $timeNow $($TimeZoneUTC) ($($TimeZoneID))"
Write-Host (Get-Date) ": Last DirSync Time $($info.LastDirSyncTime.ToLocalTime()) $($TimeZoneUTC) ($($TimeZoneID))"
Write-Host (Get-Date) ": Total Elapsed Time $($dirSyncElapsedTime.Hours) Hours"

if ($dirSyncElapsedTime.Hours -ge $dirSyncElapsedTimeThreshold)
{
	Write-Host (Get-Date) ": Sending Email Alert"
	$mailParams = @{		
		To = $toAddress
		From = $fromAddress
		Subject = $mailSubject
		Body = "Last DirSync Time ($($info.LastDirSyncTime)) was over $($dirSyncElapsedTime.Hours) HOURS ago"
		SmtpServer = $smtpServer
		Port = $smtpPort
		Credential = $onLineCredential
		Priority = "High"
	}
	Send-MailMessage @mailParams -UseSSL
}
Write-Host (Get-Date) ": Done"
Stop-Transcript