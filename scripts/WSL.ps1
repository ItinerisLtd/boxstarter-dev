choco install -y Microsoft-Hyper-V-All --source=windowsFeatures
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
choco install -y Microsoft-Windows-Subsystem-Linux --source=windowsfeatures

$Program = "ubuntu"
$Username = 'itineris'
$Password = 'itineris'
# TODO: Move this to choco install once --root is included in that package
Invoke-WebRequest -Uri "https://aka.ms/wslubuntu" -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx

RefreshEnv
Invoke-WebRequest -Uri "https://github.com/ItinerisLtd/boxstarter-dev/raw/main/configs/.wslconfig" -OutFile ~/.wslconfig -UseBasicParsing

# Install Ubuntu as passwordless root user
& "$Program" install --root
# Add user account
& "$Program" run useradd -m "$Username"
& "$Program" run sh -c "echo ${Username}:${Password} | chpasswd"
& "$Program" run chsh -s /usr/bin/bash "$Username"
& "$Program" run usermod -aG adm,cdrom,sudo,dip,plugdev
& "$Program" run apt update
& "$Program" run apt upgrade -y
& "$Program" config --default-user "$Username"
& "$Program" --set-default Ubuntu

# TODO: copy configs/wsl.conf to WSL /etc/wsl.conf
