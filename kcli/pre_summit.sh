setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=permissive/" /etc/selinux/config
yum -y install httpd qemu-img
systemctl enable httpd
systemctl start httpd
