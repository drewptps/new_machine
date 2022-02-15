#!/bin/bash

#Check for root
if [ "$(whoami)" != root ]; then
    echo "THIS SCRIPT MUST BE RUN AS ROOT!"
    exit 1
fi


#Add user drew
if ![ id drew &>/dev/null ]; then
	echo "Adding user drew..."
	sleep 1s
	useradd --create-home --shell /usr/bin/bash drew
	passwd -e drew
	usermod -aG sudo drew
else
	echo "Skipping useradd... user drew already exists"
fi

#Add group petipas
if [ $(getent group petipas) ]; then
	echo "Skipping groupadd... group petipas already exists"
else
	echo "Adding group petipas..."
	groupadd petipas
fi

#Add drew to petipas, delete group drew, changes permissions of /home/drew
if [ $(id -gn drew) != petipas ]; then
	echo "Changing primary group for drew to petipas"
	usermod -g petipas drew
else
	echo "Skipping primary group... drew's primary group is already petipas"
fi

#Change permissions of /home/drew
if [ $(stat -c %G /home/drew) != petipas ]; then
	echo "Changing group for /home/drew to petipas"
	chgrp -R petipas /home/drew
else
	echo "Skipping permissions... /home/drew already belongs to group petipas"
fi

#Delete group drew
if [ $(getent group drew) ]; then
	echo "Deleting group drew"
	groupdel drew &> /dev/null
else
	echo "Skipping groupdel... group drew doesn't exist"
fi



#Remove snapd
if [ dpkg -l snapd &> /dev/null ]; then
    echo "Removing snapd..."
    sleep 1s
    systemctl stop snapd
    apt remove --purge --assume-yes snapd gnome-software-plugin-snap
    rm -rf ~/snap/
    rm -rf /var/cache/snapd/
else
    echo "Skipping snapd... does not exist"
fi

#Remove cloud-init
if [ dpkg -l cloud-init &> /dev/null ]; then
    echo "Removing cloud-init..."
    sleep 1s
    apt purge cloud-init -y
    rm -rf /etc/cloud
    rm -rf /var/lib/cloud/
else
    echo "Skipping cloud-init... does not exist."
fi

#Remove cloud-init
if [ "$(cat /etc/timezone)" != US/Eastern ]; then
    echo "Setting timezone US/Eastern..."
    sleep 1s
    timedatectl set-timezone US/Eastern
else
    echo "Skipping timezone... already US/Eastern."
fi

#Import SSH keys
if [ dpkg -l ssh-import-id-gh &> /dev/null ]; then
    echo "Importing SSH keys from GitHub..."
    sleep 1s
    ssh-import-id-gh petipas
else
    echo "Skipping SSH key import..."
fi

#Remove news from motd
if [ -f "/etc/default/motd-news" &> /dev/null ]; then
    echo "Removing motd news..."
    sleep 1s
    sed -n 's/ENABLED=1/ENABLED=0/' /etc/default/motd-news
    systemctl restart motd-news
else
    echo "Skipping motd-news..."
fi
