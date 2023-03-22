## Disable SELinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled' /etc/selinux/config
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
cat /etc/selinux/config
setenforce 0
getenforce

## Configure EPEL Repository
yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm 
yum install -y git gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils unzip httpd php gd gd-devel perl postfix
yum install -y perl-Net-SNMP
cd /tmp
git clone https://github.com/nasahmed12522/nagios_core_4.4.9.git


## Create Nagios user and group
useradd apache
groupadd nagcmd
groupadd nagios
useradd -g nagios -G nagcmd nagios
usermod -aG nagcmd apache


## Change directory path into extracted package and installation

cd /tmp/nagios_core_4.4.9/
tar xzf nagios-4.4.9.tar.gz; tar xzf nagios-plugins.tar.gz; tar xzf nagios-plugins-2.3.3.tar.gz 
cd /tmp/nagios_core_4.4.9/nagios-4.4.9/
./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-commandmode
make install-config
make install-exfoliation
make install-webconf


## Add Firewall rule to allow http and https
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

## Enable and start httpd & nagios services
systemctl start httpd.service
systemctl enable httpd.service
systemctl start nagios
systemctl enable nagios

## Verify the Nagios config
/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

cd /tmp/nagios_core_4.4.9/nagios-plugins-2.3.3

./configure --with-nagios-user=nagios --with-nagios-group=nagcmd
make
make install


## Verify the plugins in below path
cd /usr/local/nagios/libexec/
ls

service nagios restart
cd /tmp/nagios_core_4.4.9/nagios-plugins-release-2.3.3/
./tools/setup
chown nagios:nagcmd /usr/local/nagios/var/rw/
chown nagios:nagcmd /usr/local/nagios/var/rw/nagios.cmd
systemctl restart nagios.service

htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin n@123
