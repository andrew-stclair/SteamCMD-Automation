#!/bin/bash

clear

#VARS
#COLOURS
normal_color="$(tput sgr0) "
black="\033[1;30m"
red="\033[33;31m"
orange="\033[1;31m"
green="\033[33;32m"
yellow="\033[33;33m"
blue="\033[33;34m"
pink="\033[1;35m"
magenta="\033[33;35m"
cyan="\033[33;36m"
#OTHER
wait10="sleep 1"
process=$yellow
#IMPORTANT
username="anonymous"
password=""
install_dir=""
app_id=""
app_exe=""
done="echo $green[*] Done! "
steamCmd_web_location="http://media.steampowered.com/client/steamcmd_linux.tar.gz"

#PROGRAM

echo $cyan
echo "Starting Auto-SteamCMD"
echo $normal_color

echo "$process[>>] Please wait untill we install needed packages ('lib32gcc1' and 'dpkg --add-architecture i386'), this may require your password!$normal_color"
sudo apt-get update
echo "$green[>>] Running:$cyan sudo dpkg --add-architecture i386 $normal_color"
sudo dpkg --add-architecture i386
echo "$green[>>] Running:$cyan sudo apt-get install lib32gcc1 $normal_color"
sudo apt install lib32gcc1 -y

echo "$green[*] All packages successfully installed!"
echo $normal_color

if [ -z $install_dir ] 
then
	echo "$red[*] The directory can not be empty!!"
	echo "[*] The scipt is now terminated! Please re-run the scipt and specify the directory!"
	echo $normal_color
	exit
fi

if [ -z $app_id ] 
then
	echo "$red[*] The server id can not be empty!!"
	echo "[*] The scipt is now terminated! Please re-run the scipt and specify the server id!"
	echo $normal_color
	exit
fi

if [ -z $app_exe ] 
then
	echo "$red[*] The server executable can not be empty!!"
	echo "[*] The scipt is now terminated! Please re-run the scipt and specify the server executable!"
	echo $normal_color
	exit
fi

#CREATE TEMP DIRECTORY
echo "$process[>>] Creating /tmp/steamcmd Directory... $red"
mkdir -p /tmp/steamcmd
echo "$green[*] Directory created!"
cd /tmp/steamcmd
echo ""

#CONNECT TO STEAM SERVER AND GET THE LATEST 'steamcmd' FILES
echo "$process[>>] Connecting to Steam Server... $normal_color"
if ( ! wget $steamCmd_web_location ) then
echo "$red[*] The needed SteamCMD files cannot be downloaded at this moment."
echo "[*] Please try again later. $normal_color"
exit
else
echo "$green[*] All files were successfully downloaded! $normal_color"
fi
echo ""
$wait10

#EXTRACT JUST DOWNLOADED FILES
echo "$process[>>] Extracting the files ...$normal_color"
if (tar -xvzf steamcmd_linux.tar.gz) then
echo "$green[*] Files Extracted! $normal_color"
else
echo "$red[*] An Error has occured while extracting files. Please check that '$cyan steamcmd_linux.tar.gz $red' file exists. $normal_color"
exit
fi
echo ""
$wait10

#----------- PUT IF tar THEN ECHO ////

echo "$process[>>] Removing Temp Files... $red"
rm *.tar.gz
echo "$green[*] Temp files removed! $normal_color"
echo ""

echo "$process[>>] Setting up your server's directory... $red"
mkdir $install_dir
chmod +x $install_dir
echo "$green[*] Your new server's directory is '$install_dir'"
echo "[*] '$install_dir' - is case sensitive! $normal_color"

echo ""
# Move SteamCMD to user directory
echo "$process[>>] Moving SteamCMD files... $red"
mv /tmp/steamcmd/* ~/
$done
echo ""

echo "$process[>>] Cleaning up... $red"
rm -rf /tmp/steamcmd
$done
echo ""

#CREATING UPDATE SCRIPT
echo "$process[>>] Creating UPDATE sctipt: /update-$app_id.txt $red"
echo "//SERVER UPDATER SCTIPT FOR $install_dir
login $username $password
force_install_dir $install_dir
app_update $app_id validate
quit
" > /update-$app_id.txt 
echo ""


#CREATING STARTING SCTIPT
echo "$process[>>] Creating STARTING sctipt: /start_$app_id.sh $red"
echo "#!/bin/bash
clear
echo 'Starting your server...'
sleep 1
cd $install_dir

# Start Server
$app_exe
" > /start_$app_id.sh 
$done
echo ""

#CHANСHING PERMISIONS --------------------------------------------------------------------------
echo "$process[>>] Changing file permisions... (FILES: ~/start_$install_dir.sh, ~/updater/$install_dir.txt  > TO >  'chmod +x')"
chmod +x /start_$app_id.sh
chmod +x /update-$app_id.txt
$done
echo ""

#DOWNLOADING SERVER FROM STEAM --------------------------------------------------------------------------
echo "$process[>>] Starting the Installation Process... $normal_color"
sh ~/steamcmd.sh +login $username $password +force_install_dir $install_dir +app_update $app_id validate +quit
echo "$green[*] The server was successfully downloaded! $normal_color"
echo ""
