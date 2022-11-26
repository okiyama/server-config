#from: Debian - bootstrapping past this would be copying disk images around, which isn't very flexible
sudo apt -y update;
sudo apt -y upgrade;
sudo apt -y install git docker docker-compose ntfs-3g zsh samba;
sudo apt -y autoremove;
stat ~/.zshrc || yes | sudo sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
sudo cp -f ./fstab /etc/fstab;
sudo cp -f ./smb.conf /etc/samba/smb.conf;
sudo cp -f ./smb.conf /usr/local/samba/smb.conf;
sudo systemctl daemon-reload;
if [ -z ${SAMBA_PASSWORD_SET+x} ]; then sudo smbpasswd -a julian && export SAMBA_PASSWORD_SET=true; fi
sudo service smbd restart;
#sudo docker-compose up;
