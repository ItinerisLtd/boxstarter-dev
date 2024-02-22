# Setting File Permissions On Hosts File
Write-Output "Setting File Permissions On Hosts File"
$ACL = Get-ACL -Path "C:\Windows\System32\drivers\etc\hosts"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Users","Modify","Allow")
$ACL.SetAccessRule($AccessRule)
$ACL | Set-Acl -Path "C:\Windows\System32\drivers\etc\hosts"

$Username = 'itineris'
$Password = 'itineris'

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

echo 'Installing wsl.sh'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ItinerisLtd/boxstarter-dev/main/scripts/wsl.sh' -OutFile "\\wsl$\Ubuntu\home\${Username}\wsl-setup.sh" -UseBasicParsing

echo 'Running wsl.sh'
ubuntu run bash -c "chmod +x /home/${Username}/wsl-setup.sh && /home/${Username}/wsl-setup.sh"
