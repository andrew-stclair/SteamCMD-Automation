#!/bin/bash

# Make sure we are running as root
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit
fi

# Update required software
dpkg --add-architecture i386
apt-get update
apt install lib32gcc1 -y

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

# Make sure we are running as root
if [ "$EUID" -ne 0 ]
	then echo \"Please run as root\"
	exit
fi

# Stop service
systemctl stop srcds-${app_id}

# Update Server
${HOME}/steamcmd.sh +runscript /update-${app_id}.txt
chown -R srcds-${app_id}:srcds-${app_id} ${install_dir}

# Start service
systemctl start srcds-${app_id}
" > /update_${app_id}.sh

# Create service user
useradd -M -U -s /usr/sbin/nologin srcds-${app_id}

# Create and enable systemd service
echo "[Unit]
Description=SRCDS-${app_id} Server
After=network.target

[Service]
Type=simple
User=srcds-${app_id}
Group=srcds-${app_id}
ExecStart=/start_${app_id}.sh
TimeoutStartSec=0

[Install]
WantedBy=default.target
" > /etc/systemd/system/srcds-${app_id}.service
systemctl daemon-reload
systemctl enable srcds-${app_id}

# Fix permissions
chmod +x /start_${app_id}.sh
chmod +x /update_${app_id}.sh
chmod +x /update-${app_id}.txt
chown -R srcds-${app_id}:srcds-${app_id} ${install_dir}

# Download server files from steam
~/steamcmd.sh +runscript /update-${app_id}.txt

# Start Server
systemctl start srcds-${app_id}
