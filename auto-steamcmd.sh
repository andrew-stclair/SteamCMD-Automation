#!/bin/bash

# Variables
username="anonymous"
password=""
install_dir=""
app_id=""
app_exe=""
steamCmd_web_location="http://media.steampowered.com/client/steamcmd_linux.tar.gz"

# Update required software
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt install lib32gcc1 -y

# Create temp directory
mkdir -p /tmp/steamcmd
cd /tmp/steamcmd

# Download and extract latest steamcmd
wget ${steamCmd_web_location}
tar -xvzf steamcmd_linux.tar.gz
rm *.tar.gz

# Make install directory
mkdir -p ${install_dir}
chmod +x ${install_dir}

# Move steamcmd to user directory
mv /tmp/steamcmd/* ~/
rm -rf /tmp/steamcmd

# Create update file
echo "//SERVER UPDATER SCTIPT FOR ${install_dir}
login ${username} ${password}
force_install_dir ${install_dir}
app_update ${app_id} validate
quit
" > /update-${app_id}.txt

# Create start script
echo "#!/bin/bash
cd ${install_dir}

# Start Server
${app_exe}
" > /start_${app_id}.sh

# Create update script
echo "#!/bin/bash
cd ${install_dir}

# Update Server
${HOME}/steamcmd.sh +runscript /update-${app_id}.txt
" > /update_${app_id}.sh

# Fix permissions
chmod +x /start_${app_id}.sh
chmod +x /update_${app_id}.sh
chmod +x /update-${app_id}.txt

# Download server files from steam
~/steamcmd.sh +runscript /update-${app_id}.txt
