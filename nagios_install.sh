sed -i 's/SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
getenforce
yum install -y epel-release git
yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils unzip httpd php gd gd-devel perl postfix
cd /tmp
git clone https://github.com/nasahmed12522/nagios_core_4.4.9.git
useradd nagios
useradd apache
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagcmd apache
cd /tmp/nagios_core_4.4.9/
tar xzf nagios-4.4.9.tar.gz; tar xzf nagios-plugins.tar.gz; tar xzf nagios-plugins-2.3.3.tar.gz 
cd /tmp/nagios_core_4.4.9/nagios-4.4.9/
./configure
make all
make install
make install-init
make install-commandmode
make install-config
make install-webconf
firewall-cmd --zone=public --add-port=80/tcp
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload
systemctl start httpd.service
systemctl start nagios.service
cd /tmp/nagios_core_4.4.9/nagios-plugins-2.3.3
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make all
service nagios restart
cd /tmp/nagios_core_4.4.9/nagios-plugins-release-2.3.3/
./tools/setup
chown nagios:nagcmd /usr/local/nagios/var/rw/
chown nagios:nagcmd /usr/local/nagios/var/rw/nagios.cmd
systemctl restart nagios.service
systemctl enable httpd.service
htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin n@123
