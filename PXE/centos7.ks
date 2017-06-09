#Perform Install not upgrade
install

#Text mode Install
text

%pre

#change to tty6 to get input
exec < /dev/tty6 > /dev/tty6 2> /dev/tty6
chvt 6

#Get hostname
echo "Type Hostname :"
read NAME

#Get IP
echo "Enter IP address :"
read ADDR

#Get Gateway
echo "Enter Gateway :"
read GW

#build /etc/sysconfig/network
echo "NETWORKING=yes" > network
echo "HOSTNAME=${NAME}" >> network
echo "GATEWAY=${GW}" >> network
echo "${NAME}" > hostname

#build /etc/sysconfig/network-scripts/ifcfg-ens192
echo "DEVICE=ens192" > ifcfg-ens192
echo "BOOTPROTO=none" >> ifcfg-ens192
echo "IPV6INIT=no" >> ifcfg-ens192
echo "MTU=1500" >> ifcfg-ens192
echo "NM_CONTROLLED=no" >> ifcfg-ens192
echo "ONBOOT=yes" >> ifcfg-ens192
echo "TYPE=Ethernet" >> ifcfg-ens192
echo "IPADDR=${ADDR}" >> ifcfg-ens192
echo "NETMASK=255.255.255.0" >> ifcfg-ens192

#change back to tty1 and continue script
chvt 1
exec < /dev/tty1 > /dev/tty1 2> /dev/tty1
%end

#syystem authorization information
auth --enableshadow --passalgo=sha512

#Install method
#cdrom
url --url ftp://192.168.10.14/pub/centos7/

# Keyboard layouts
keyboard --vckeymap=fr --xlayouts='fr'

# System language
lang en_GB.UTF-8

# Root password
rootpw --iscrypted XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# System services
services --enabled="chronyd"

# System timezone
timezone Europe/Paris --isUtc --ntpservers=dns1.pixhome.local
user --groups=wheel --name=user1 --password=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --iscrypted --gecos="user1"

# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
autopart --type=lvm

# Partition clearing information
clearpart --none --initlabel

#network
network --device=ens192 --bootproto=dhcp

#Reboot after installation
reboot

%packages
@^infrastructure-server-environment
@base
@compat-libraries
@core
chrony
kexec-tools

%end
%post --nochroot
/usr/sbin/ntpdate -sub europe.pool.ntp.org
chkconfig ntpd on

#Force Network from %pre
cp network /mnt/sysimage/etc/sysconfig/network
. /mnt/sysimage/etc/sysconfig/network

#Force Hostname
cp hostname /mnt/sysimage/etc/hostname

#copy prebuilt ifcfg-ens192 script to set IP
cp ifcfg-ens192 /mnt/sysimage/etc/sysconfig/network-scripts/ifcfg-ens192

%end
