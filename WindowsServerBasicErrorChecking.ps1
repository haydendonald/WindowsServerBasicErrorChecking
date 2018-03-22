#Email Settings - I use outlook so yeah
$From       = "putaemail@here.com"
$To         = "putaemail@here.com"
$SMTPServer = "smtp-mail.outlook.com"
$SMTPPort   = "587"
$username   = 'putaemail@here.com'
$password   = 'putaspasswordhere'
$secstr     = New-Object -TypeName System.Security.SecureString
$password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred       = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
$smtpserver = "smtp-mail.outlook.com"

#Script Settings
$showErrorDialog = 1;
$emailOnError = 1;
$emailOnGood = 1;
$serverName = "GenericServer";


$diskStatus = Get-PhysicalDisk;
$frendlyDiskStatus = $diskStatus | Out-String;
$storagePool = Get-StoragePool;
$friendlyStoragePool = $storagePool | Out-String;
$virtualDisk = Get-VirtualDisk;
$friendlyVirtualDiskStatus = $virtualDisk | Out-String;
$status = "OK";
$checkState = 0;

"Windows Server Disk Checker
By Hayden Donald http://github.com/haydendonald 2018

Got Disk Status: $frendlyDiskStatus 

Got Storage Pool Status: $friendlyStoragePool

Got Virtual Disk Status: $friendlyVirtualDiskStatus

====================================================
"

#Check the disks
"Checking Disks..";


foreach($i in $diskStatus) {
if ($i.OperationalStatus -ne "OK" -or $i.HealthStatus -ne "Healthy") {
    if($checkState -eq 0) {"Problem Disk(s) Found!"; $checkState = 1;}
    $i | Out-String
    if($status -eq "OK") {$status = "Disk Error!";} else {$status += "Disk Error!";}
    }
}
if($status -eq "OK"){"Good";}


#Check the storage pool
"Checking Storage Pool..";
$checkState = 0;


foreach($i in $storagePool) {
if ($i.OperationalStatus -ne "OK" -or $i.HealthStatus -ne "Healthy") {
    if($checkState -eq 0) {"Problem Storage Pool(s) Found"; $checkState = 1;}
    $i | Out-String
    if($status -eq "OK") {$status = "Storage Pool Error!";} else {$status += "Storage Pool Error!";}
    }
}
if($status -eq "OK"){"Good";}

#Check the storage pool
"Checking Virtual Disks..";
$checkState = 0;


foreach($i in $virtualDisk) {
if ($i.OperationalStatus -ne "OK" -or $i.HealthStatus -ne "Healthy") {
    if($checkState -eq 0) {"Problem Virtual Disk(s) Found!"; $checkState = 1;}
    $i | Out-String
    if($status -eq "OK") {$status = "Virtual Disk Error!";} else {$status += "Virtual Disk Error!";}
    }
}
if($status -eq "OK"){"Good";}


"Current Status: $status"

#Send out email report!
if($status -ne "OK") {
if($showErrorDialog -eq 1) {
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("There Is A Problem With $serverName
}

Status:
$status

Disk Status:
$frendlyDiskStatus

Storage Pool Status:
$friendlyStoragePool

Virtual Disk Status:
$friendlyVirtualDiskStatus

Sorry for the spam, wanted you to know :)
", "Critical Error", "Ok", "Error");
}


if($emailOnError -eq 1) {
try {
"Sending out a email notification";
Send-MailMessage -From $From -to $To -Subject "$serverName Reported A Critical Error" -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -Verbose -Body "
$serverName REQUIRES ATTENTION!

The server is currently experiencing a cricial error and needs to be checked.

It Is Reporting A Status Of 
$status

More Information:

Disk Status:
$frendlyDiskStatus

Storage Pool Status:
$friendlyStoragePool

Virtual Disk Status:
$friendlyVirtualDiskStatus

This script is by Hayden Donald
Check out my github at http://github.com/haydendonald
";
"Done!"
}
catch {
Add-Type -AssemblyName System.Windows.Forms
System.Windows.Forms.MessageBox]::Show("Couldn't Send The Email!");
}
}
elseif($emailOnGood -eq 1){
try {
"Sending out a email notification";
Send-MailMessage -From $From -to $To -Subject "$serverName RWas Checked And Reported OK" -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -Verbose -Body "
$serverName Reported OK

The server is happy lets go party!

It Is Reporting A Status Of 
$status

More Information:

Disk Status:
$frendlyDiskStatus

Storage Pool Status:
$friendlyStoragePool

Virtual Disk Status:
$friendlyVirtualDiskStatus

This script is by Hayden Donald
Check out my github at http://github.com/haydendonald
";
"Done!"
}
catch {
Add-Type -AssemblyName System.Windows.Forms
System.Windows.Forms.MessageBox]::Show("Couldn't Send The Email!");
}
}}

#Don't hate on my code or spelling its my first time writing powershell scripts :)