# To create multiple Masternodes on one VPS instance
1. you need to send 10,000 coins to a new address (or two new ones if you are doing 2)
2. you need more than one IP address (up to 3 on Vultr instances, some VPS providers offer more).
3. you need to edit some files through SSH and restart the server.
4. you need to download some files, copy some files and edit some files. Then you're done.

** This is the same procedure for the 3rd node as it is for the 2nd one **

## Step 1: make sure you have sent the coins for your new masternode(s) beforehand.
This takes 15 confirmations before you can activate new nodes. This procedure takes considerably less time than that so make sure you do the coin send beforehand so you don't waste any time waiting. Also, make sure you lock the wallet once you've done the send so you don't accidentally stake and break your inputs.


## Step 2: add more IPs to your instance (Using [Vultr](https://www.vultr.com/?ref=7396893) as an example)
Log into your VPS and click on the settings tab of your VPS. Next click on the "Additional IPv4" button to add one or two more IPs
![Image AddIP](https://github.com/AtheneumChain/Scripts/blob/master/images/AddIPs.png) </br>
</br>
Once that is done, DON'T restart the server from here - we have to do a few modifications from the console via SSH.
![Image IPadded](https://github.com/AtheneumChain/Scripts/blob/master/images/IPadded.png) </br>


## Step 3: Log into your VPS with SSH and mod some files

Once in the console, type:
```
sudo nano /etc/network/interfaces
```
enter your password when prompted and paste the following at the end of the file:

```
auto ens3:0
iface ens3:0 inet static
address 2nd_ip_address_here
netmask 255.255.255.0

auto ens3:1
iface ens3:1 inet static
address 3rd_ip_address_here
netmask 255.255.255.0
```
Replace ` 2nd_ip_address_here ` and ` 3rd_ip_address_here ` with the new IPs that Vultr assigned to you. In the example above, the full file would look like this:
```
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

#source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto ens3
iface ens3 inet dhcp
iface ens3 inet6 auto

auto ens3:0
iface ens3:0 inet static
address 108.61.245.238
netmask 255.255.255.0

auto ens3:1
iface ens3:1 inet static
address 149.28.40.167
netmask 255.255.255.0
```

then press CTRL-X, Y and ENTER to save and exit the file.

next restart the networking service or reboot the computer for the changes to take effect. Log back into the server via SSH to proceed to the next step
```
sudo reboot now
```
or
```
systemctl restart networking.service
```
## Step 4: ** AUTOMATIC METHOD ** Run the command below again for the automated installer OR skip to step 5 if you want to do it manually
```
cd ~ && wget https://raw.githubusercontent.com/AtheneumChain/Scripts/master/Masternode%20Setup/aeminstall.sh -O aeminstall.sh && chmod +x aeminstall.sh && ./aeminstall.sh
```
Follow the on screen prompts - don't continue to Step 5.

## Step 5: ** MANUAL METHOD ** Download a few utilities and clone the data 

Copy and paste this into your console session (SSH)
```
wget https://raw.githubusercontent.com/AtheneumChain/Scripts/master/infopage -O /usr/local/bin/infopage && chmod +x /usr/local/bin/infopage

wget -q https://raw.githubusercontent.com/AtheneumChain/Scripts/master/aem -O /usr/local/bin/aem && chmod +x /usr/local/bin/aem
```
The first utility (infopage) helps get information using the data folders without having to do several commands and formats them in an easy-to-understand manner.

The second one (aem) allows to interact with the nodes by specifying the datafolders

We're going to start by using the infopage utility to get the current block height
```
infopage Atheneum
```

1. Check the 'blocks' parameter and make sure it's the same as the AEM Discord bot OR the explorer OR your QT wallet. Press CTRL-C to exit
2. Get a new masternode genkey then shut down the daemon to prepare for copying
```
aem Atheneum masternode genkey
aem Atheneum stop
```
copy the masternode genkey, then do:
```
cp -r ~/.Atheneum ~/.Atheneum2
aem Atheneum start
```
Note that we restart the first node right after so it doesn't go missing. </br>

Next edit the config file for the copy and replace the info with your new IP address and masternode genkey:
```
nano ~/.Atheneum2/atheneum.conf
```
![Image Aemconf](https://github.com/AtheneumChain/Scripts/blob/master/images/aemconf.png) </br>

Press CTRL-X, Y and ENTER to save and exit.

Now if everything was edited properly, you should be able to start the node with:
```
aem Atheneum2 start
```
you can check the progress of the sync and the state of that instance by doing
```
infopage Atheneum2
```

All you need to do next is to activate that new node from your QT wallet.

