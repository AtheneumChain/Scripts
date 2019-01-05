# To create multiple Masternodes on one VPS instance
1. you need to send 10,000 coins to a new address (or two new ones if you are doing 2)
2. you need more than one IP address (up to 3 on Vultr instances, some VPS providers offer more).
3. you need to edit some files through SSH and restart the server.
4. you need to download some files, copy some files and edit some files. Then you're done.

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

next reboot the computer for the changes to take effect. Log back into the server via SSH to proceed to the next step
```
sudo reboot now
```

## Step 4: Download a few utilities and clone the data

(TO BE CONTINUED)
