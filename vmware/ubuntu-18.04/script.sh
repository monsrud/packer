#!/bin/bash


#
# Provision system
#
apt update -y
apt upgrade -y
apt install apache2
apt install nfs-utils
