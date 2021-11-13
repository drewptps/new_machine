#!/bin/bash

#Check for root
if [ "$(whoami)" != root ]; then
    echo "THIS SCRIPT MUST BE RUN AS ROOT!"
    exit 1
fi

#Add user drew
echo "Adding user drew..."
sleep 1s
useradd --create-home --shell bash drew
echo "Enter password for account drew:"
passwd drew
usermod -aG sudo drew

#Remove snapd
if dpkg -l snapd &> /dev/null; then
    echo "Removing snapd..."
    sleep 1s
    systemctl stop snapd
    apt remove --purge --assume-yes snapd gnome-software-plugin-snap
    rm -rf ~/snap/
    rm -rf /var/cache/snapd/
elif ! dpkg -l snapd &> /dev/null; then
    echo "Skipping snapd... does not exist"
fi

#Remove cloud-init
if dpkg -l cloud-init &> /dev/null; then
    echo "Removing cloud-init..."
    sleep 1s
    apt purge cloud-init -y
    rm -rf /etc/cloud
    rm -rf /var/lib/cloud/
elif ! dpkg -l cloud-init &> /dev/null; then
    echo "Skipping cloud-init... does not exist."
fi

#Remove cloud-init
if [ "$(cat /etc/timezone)" != US/Eastern ]; then
    echo "Setting timezone US/Eastern..."
    sleep 1s
    timedatectl set-timezone US/Eastern
elif [ "$(cat /etc/timezone)" = US/Eastern ]; then
    echo "Skipping timezone... already US/Eastern."
fi

#Import SSH keys
if dpkg -l ssh-import-gh &> /dev/null; then
    echo "Importing SSH keys from GitHub..."
    sleep 1s
    ssh-import-gh petipas
elif ! dpkg -l ssh-import-gh &> /dev/null; then
    echo "Skipping SSH key import..."
fi

#Remove news from motd
if [ -f "/etc/default/motd-news" ]; then
    echo "Removing motd news..."
    sleep 1s
    sed 's/ENABLED=1/ENABLED=0/' /etc/default/motd-news
else
    echo "Skipping motd-news..."
fi