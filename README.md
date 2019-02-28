# Automated Masternode Setup
[click here](https://github.com/AtheneumChain/Scripts/tree/master/Masternode%20Setup)

# Atheneum Information Scriptlet 
to download:
```
cd ~ && wget https://raw.githubusercontent.com/AtheneumChain/Scripts/master/infopage -O /usr/local/bin/infopage && chmod +x /usr/local/bin/infopage
```

to execute the script:
```
infopage [datadir]
```
if datadir is excluded, it displays information for the first datadir (Atheneum)

examples:
```
infopage
infopage Atheneum
Infopage Atheneum2
```

# Atheneum command simplifier
to download:
```
wget -q https://raw.githubusercontent.com/AtheneumChain/Scripts/master/aem -O /usr/local/bin/aem && chmod +x /usr/local/bin/aem
```

to execute the script:
```
aem datadir command1 [arg1]
```
Examples:
```
aem Atheneum getinfo
aem Atheneum2 masternode status
```

# Atheneum Headless Binary updater 
### This script will update one or several nodes running on the same machine.
to download:
```
cd ~ && wget https://raw.githubusercontent.com/AtheneumChain/Scripts/master/updater.sh -O ./updater.sh && chmod +x ./updater.sh
```

to execute the script (if you need to launch it again for some reason):
```
cd ~
./updater.sh
```

# Atheneum Data Nuker for Headless Linux
### This script will reset the block data for your current folder
to download, navigate to your data directory you wish to nuke then:
```
wget https://raw.githubusercontent.com/AtheneumChain/Scripts/master/nuke -O ./nuke && chmod +x ./nuke
```

to execute the script:
```
./nuke
```

# Ubuntu QT dependencies Installer
### This script will install all of the necessary files for the Ubuntu QT wallet and/or headless binaries.
to download:
```
wget https://raw.githubusercontent.com/AtheneumChain/Scripts/master/UbuntuDepends.sh -O ./UbuntuDepends.sh && chmod +x ./UbuntuDepends.sh
```

to execute the script:
```
./UbuntuDepends.sh
```
