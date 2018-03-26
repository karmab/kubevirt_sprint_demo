yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion atomic-openshift-utils atomic-openshift-excluder atomic-openshift-docker-excluder docker python-ipaddress
yum -y install NetworkManager 
systemctl enable NetworkManager
systemctl start NetworkManager
atomic-openshift-excluder unexclude
atomic-openshift-docker-excluder unexclude
sed -i "s@# INSECURE_REGISTRY=.*@INSECURE_REGISTRY='--insecure-registry 172.30.0.0/16'@" /etc/sysconfig/docker
echo -e "DEVS=/dev/vdb\nVG=dockervg" > /etc/sysconfig/docker-storage-setup
rm -rf /etc/sysconfig/docker-storage
docker-storage-setup
systemctl enable docker
systemctl start docker
yum -y update
yum -y install centos-release-openshift-origin centos-release-gluster epel-release
