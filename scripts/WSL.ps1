choco install -y Microsoft-Hyper-V-All --source=windowsFeatures
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
choco install -y Microsoft-Windows-Subsystem-Linux --source=windowsfeatures
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

$Username = 'itineris'
$Password = 'itineris'
# TODO: Move this to choco install once --root is included in that package
Invoke-WebRequest -Uri "https://aka.ms/wslubuntu" -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx

RefreshEnv
echo "Installing Ubuntu"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ItinerisLtd/boxstarter-dev/main/configs/.wslconfig" -OutFile ~/.wslconfig -UseBasicParsing

wsl --update
wsl --set-default-version 2
# Install Ubuntu as passwordless root user
ubuntu install --root
# Add user account
ubuntu run useradd -m "$Username"
ubuntu run sh -c "echo ${Username}:${Password} | chpasswd"
ubuntu run chsh -s /usr/bin/bash "$Username"
ubuntu run usermod -aG adm,cdrom,sudo,dip,plugdev
ubuntu run apt update
ubuntu run apt upgrade -y
ubuntu config --default-user "$Username"
wsl --set-default Ubuntu

# TODO: copy configs/wsl.conf to WSL /etc/wsl.conf
