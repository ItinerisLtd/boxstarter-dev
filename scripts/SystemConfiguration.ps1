#--- Enable developer mode on the system ---
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

# Setting File Permissions On Hosts File
$ACL = Get-ACL -Path "C:\Windows\System32\drivers\etc\hosts"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users","Modify","Allow")
$ACL.SetAccessRule($AccessRule)
$ACL | Set-Acl -Path "C:\Windows\System32\drivers\etc\hosts"
