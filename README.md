# SteamCMD-Automation
A Linux Script to automate the process of installing and updating SteamCMD servers

# Installation
setup an amazon EC2 instance with the official ubuntu image

set the User Data to the following:

```
#!/bin/bash
# Vars to edit
source username="anonymous"
source password=""
source install_dir=""
source app_id=""
source app_exe=""
source steamCmd_web_location="http://media.steampowered.com/client/steamcmd_linux.tar.gz"

# Leave below alone
wget https://raw.githubusercontent.com/andrew-stclair/SteamCMD-Automation/master/install.sh -O /install.sh
chmod +x /install.sh
cd /
/install.sh
```

Alternatively, copy the code above to setup.sh and execute it as root