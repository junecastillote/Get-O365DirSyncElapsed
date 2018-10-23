<p>
<a href="https://lh3.googleusercontent.com/-ELVMp71R9sI/W28fam_G7eI/AAAAAAAACtc/DU_0h6-eWjUtwV4G0VkcQUDyQPtbnSCcACHMYCw/s1600-h/Office365Logo_256x254px%255B5%255D"><img width="158" height="158" title="Office365Logo_256x254px" align="left" style="border: 0px currentcolor; border-image: none; float: left; display: inline; background-image: none;" alt="Office365Logo_256x254px" src="https://lh3.googleusercontent.com/-NDbwZNxqOt4/W28fcC9-P2I/AAAAAAAACtg/LysXoDXJo5UzhLbU3sj1am54NDaHgC0WwCHMYCw/Office365Logo_256x254px_thumb%255B3%255D?imgmax=800" border="0"></a>Knowing if your Directory Sync is up to date (or not) is crucial. Yes, you can glue your eyes to the Office 365 Portal or use commercial 3rd party monitoring tools to be alerted when your Directory Sync hasn’t updated for a certain period, or you can achieve the same goal using PowerShell. Microsoft was kind enough to include a LastDirSyncTime value when you run the Get-MsolCompanyInformation cmdlet. This way it can be programmatically checked and monitored by scheduling a script to run via task at an interval.</p>
<p>
This script queries the LastDirSyncTime value, gets the current time, calculates the elapsed time, compares the difference against a set threshold and send an email alert if the threshold is breached.</p>
<h3>
</h3>
<h4>
</h4>
<h3>
</h3>
<h3>
Download Link</h3>
<p>
<a title="https://github.com/junecastillote/Get-O365DirSyncElapsed" href="https://github.com/junecastillote/Get-O365DirSyncElapsed">https://github.com/junecastillote/Get-O365DirSyncElapsed</a></p>
<ul>
<li>1.0 - April 19, 2018</li>
<ul>
<li>Initial Release </li>
</ul>
<li>1.1 – August 20, 2018</li>
<ul>
<li>Changed Time Stamp from UTC to Local Time, including the Time Zone ID</li>
<li>Required PowerShell v5.1</li>
</ul>
</ul>
<h3>

</h3>
<h3>
Requirements</h3>
<ul>
<li><font color="#ff0000">PowerShell v5.1 (as of script v1.1)</font></li>
<li>MSOnline Module</li>
</ul>
<p>
Having the MSOnline Module installed is required for this to work. If you have PowerShell 5, it is easy to install. Just run Install-Package MSOnline and it should get you started. However for lower PS versions it may take a bit more to get MSOnline Module installed.</p>
<p>
You can read up on MSOnline in detail from by following this link: <a href="https://docs.microsoft.com/en-us/powershell/azure/active-directory/overview?view=azureadps-1.0" target="_blank">Azure ActiveDirectory (MSOnline)</a></p>
<h3>
How To Use</h3>
<h4>
Export Login Credentials to XML</h4>
<p>
The Username and Password are not saved inside the script, but rather it will import the login information from an encrypted XML file that you need to create beforehand.</p>
<p>
<a href="https://lh3.googleusercontent.com/-dDkHn9xhG-s/W2-ZmP83g5I/AAAAAAAACuU/cwRg7DiAVS4F4rI3rox9DkeMsSxRDq1fwCHMYCw/s1600-h/notepad%252B%252B_2018-08-12_09-59-43%255B3%255D"><img width="747" height="74" title="" style="display: inline; background-image: none;" alt="" src="https://lh3.googleusercontent.com/-53azmq1CpAM/W2-ZnUs1xjI/AAAAAAAACuY/CwyCs62FU10qtbF80qSwXYcD66rI-e4HACHMYCw/notepad%252B%252B_2018-08-12_09-59-43_thumb%255B1%255D?imgmax=800" border="0"></a></p>
<p>
Run this line in PowerShell, and it should save the credentials in an XML file.</p>
<p>
<font face="Courier New">Get-Credential | Export-CliXml ExOnlineStoredCredential.xml</font></p>
<p>
<a href="https://lh3.googleusercontent.com/-ubHGVm4T994/W2-Zo0P_CMI/AAAAAAAACuc/I8-5tLhBUWEtwZ_5rEOjOJHBQ-qMAFiMgCHMYCw/s1600-h/mRemoteNG_2018-08-12_09-53-30%255B3%255D"><img width="795" height="340" title="" style="display: inline; background-image: none;" alt="" src="https://lh3.googleusercontent.com/-1dS7ynHJHdg/W2-ZqFFSIuI/AAAAAAAACug/AU4G09POAi8KRGzJsH2-hpMpYvn5Yp1kACHMYCw/mRemoteNG_2018-08-12_09-53-30_thumb%255B1%255D?imgmax=800" border="0"></a></p>
<p>
Below is the sample content of the exported credentials.</p>
<p>
<a href="https://lh3.googleusercontent.com/-o0wjcAhgBxI/W2-ZrtEQmBI/AAAAAAAACuk/U1ITE9PGIzIBwMeeFtqSV1gNJxecIL-TgCHMYCw/s1600-h/mRemoteNG_2018-08-12_09-55-27%255B3%255D"><img width="694" height="229" title="" style="display: inline; background-image: none;" alt="" src="https://lh3.googleusercontent.com/-MoG9H-ntDcA/W2-Zs-3szBI/AAAAAAAACuo/S1IBb-LmwwoRS13ot1goy2tkFfDkLjaKQCHMYCw/mRemoteNG_2018-08-12_09-55-27_thumb%255B1%255D?imgmax=800" border="0"></a></p>
<h4>
Variables</h4>
<p>
Some variables that need to be modified depending on your requirement. The below example assumes that you are also using Exchange Online as relay. If you prefer to use a different SMTP relay, you will need to manually modify the script to conform with that.</p>
<p>
<a href="https://lh3.googleusercontent.com/-sambtNt6pq0/W2-Zt-y5dmI/AAAAAAAACus/TwRrBWIUh-o2nEfQwWEFDn_sQYNqIyi0ACHMYCw/s1600-h/notepad%252B%252B_2018-08-12_10-01-44%255B3%255D"><img width="742" height="156" title="" style="display: inline; background-image: none;" alt="" src="https://lh3.googleusercontent.com/-Ab6xPvjQTPA/W2-ZvUulPFI/AAAAAAAACuw/fs9hqg07XFECGOKX4Z0cLz06OJ2OxmN5gCHMYCw/notepad%252B%252B_2018-08-12_10-01-44_thumb%255B1%255D?imgmax=800" border="0"></a></p>
<p>
In this example, only the following variables need to be modified.</p>
<p>
<strong>$dirSyncElapsedTimeThreshold</strong>: The threshold in hours. If this is breached, the email alert will be sent.</p>
<p>
<strong>$toAddress</strong> : The email addresses (separate with comma if more than one) of the intended recipients of the email alert.</p>
<p>
<strong>$mailSubject</strong>: Your choice of message subject when the alert is sent.</p>
<h4>

</h4>
<h4>
Output</h4>
<p>
Once it’s all set up, just run the script from PowerShell. In the example below I set the threshold to ZERO (0) hours to trigger the alert. You should set a more realistic threshold in your production, obviously.</p>
<p>
<a href="https://lh3.googleusercontent.com/-YTIDQbnNjsU/W3orIf6-7gI/AAAAAAAAC28/Uanofz_zR0kz3_-VA8Oh47r1MAB-EPHwwCHMYCw/s1600-h/mRemoteNG_2018-08-20_09-24-153"><img width="689" height="177" title="" style="display: inline; background-image: none;" alt="" src="https://lh3.googleusercontent.com/-22NBz35dAsY/W3orLC0AJPI/AAAAAAAAC3A/4wNb7jrLOIE1ypsblwU-VxC_WW75rh9XACHMYCw/mRemoteNG_2018-08-20_09-24-15_thumb1?imgmax=800" border="0"></a></p>
<p>
Then the email alert similar to this should be received.</p>
<p>
<a href="https://lh3.googleusercontent.com/-Vk6AxoUUpeI/W2-ZzFdzy8I/AAAAAAAACu8/7yUqzUTc8eonMkfHdC0BAp4Mv3GFm2wowCHMYCw/s1600-h/OUTLOOK_2018-08-12_10-14-40%255B5%255D"><img width="471" height="223" title="" style="border: 0px currentcolor; border-image: none; display: inline; background-image: none;" alt="" src="https://lh3.googleusercontent.com/--ytXgzCeg84/W2-Z0TqkAbI/AAAAAAAACvA/bGhksy5-qv8W4_Ry3Gh9aGWldl2y3wZTACHMYCw/OUTLOOK_2018-08-12_10-14-40_thumb%255B3%255D?imgmax=800" border="0"></a></p>
