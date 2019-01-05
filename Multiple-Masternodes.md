# To create multiple Masternodes on one VPS instance
1. you need more than one IP address (up to 3 on Vultr instances, some VPS providers offer more).
2. you need to edit some files through SSH.
3. you need to restart the server.


## Step 1: add more IPs to your instance (Using [Vultr](https://www.vultr.com/?ref=7396893) as an example)
Log into your VPS and click on the settings tab of your VPS. Next click on the "Additional IPv4" button to add one or two more IPs
![Image AddIP](https://github.com/AtheneumChain/Scripts/blob/master/images/AddIP.png) </br>
Once that is done, DON'T restart the server from here - we have to do a few modifications from the console via SSH.
