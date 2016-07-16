#!/bin/sh

###########################################
## Backs up all MySQL databases on the host
###########################################

# Backup Directory
MBD="/home/username/mysql_backups"

# Get hostname
HOST="$(hostname)"

# Set MySQL Username, Password, and host
MyUSER="usernameGoesHere"
MyPASS="passwordGoesHere"
MyHOST="localhost"

# Get current date for use in archive filename
NOW="$(date +"%m-%d-%Y-%T")"

# Command to show databases
DBS="$(mysql -u $MyUSER -h $MyHOST -p$MyPASS -Bse 'show databases')"

# Command used by rsync to use the password-less private key
SSHCOMMAND="ssh -i /home/username/.ssh/id_rsa"

# Remote host and directory that we will be syncing archives to.
REMOTEDIR="remotehost:/home/username/mysql_backups"

#  Loop through Databases
for db in $DBS
do
   MYSQLARCHIVE="$MBD/$db.$HOST.$NOW.gz"
   mysqldump -u $MyUSER -h $MyHOST -p$MyPASS --skip-add-locks --complete_insert $db | gzip -9 > $MYSQLARCHIVE
done

# Send a copy offsite
#  Note that you will need to generate an SSH key without a password
#  See https://macnugget.org/projects/publickeys/ for how to do this.
rsync -aq -e "$SSHCOMMAND" $MBD $REMOTEDIR

# Remove old archives older than 24 hours
#find $MBD* -mtime +2 -exec rm {} \;
