#!/bin/bash

# Create home dir and update vsftpd user db:
mkdir -p /home/vsftpd
chown -R ftp:ftp /home/vsftpd

# use '>' is ok, only one user
echo -e "${FTP_USER}\n${FTP_PASS}" > /etc/vsftpd/virtual_users.txt
db_load -T -t hash -f /etc/vsftpd/virtual_users.txt /etc/vsftpd/virtual_users.db

# Set passive mode parameters:
if [ "$PASV_ADDRESS" = "REQUIRED" ]; then
    echo "Please insert IPv4 address of your host"
    exit 1
fi

if [ ! -f "/etc/vsftpd/boot_from_image" ]; then 
    # if host server reboot , this script will run, and .....you know
    # so add a flag
    touch "/etc/vsftpd/boot_from_image"
    echo "pasv_address=${PASV_ADDRESS}" >> /etc/vsftpd/vsftpd.conf
    ## Set passive ports range
    echo "pasv_min_port=${PASV_MIN_PORT}" >> /etc/vsftpd/vsftpd.conf
    echo "pasv_max_port=${PASV_MAX_PORT}" >> /etc/vsftpd/vsftpd.conf
fi 

# Run vsftpd:
vsftpd /etc/vsftpd/vsftpd.conf



