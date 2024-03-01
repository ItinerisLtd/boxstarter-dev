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

echo 'Running wsl --update'
wsl --update
echo 'Running wsl --install --distribution Ubuntu --no-launch'
wsl --install --distribution Ubuntu --no-launch
echo 'Setting WSL version to 2'
wsl --set-default-version 2
refreshenv
echo 'Installing Ubuntu as passwordless root user'
ubuntu install --root
echo 'Installing wsl.conf'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ItinerisLtd/boxstarter-dev/main/configs/wsl.conf' -OutFile ~/Downloads/wsl.conf -UseBasicParsing
ubuntu run cp "/mnt/c/Users/${env:USERNAME}/Downloads/wsl.conf" '/etc/wsl.conf'
echo "Adding '${Username}' user"
ubuntu run useradd -m "${Username}"
ubuntu run "echo ${Username}:${Password} | chpasswd"
ubuntu run chsh -s /usr/bin/bash "${Username}"
ubuntu run usermod -aG adm,cdrom,sudo,dip,plugdev "${Username}"
echo 'Updating Ubuntu'
ubuntu run apt update
ubuntu run apt upgrade -y
echo "Setting Ubuntu default user to ${Username}"
ubuntu config --default-user "${Username}"
echo 'Setting default WSL distribution to Ubuntu'
wsl --set-default Ubuntu

echo 'Installing wsl.sh'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ItinerisLtd/boxstarter-dev/main/scripts/wsl.sh' -OutFile ~/Downloads/wsl-setup.sh -UseBasicParsing
ubuntu run cp "/mnt/c/Users/${env:USERNAME}/Downloads/wsl-setup.sh" '~/wsl-setup.sh'

echo 'Running wsl.sh'
ubuntu run chmod +x '~/wsl-setup.sh'
ubuntu run '~/wsl-setup.sh'
