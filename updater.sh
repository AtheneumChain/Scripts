#!/bin/bash

ver="1.0.2"
PROJECT="Atheneum"
DATAFOLDER=".Atheneum"
CONFIG="atheneum.conf"
PROJECT_FOLDER="$HOME/Atheneum"
DAEMON_BINARY="atheneumd"
CLI_BINARY="atheneum-cli"
REPO="https://github.com/AtheneumChain/Atheneum/releases"

echo -e "${red} Checking Version ...${clear}"
getcurrent=$(curl -q wget https://raw.githubusercontent.com/AtheneumChain/Scripts/master/versions | jq .updater | tr -d '"') > /dev/null 2>&1
if ! [[ $ver == $getcurrent ]]; then
  echo -e "${red} Version outdated! Downloading new version ...${clear}"
  wget https://raw.githubusercontent.com/AtheneumChain/Scripts/master/updater -O ./updater.sh > /dev/null 2>&1
  chmod +x ./updater.sh
  sleep 2
  exec "./updater.sh"
fi

red='\033[1;31m'
grn='\033[1;32m'
yel='\033[1;33m'
blu='\033[1;36m'
clr='\033[0m'

printf '\e[48;5;0m'
clear

echo -e "${yel}Searching for $PROJECT binaries and installation directories...${clr}"
echo
client=$(find / -name $CLI_BINARY | head -n 1) > /dev/null 2>&1
workDir=$(dirname "$client")

echo -e "${blu}Found ${yel}$client ${blu}in ${yel}$workDir ...${clr}"
sleep 2
#Get number of existing masternode directories
DIR_COUNT=$(ls -la /root/ | grep "\$DATAFOLDER" | grep -c '^')

if [[ $DIR_COUNT -lt 1 ]]; then
  echo -e "${red}No data directories found! Please make sure you have $PROJECT Masternodes installed on this server.${clr}"
  exit 1;
fi
echo -e "${grn}$PROJECT binaries found in $workDir .${clr}"
echo -e "${blu}$DIR_COUNT $PROJECT installations found!${clr}"
echo

echo -e "${grn}Stopping Daemon using datadir /$DATAFOLDER"
$client -datadir=/root/$DATAFOLDER -conf=/root/$DATAFOLDER/$CONFIG stop

if [[ $DIR_COUNT -gt 1 ]]; then
  for i in `seq 2 $DIR_COUNT`; 
    do 
      echo -e "${grn}Stopping Daemon using datadir $DATAFOLDER$i"
      $client -datadir=/root/$DATAFOLDER$i -conf=/root/$DATAFOLDER$i/$CONFIG stop
    done
fi
echo

echo -e "${blu}Downloading new binaries...${clr}"
sleep 15
echo
rm $workDir/$DAEMON_BINARY
rm $workDir/$CLI_BINARY

wget -q https://github.com/AtheneumChain/Atheneum/releases/download/Latest/Ubuntu16.04-Headless_Latest.zip -O $workDir/ubuntu.zip
unzip -o $workDir/ubuntu.zip

chmod +x $workDir/$DAEMON_BINARY $workDir/$CLI_BINARY
echo -e "${grn}Starting Daemon using datadir /$DATAFOLDER"
$workDir/$DAEMON_BINARY -datadir=/root/$DATAFOLDER -conf=/root/$DATAFOLDER/$CONFIG -daemon

if [[ $DIR_COUNT -gt 1 ]]; then
  for i in `seq 2 $DIR_COUNT`; 
    do 
      echo -e "${grn}Starting Daemon using datadir /$DATAFOLDER$i"
      $workDir/$DAEMON_BINARY -datadir=/root/$DATAFOLDER$i -conf=/root/$DATAFOLDER$i/$CONFIG -daemon
    done
fi
echo

echo -e "${blu}Update complete. $PROJECT now updated to version below.${yel}"
$workDir/$DAEMON_BINARY -datadir=/root/$DATAFOLDER$i -conf=/root/$DATAFOLDER$i/$CONFIG --version | head -n 1
echo
echo -e "${red} !!! IMPORTANT !!! ${grn}"
echo -e "Don't forget to update your QT wallet with the latest executables. \nYou can find them at the official repo at:"
echo -e "${blu}$REPO${clr}"
echo

