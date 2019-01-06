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
cd ~ && wget https://raw.githubusercontent.com/AtheneumChain/Scripts/master/update.sh -O ./update.sh && chmod +x ./update.sh
```

to execute the script:
```
./update.sh
```
