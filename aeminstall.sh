
#!/bin/bash
#Masternode Installer script by chris, 2018.
#exec >/dev/null
# still shows the prompt
#exec 2>/dev/null
# now the prompt is gone, too

# restore stdout
#exec >/dev/tty
# restore stderr
#exec 2>/dev/tty

VERSION="1.1.23"
PROJECT="Atheneum"
PROJECT_FOLDER="$HOME/Atheneum"
DAEMON_BINARY="atheneumd"
CLI_BINARY="atheneum-cli"

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m'

printf '\e[48;5;0m'
clear

function checks() 
{
  if [[ ($(lsb_release -d) != *16.04*) ]]; then
      echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
      exit 1
  fi

  if [[ $EUID -ne 0 ]]; then
     echo -e "${RED}$0 must be run as root.${NC}"
     exit 1
  fi
}

function check_existing()
{
  echo
  echo -e "${BLUE}Checking for existing nodes and available IPs...${NC}"
  echo
  #Get list and count of IPs
  IP_LIST=$(ifconfig | grep "inet " | awk {'print $2'} | grep -vE '127.0.0|192.168|172.16|10.0.0' | tr -d 'inet addr:')
  IP_NUM=$(echo "$IP_LIST" | wc -l)

  #Get number of existing masternode directories
  DIR_COUNT=$(ls -la /root/ | grep "\.atheneum" | grep -c '^')
  
  #Check if there are more IPs than existing nodes
  if [[ $DIR_COUNT -ge $IP_NUM ]]; then
    echo -e "${RED}Not enough available IP addresses to run another node! Please add other IPs to this VPS first.${NC}"
    exit 1
  fi

  echo -e "${YELLOW}Found ${BLUE} $DIR_COUNT ${YELLOW} $PROJECT Masternodes and ${BLUE} $IP_NUM ${YELLOW} IP addresses.${NC}"

  #Now confirm available IPs by removing those that are already bound to 22555
  IP_IN_USE=$(netstat -tulpn | grep :22000 | awk {'print $4'})
  
  echo -e "${RED}IMPORTANT - ${YELLOW} please make sure you don't select an IP that is already in use! ${RED}- IMPORTANT${NC}"
  echo -e "${BLUE}IP List using port 22000 (Active Atheneum nodes):${NC}"
  echo $IP_IN_USE
  echo
  echo -e "${GREEN}List of all IPs on this machine${NC}"
  echo $IP_LIST
  echo
  read -e -p "$(echo -e ${BLUE}Please enter the IP address you wish to use: ${NC})" NEXT_AVAIL_IP
  echo
  echo -e "${YELLOW}Using ${BLUE} $NEXT_AVAIL_IP${NC}"
  echo
  read -e -p "Continue with installation? [Y/N] : " CHOICE
  if [[ ("$CHOICE" == "n" || "$CHOICE" == "N") ]]; then
    exit 1;
  fi
  
  #Get masternode.conf data to create new entry for QT wallet
  echo
  echo -e "${YELLOW}Masternode Transaction Information for masternode.conf in the QT Wallet${NC}"
  echo -e "For this section, you will need the debug console of your QT wallet by going to ${GREEN}Tools ${NC}then ${GREEN}Debug Console.${NC}"
  echo -e "When executing the command ${GREEN}masternode outputs${NC}, you will see the following information:"
  echo -e "{"
  echo -e "  \"${RED}b672c35585500a0221e726de710a3de8caadb9624b60f3bdefbfc71e0a4e78ab${NC}\": \"${YELLOW}1${NC}\","
  echo -e "}"
  echo -e "The ${RED}first part${NC} is your TXid and the ${YELLOW}second part${NC} is your TXOutput"
  echo -e "${BLUE}Please enter the TXid for your new masternode generated in the debug console via ${YELLOW}masternode outputs ${NC}"
  read -e -p " : " TX_ID
  echo
  echo -e "${BLUE}Please enter the TXOutput for that transaction generated in the debug console via ${YELLOW}masternode outputs ${NC}[0/1]"
  read -e -p " : " TX_OUT
  echo
  read -e -p "$(echo -e ${BLUE}Please enter the Alias for your new masternode : ${NC})" MN_ALIAS
  
  if [[ $DIR_COUNT -gt 0 ]]; then
    DIR_NUM=$((DIR_COUNT+1))
  fi
}

function set_environment()
{
  DATADIR="$HOME/.Atheneum$DIR_NUM"

  TMP_FOLDER=$(mktemp -d)
  RPC_USER="$PROJECT-Admin"
  MN_PORT=22000
  RPC_PORT=$((15647+DIR_NUM))

  DAEMON="$PROJECT_FOLDER/$DAEMON_BINARY"
  STARTCLI="$PROJECT_FOLDER/$CLI_BINARY"
  CONF_FILE="$DATADIR/atheneum.conf"
  CLI="$PROJECT_FOLDER/$CLI_BINARY -conf=$CONF_FILE -datadir=$DATADIR"
  DAEMON_START="$DAEMON -datadir=$DATADIR -conf=$CONF_FILE -daemon"
  CRONTAB_LINE="@reboot sleep 30; $DAEMON_START"
}

function show_header()
{
  clear
  echo -e "${RED}■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■${NC}"
  echo -e "${YELLOW}$PROJECT Masternode Installer v$VERSION - chris 2018"
  echo -e "${RED}■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■${NC}"
  echo
  echo -e "${BLUE}This script will automate the installation of your ${YELLOW}$PROJECT ${BLUE}masternode along with the server configuration."
  echo -e "It will:"
  echo
  echo -e " ${YELLOW}■${NC} Create a swap file"
  echo -e " ${YELLOW}■${NC} Prepare your system with the required dependencies"
  echo -e " ${YELLOW}■${NC} Obtain the latest $PROJECT masternode files from the official $PROJECT repository"
  echo -e " ${YELLOW}■${NC} Automatically generate the Masternode Genkey (and display at the end)"
  echo -e " ${YELLOW}■${NC} Automatically generate the .conf file"
  echo -e " ${YELLOW}■${NC} Add Brute-Force protection using fail2ban"
  echo -e " ${YELLOW}■${NC} Update the system firewall to only allow SSH, the masternode ports and outgoing connections"
  echo -e " ${YELLOW}■${NC} Add a schedule entry for the service to restart automatically on power cycles/reboots."
  echo
  echo -e " ${RED}WARNING!!! ${BLUE}If you are already running one or more $PROJECT Masternode(s) on this machine, make sure they are running before executing this script!!! ${NC}"
  echo
}

function create_swap()
{
  echo
  echo -e "${BLUE}Creating Swap... (ignore errors, this might not be supported)${NC}"
  fallocate -l 3G /swapfile > /dev/null 2>&1
  chmod 600 /swapfile > /dev/null 2>&1
  mkswap /swapfile > /dev/null 2>&1
  swapon /swapfile > /dev/null 2>&1
  echo
  echo -e "/swapfile none swap sw 0 0 \n" >> /etc/fstab > /dev/null 2>&1
}

function install_prerequisites()
{
  if [ "$IS_INSTALLED" = true ]; then
      echo -e "${BLUE} Skipping pre-requisites..."
  else
    echo
    echo -ne "${BLUE}Installing Pre-requisites${NC}"
    echo
    #addid this for libdbcxx
    echo -ne "${GREEN} >Progress: ${BLUE}[###-----------]\r"
    sudo apt install -y jq software-properties-common curl > /dev/null 2>&1
    if [ $? -ne 0 ]; then
       echo 
       echo -e "${RED}Install of ${YELLOW}software-properties-common ${RED}and {$YELLOW}curl ${RED}failed! ${NC}"
       exit 1;
    fi
    sudo apt update > /dev/null 2>&1
    echo -ne "${GREEN} >Progress: ${BLUE}[#####---------]\r"
    sudo apt install -y pwgen build-essential libssl-dev libboost-all-dev libqrencode-dev libminiupnpc-dev libevent-2.0-5 > /dev/null 2>&1
    if [ $? -ne 0 ]; then
       echo 
       echo -e "${RED}Install of ${YELLOW}libmini, build-essential ${RED}and {$YELLOW}libevent ${RED}failed! ${NC}"
       exit 1;
    fi
    echo -ne "${GREEN} >Progress: ${BLUE}[#######-------]\r"
    sudo add-apt-repository -y ppa:bitcoin/bitcoin > /dev/null 2>&1
    if [ $? -ne 0 ]; then
       echo 
       echo -e "${RED}Adding ${YELLOW}BITCOIN PPA ${RED}failed! ${NC}"
       exit 1;
    fi
    sudo apt update > /dev/null 2>&1
    echo -ne "${GREEN} >Progress: ${BLUE}[##########----]\r"
    sudo apt install -y jq libdb4.8-dev libdb4.8++-dev > /dev/null 2>&1
    if [ $? -ne 0 ]; then
       echo 
       echo -e "${RED}Install of ${YELLOW}libdb4.8 libraries ${RED}failed! ${NC}"
       exit 1;
    fi
    echo -ne "${GREEN} >Progress: ${BLUE}[############--]${NC}\r"
    #end libdbcxx section
  
    sudo apt install -y jq libzmq5 libboost-system1.58.0 libboost-filesystem1.58.0 libboost-program-options1.58.0 libboost-thread1.58.0 libboost-chrono1.58.0 libminiupnpc10 libevent-pthreads-2.0-5 unzip > /dev/null 2>&1
    if [ $? -ne 0 ]; then
       echo 
       echo -e "${RED}Install of ${YELLOW}libboost ${RED}and {$YELLOW}extra files ${RED}failed! ${NC}"
       exit 1;
    fi
    echo -ne "${GREEN} >Progress: ${BLUE}[##############]${NC}"
    echo
  fi
}

function copy_binaries()
{
  #check if version is current before copying binaries
    #deleting previous install folders in case of failed install attempts. Also ensures latest binaries are used
    rm -rf $PROJECT_FOLDER
    echo
    echo -e "${BLUE}Copying Binaries...${NC}"
    mkdir $PROJECT_FOLDER
    cd $PROJECT_FOLDER
    wget -q https://github.com/AtheneumChain/Atheneum/releases/download/v1.0.0.1/Ubuntu16.04-Headless_1.0.0.1.zip -O ./ubuntu.zip
    unzip -o ubuntu.zip
    
    if [ $? -ne 0 ]; then
       echo 
       echo -e "${RED}Getting latest binaries failed!${NC}"
       exit 1;
    fi
    
    chmod +x atheneum{d,-cli}
    if [ ! -f '/usr/local/bin/aem' ]; then
      wget -O /usr/local/bin/aem https://raw.githubusercontent.com/zaemliss/installers/master/atheneum/aem > /dev/null 2>&1
      chmod +x /usr/local/bin/aem > /dev/null 2>&1
      echo "alias aem='/usr/local/bin/aem'" >> ~/.bashrc > /dev/null 2>&1
      . ~/.bashrc
    fi

  if [ -f $DAEMON ]; then
      mkdir $DATADIR
      echo -e "${BLUE}Starting daemon ...(5 seconds)${NC}"
      echo -e "${YELLOW}Ignore any errors you see below. (5 seconds)${NC}"
      $DAEMON -daemon > /dev/null 2>&1
      PASSWORD=$(pwgen -s 64 1)
      sleep 10
      $STARTCLI stop
cat <<EOF > $CONF_FILE
rpcuser=$RPC_USER
rpcpassword=$PASSWORD
EOF
      sleep 3
      $DAEMON -daemon > /dev/null 2>&1
      sleep 10
  else
      echo -e "${RED}Binary not found! Please scroll up to see errors above : $RETVAL ${NC}"
      exit 1;
  fi
  sleep 3
  . ~/.bashrc
}

function create_conf_file()
{
  echo
  GENKEY=$($STARTCLI masternode genkey)
  echo
  echo -e "${BLUE}Creating conf file...${NC}"
  echo -e "${YELLOW}Ignore any errors you see below. (5 seconds)${NC}"
  sleep 5
  echo
  echo -e "${BLUE}Stopping the daemon and writing config (5 seconds)${NC}"
  $STARTCLI stop
  sleep 5
  
cat <<EOF > $CONF_FILE
rpcuser=$RPC_USER
rpcpassword=$PASSWORD
rpcport=$RPC_PORT
server=1
daemon=1
logintimestamps=1
maxconnections=256
bind=$NEXT_AVAIL_IP
externalip=$NEXT_AVAIL_IP:$MN_PORT
masternode=1
masternodeprivkey=$GENKEY

#Addnodes
addnode=node0.emberchain.xyz
addnode=node1.emberchain.xyz
addnode=node2.emberchain.xyz
addnode=node3.emberchain.xyz

EOF
}

function configure_firewall()
{
  echo
  echo -e "${BLUE}setting up firewall...${NC}"
  sudo apt-get install -y ufw > /dev/null 2>&1
  sudo apt-get update -y > /dev/null 2>&1
  
  #configure ufw firewall
  sudo ufw default allow outgoing > /dev/null 2>&1
  sudo ufw default deny incoming > /dev/null 2>&1
  sudo ufw allow ssh/tcp > /dev/null 2>&1
  sudo ufw limit ssh/tcp > /dev/null 2>&1
  sudo ufw allow $MN_PORT/tcp > /dev/null 2>&1
  sudo ufw logging on > /dev/null 2>&1
  echo "y" | sudo ufw enable > /dev/null 2>&1
}

function add_cron()
{
(crontab -l; echo "$CRONTAB_LINE") | crontab -
}

function start_wallet()
{
  
  echo
  echo -e "${BLUE}Re-Starting the wallet...${NC}"
  if [ -f $DAEMON ]; then
    echo
    echo -e "${RED}Make ${YELLOW}SURE ${RED}you copy this masternode line for your QT wallet (Windows/Mac wallet):"
    echo
    echo -e "${GREEN}$MN_ALIAS $NEXT_AVAIL_IP:$MN_PORT $GENKEY $TX_ID $TX_OUT ${NC}"
    echo
    echo -e "${BLUE}If you are using Putty, just select the text. It will automatically go to your clipboard.${NC}"
    echo -e "${BLUE}If you are using SSH, use CTRL-INSERT / CTRL-V${NC}"
    echo
    echo -e "Paste this in your masternode.conf file (accessed via ${GREEN}Tools ${NC}then ${GREEN}Open Masternode Configuration File${NC})"
    echo
    echo -e "${YELLOW}Typing the key out incorrectly is 99% of all installation issues. ${NC}"
    echo
    echo -e "${GREEN}Save the masternode.conf file, restart the QT wallet and press any key to continue to syncronisation steps.${NC}"
    read -n 1 -s -r -p " "
    echo
    echo
    echo -e "${BLUE}Now wait for a full synchro (can take 5-10 minutes)${NC}"
    echo -e "${BLUE}Once Synchronized, you will be prompted to go back to your Windows/Mac wallet,${NC}"
    echo -e "${BLUE}and perform one more operation.${NC}"
    echo
    echo
    $DAEMON_START
    echo -e "${BLUE}Starting Synchronization...${NC}"
    sleep 3
    APIBLOCKS=$(curl -s http://explorer.atheneumchain.io/api/getblockcount)
    CURBLOCK=$($CLI getinfo | jq .blocks)

    echo -ne "${YELLOW}Current Block: ${GREEN}$APIBLOCKS${NC}\n\n"
    echo -ne "${BLUE} >syncing${YELLOW} $CURBLOCK ${BLUE}out of${YELLOW} $APIBLOCKS ${BLUE}...${NC} \r"
    while [[ $CURBLOCK -lt $APIBLOCKS ]]; do
      CURBLOCK=$($CLI getinfo | jq .blocks)
      echo -ne "${BLUE} >syncing${YELLOW} $CURBLOCK ${BLUE}out of${YELLOW} $APIBLOCKS ${BLUE}...${NC} \r"
      sleep 2
    done
    echo
    
    MNSTATUS=$($CLI mnsync status | jq .RequestedMasternodeAssets)
    while [ "$MNSTATUS" != 999 ]; do
      GETSYNC=$($CLI mnsync status)
      MNSYNC=$(echo $GETSYNC | jq .RequestedMasternodeAssets | tr -d '\"')
      MNSTATUS=$($CLI mnsync status | jq .RequestedMasternodeAssets)
      MNSTAGE=$(echo $GETSYNC | jq .RequestedMasternodeAttempt)
      echo -ne "${YELLOW} >Masternode Sync Stage: ${BLUE}$MNSYNC ${YELLOW}attempt [${GREEN}$MNSTAGE of 8${YELLOW}]                \r"
      sleep 2
    done
    
    TXSTATUS=$($CLI getrawtransaction $TX_ID 1 | jq .confirmations) > /dev/null 2>&1
    while (( TXSTATUS < 1 )); do
      echo -ne "${YELLOW} >Waiting for the transaction to appear on the blockchain...${YELLOW}                \r"
      sleep 15
    done
    
    while (( TXSTATUS < 15 )); do
      TXSTATUS=$($CLI getrawtransaction $TX_ID 1 | jq .confirmations) > /dev/null 2>&1
      echo -ne "${YELLOW} >Transaction Confirmation: ${BLUE}$TXSTATUS of 15${YELLOW}]                \r"
      sleep 15
    done
    
    echo
    echo -e "${YELLOW}After pressing any key to continue below, go to the masternodes tab / my masternodes in your QT wallet and Start Alias on your new node.${NC}"
    echo -e "${YELLOW}The command prompt will return once your node is started. If the Status goes to Expired in your QT wallet, please start alias again.${NC}"
    read -n 1 -s -r -p "Press any key to continue"
    echo
    MNSTATUS=$($CLI masternode debug)
    echo -e "${YELLOW} >Masternode Status : ${BLUE}Waiting for remote Activation....${NC}"
    while [ "$MNSTATUS" != "Masternode successfully started" ]; do
      MNSTATUS=$($CLI masternode debug)
      sleep 2
    done
    echo
    echo -e "${YELLOW} >Masternode Status : ${BLUE}Masternode Activated!"
    echo
    echo -e "${BLUE}Congratulations, you've set up your masternode!${NC}"
    echo    
    echo -e "${BLUE}Type ${YELLOW}aem.sh <data directory> <command> ${BLUE} to interact with your server(s). ${NC}"
    echo -e "${BLUE}Ex: ${GREEN}aem.sh atheneum2 masternode status ${NC}"
    echo

    
  else
    RETVAL=$?
    echo -e "${RED}Binary not found! Please scroll up to see errors above : $RETVAL ${NC}"
    exit 1
  fi
}

function cleanup()
{
    echo -e "${YELLOW}finalizing...${NC}" 
}

function deploy()
{
  checks
  show_header
  check_existing
  set_environment
  create_swap
  install_prerequisites
  copy_binaries
  create_conf_file
  configure_firewall
  add_cron
  start_wallet
  cleanup
}

deploy
