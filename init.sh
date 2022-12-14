#from: Debian - bootstrapping past this would be copying disk images around, which isn't very flexible
#Installs:
  # Plex
  # Samba
  # ClickClick
  # WriteShite
#Configures:
  # Samba
  # Auto-mounting hard drives TODO better solution to this
  # Github CLI
#Does not configure:
  # Plex - login locally to the IP address, login with normal Plex account. Might have to setup libraries again

#Use cases:
  # You blammed your Debian install (again) and you want to get to "basically okay" in one command
    # > sudo chmod +x ./init.sh && ./init.sh
  # You added a new hard drive
    # Update ./fstab file
    # > sudo chmod +x ./init.sh && UNATTENDED_INIT="true" ./init.sh
  # You are developing this further after doing initial setup
    # > sudo chmod +x ./init.sh && UNATTENDED_INIT="true" ./init.sh

#Params:
  #UNATTENDED_INIT? - If set, will skip prompts for passwords from the user. Must be unset for first time init.


#Install plex repo
echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list;
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -;

sudo apt -y update;
sudo apt -y upgrade;
sudo apt -y install git docker docker-compose ntfs-3g zsh samba plexmediaserver;


sudo apt -y autoremove;
stat ~/.zshrc || yes | sudo sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)";
sudo cp -f ./fstab /etc/fstab;
sudo cp -f ./smb.conf /etc/samba/smb.conf;
sudo systemctl daemon-reload;
if [ -z ${UNATTENDED_INIT+x} ]; then 
	sudo smbpasswd -a julian;

	#install Github CLI https://github.com/cli/cli/blob/trunk/docs/install_linux.md
	type -p curl >/dev/null || sudo apt install curl -y
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y;
	gh auth login;
fi
sudo service smbd restart;

git clone https://github.com/okiyama/clickclickclickclickclickclickclickclick.click.git clickclick;
sudo ./clickclick/infra/update-docker-composed.sh;
git clone https://github.com/okiyama/writeshite.com.git writeshite;
chmod +x ./writeshite/gradlew;
./gradlew jibDockerBuild;
(cd docker && sudo docker-compose up --detach);
