RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m'
    
    echo
    echo -ne "${BLUE}Installing Pre-requisites${NC}"
    echo
    #addid this for libdbcxx
    echo -ne "${GREEN} >Progress: ${BLUE}[###-----------]\r"
    sudo apt update && sudo apt upgrade -y > /dev/null 2>&1
    sudo apt install -y jq software-properties-common curl > /dev/null 2>&1
    if [ $? -ne 0 ]; then
       echo 
       echo -e "${RED}Install of ${YELLOW}software-properties-common ${RED}and {$YELLOW}curl ${RED}failed! ${NC}"
       echo -e "${YELLOW}This is most often caused by broken or misconfigured packages. Please try running:${NC}"
       echo -e "${GREEN}sudo dpkg --configure -a"
       echo -e "sudo apt update"
       echo -e "sudo apt upgrade${NC}"
       echo -e "${YELLOW}Then run this script again.${NC}"
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
