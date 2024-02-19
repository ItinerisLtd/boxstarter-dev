choco install -y Microsoft-Hyper-V-All --source="'windowsFeatures'"
choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"

$DistroName = 'ubuntu'
$DistroVersion = '2204'
$Program = "$DistroName$DistroVersion"
(Get-Culture).TextInfo.ToTitleCase($Program.ToLower())
$Username = 'itineris'
$Password = 'itineris'
# TODO: Move this to choco install once --root is included in that package
Invoke-WebRequest -Uri "https://aka.ms/wsl$DistroName$DistroVersion" -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx

RefreshEnv
Copy-Item "../configs/.wslconfig" -Destination ~/.wslconfig

# Install Ubuntu as passwordless root user
& "$Program" install --root
# Add user account
& "$Program" run useradd -m "$Username"
& "$Program" run sh -c "echo $Username:$Password | chpasswd"
& "$Program" run chsh -s /usr/bin/bash "$Username"
& "$Program" run usermod -aG adm,cdrom,sudo,dip,plugdev
& "$Program" run apt update
& "$Program" run apt upgrade -y
& "$Program" config --default-user "$Username"
& "$Program" --set-default Ubuntu

# TODO: copy configs/wsl.conf to WSL /etc/wsl.conf
