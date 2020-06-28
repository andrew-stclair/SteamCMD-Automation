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
wget ${srcds_steamCmd_web_location}
tar -xvzf steamcmd_linux.tar.gz
rm *.tar.gz

# Make install directory
mkdir -p ${srcds_install_dir}
chmod +x ${srcds_install_dir}

# Move steamcmd to user directory
mv /tmp/steamcmd/* ~/
rm -rf /tmp/steamcmd

# Create update file
echo "//SERVER UPDATER SCTIPT FOR ${srcds_install_dir}
login ${srcds_username} ${srcds_password}
force_install_dir ${srcds_install_dir}
app_update ${srcds_app_id} validate
quit
" > /update-${srcds_app_id}.txt

# Create start script
echo "#!/bin/bash
cd ${srcds_install_dir}

# Start Server
${srcds_app_exe}
" > /start_${srcds_app_id}.sh

# Create update script
echo "#!/bin/bash
cd ${srcds_install_dir}

# Make sure we are running as root
if [ "$EUID" -ne 0 ]
	then echo \"Please run as root\"
	exit
fi

# Stop service
systemctl stop srcds-${srcds_app_id}

# Update Server
${HOME}/steamcmd.sh +runscript /update-${srcds_app_id}.txt
chown -R srcds-${srcds_app_id}:srcds-${srcds_app_id} ${srcds_install_dir}

# Start service
systemctl start srcds-${srcds_app_id}
" > /update_${srcds_app_id}.sh

# Create service user
useradd -M -U -s /usr/sbin/nologin srcds-${srcds_app_id}

# Create and enable systemd service
echo "[Unit]
Description=SRCDS-${srcds_app_id} Server
After=network.target

[Service]
Type=simple
User=srcds-${srcds_app_id}
Group=srcds-${srcds_app_id}
ExecStart=/start_${srcds_app_id}.sh
TimeoutStartSec=0

[Install]
WantedBy=default.target
" > /etc/systemd/system/srcds-${srcds_app_id}.service
systemctl daemon-reload
systemctl enable srcds-${srcds_app_id}

# Fix permissions
chmod +x /start_${srcds_app_id}.sh
chmod +x /update_${srcds_app_id}.sh
chmod +x /update-${srcds_app_id}.txt
chown -R srcds-${srcds_app_id}:srcds-${srcds_app_id} ${srcds_install_dir}

# Download server files from steam
~/steamcmd.sh +runscript /update-${srcds_app_id}.txt

# Start Server
systemctl start srcds-${srcds_app_id}
