# Setting File Permissions On Hosts File
Write-Output "Setting File Permissions On Hosts File"
$ACL = Get-ACL -Path "C:\Windows\System32\drivers\etc\hosts"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users","Modify","Allow")
$ACL.SetAccessRule($AccessRule)
$ACL | Set-Acl -Path "C:\Windows\System32\drivers\etc\hosts"

#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
#Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All
choco install -y Microsoft-Hyper-V-All --source windowsFeatures
choco install -y VirtualMachinePlatform --source windowsFeatures
choco install -y Microsoft-Windows-Subsystem-Linux --source windowsfeatures
#dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
#dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

#echo 'Downloading Ubuntu'
$Username = 'itineris'
$Password = 'itineris'
# TODO: Move this to choco install once --root is included in that package
#Invoke-WebRequest -Uri 'https://aka.ms/wslubuntu' -OutFile ~/Ubuntu.appx -UseBasicParsing
#Add-AppxPackage -Path ~/Ubuntu.appx

RefreshEnv
echo 'Installing .wslconfig'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ItinerisLtd/boxstarter-dev/main/configs/.wslconfig' -OutFile ~/.wslconfig -UseBasicParsing

echo 'Running wsl --install'
wsl --install
echo 'Setting WSL version to 2'
wsl --set-default-version 2
echo 'Installing Ubuntu as passwordless root user'
ubuntu install --root
echo "Adding '${Username}' user"
ubuntu run useradd -m "$Username"
ubuntu run sh -c "echo ${Username}:${Password} | chpasswd"
ubuntu run chsh -s /usr/bin/bash "$Username"
ubuntu run usermod -aG adm,cdrom,sudo,dip,plugdev
echo 'Updating Ubuntu'
ubuntu run apt update
ubuntu run apt upgrade -y
echo "Setting Ubuntu default user to ${Username}"
ubuntu config --default-user "$Username"
echo 'Setting default WSL distribution to Ubuntu'
wsl --set-default Ubuntu

echo 'Installing wsl.conf'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ItinerisLtd/boxstarter-dev/main/configs/wsl.conf' -OutFile '\\wsl$\Ubuntu\etc\wsl.conf' -UseBasicParsing
