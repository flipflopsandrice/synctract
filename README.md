# Synctract
Scripts to sync a remote folder and automatically extract archives.

*Note: This was developed for use on Synology devices.*

### Step 1: Exchange ssh pubkeys
On both your **remote** (user that you will ssh into) and **local** (user that will be running the script) machine (use default settings):
```
user1@local:~$mkdir ~/.ssh &&  touch ~/.ssh/authorized_keys && ssh-keygen
```
Upload pubkey to **remote**:
```
user1@local:~$ scp user2@remote:/home/user2/.ssh/id_rsa.pub /tmp/tmp_rsa_key && cat /tmp/tmp_rsa_key >> ~/.ssh/authorized_keys && rm /tmp/tmp_rsa_key
```
Download pubkey to **local**:
```
user1@local:~$ scp ~/.ssh/id_rsa.pub user2@remote:/tmp/tmp_rsa_key && ssh -X user2@remote 'cat /tmp/tmp_rsa_key >> ~/.ssh/authorized_keys && rm /tmp/tmp_rsa_key'
```
### Step 2: Configure
```
user1@local:~$ cd <path-to-synctract> && cp config-sample.cfg config.cfg
```
Editing the sample config to match your environments.

### Step 3: Cronjob

Use the system's crontab (or if available, edit your user's crontab through *`crontab -e`*):
```
vi /etc/crontab
```
And add the script to run whenever you like (*eg: every minute*):
```
*      *       *       *       *       root    /bin/sh /<path-to-script>/synctract.sh
```
**Note for Synology users**
Make sure to restart the cron service with:
```
/usr/syno/sbin/synoservicectl --restart crond
```