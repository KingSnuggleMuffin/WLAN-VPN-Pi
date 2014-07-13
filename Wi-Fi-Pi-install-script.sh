#!/bin/bash

#
# Wi-Fi-Pi-install-script.sh
# 
# @version    1.0 2014-07-13
# @copyright  Copyright (c) 2014 Martin Sauter, martin.sauter@wirelessmoves.com
# @license    GNU General Public License v2
# @since      Since Release 1.0
# 
# Installs and configures all necessary components
# for a Raspberry Pi to act as a Wi-Fi access point
# with backhaul over:
#
# a) Ethernet cable
# b) Wi-Fi, if a second USB device is connected
#
# For details see the project Wiki at:
#
#              https://github.com/martinsauter/WLAN-VPN-Pi/wiki
#
##############################################################################
# IMPORTANT: This script significantly changes the network configuration
# of eth0, wlan0 and wlan1 and a fair number of network configuration files.
# ONLY USE WITH A FRESH RASPBERRY PI IMAGE FILE
##############################################################################   
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU AFFERO GENERAL PUBLIC LICENSE
# License as published by the Free Software Foundation; either
# version 3 of the License, or any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU AFFERO GENERAL PUBLIC LICENSE for more details.
#
# You should have received a copy of the GNU Affero General Public
# License along with this library.  If not, see <http://www.gnu.org/licenses/>.


echo "#### Wi-Fi Pi Access Point and VPN Installation"
echo "###################################################"
echo ""

#### General Pi Setup
#### TO BE DONE MANUALLY BEFORE RUNNING THIS SCRIPT!!!

#sudo raspi-config --> change locale, etc.
#sudo apt-get update && sudo apt-get --yes upgrade
#sudo reboot

#### After the reboot install and configure all necessary components
#######################################################################

echo "###############################################################"
echo "IMPORTANT: The script requires you to change the Raspberry Pi"
echo "default password as otherwise the setup is not secure"
echo "###############################################################"

passwd pi

echo ""
echo "#### Unpacking configuration files"
echo "###############################################################"

tar xvzf wifipi.tar
cd ./configuration-files

echo ""
echo "done..."
echo ""

echo "#### Copying basic configuration for eth0, wlan0 and wlan1"
echo "###############################################################"

cp interfaces /etc/network/interfaces
cp wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf

echo ""
echo "done..."
echo ""


echo "#### Installing and configuring wlan0 as Wi-Fi AP"
echo "########################################################"

apt-get -y install hostapd

mkdir hostapd-install
cd hostapd-install

#precompiled hostapd for specific chipset
wget http://www.daveconroy.com/wp3/wp-content/uploads/2013/07/hostapd.zip
unzip -o hostapd.zip 
mv /usr/sbin/hostapd /usr/sbin/hostapd.bak
mv hostapd /usr/sbin/hostapd.edimax 
ln -sf /usr/sbin/hostapd.edimax /usr/sbin/hostapd 
chown root.root /usr/sbin/hostapd 
chmod 755 /usr/sbin/hostapd

cd ..

#copy access point configuration file
cp hostapd.conf /etc/hostapd/

#put a modified action_wpa.sh in lace to fix wpa supplicant misbehavior with two Wi-Fi interfaces
cp action_wpa.sh /etc/wpa_supplicant/action_wpa.sh

#autostart hostapd on system startup
cp hostapd /etc/default/hostapd

echo ""
echo "done..."
echo ""


echo "#### Installing and configuring the DHCP server to serve wlan0"
echo "###################################################################"

apt-get -y install hostapd isc-dhcp-server
cp dhcpd.conf /etc/dhcp/dhcpd.conf
cp isc-dhcp-server /etc/default/isc-dhcp-server

echo ""
echo "###### NOTE: The failure report above is o.k., it will work after rebooting... #####"
echo ""

echo ""
echo "done..."
echo ""


echo "#### Enabling ip packet routing between interfaces"
echo "########################################################"

cp sysctl.conf /etc/sysctl.conf

echo ""
echo "done..."
echo ""

echo "### Installing and configuring Dnsmasq as a local DNS server"
echo "##############################################################"

apt-get install -y dnsmasq
cp dnsmasq.conf /etc/dnsmasq.conf

echo ""
echo "done..."
echo ""


echo "### Installing the OpenVPN client service"
echo "###############################################"

apt-get -y install openvpn
cp ./openvpn/* /etc/openvpn

#disable openvpn client autostart
apt-get -y install chkconfig
chkconfig openvpn off

echo ""
echo "done..."
echo ""

#copy VPN start and stop batch files to upper directory
cp start* ..
cp stop* ..

echo ""
echo "#####################################################"
echo "The Wi-Fi Access Point configuration is as follows:"
echo ""

cat /etc/hostapd/hostapd.conf

echo ""
echo "#####################################################" 
echo ""

echo ""
echo "#####################################################"
echo "The network configuration of the Wi-Fi AP interface"
echo "(wlan0) is as follows"
echo ""

cat /etc/network/interfaces

echo ""
echo "#####################################################" 
echo ""

echo ""
echo "#####################################################"
echo "For details to start Internet access with or without"
echo "the VPN tunnel see the project Wiki at Github at"
echo ""
echo "  https://github.com/martinsauter/WLAN-VPN-Pi/wiki"
echo ""
echo "#####################################################" 
echo ""

echo "#########################################################"
echo "### and now reboot to make the changes come into effect"
echo "#########################################################"


