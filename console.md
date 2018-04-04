wget https://dl.google.com/go/go1.8.7.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.8.7.linux-amd64.tar.gz
mkdir -p /root/go/{bin,src}
yum -y install docker mercurial nodejs
systemctl enable docker
systemctl start docker
npm install -g bower
git clone https://github.com/openshift/origin-web-console.git
git clone https://github.com/openshift/origin-web-catalog.git
git clone https://github.com/openshift/origin-web-common.git
cd origin-web-console
git fetch origin pull/2929/head:kubevirt
cd ../origin-web-common
bower link --allow-root
cd ../origin-web-catalog
bower link --allow-root
cd ../origin-web-console
bower link origin-web-common --allow-root
bower link origin-web-catalog --allow-root
npm install -g grunt-cli
npm install grunt
grunt build
cd /root/go/src
git clone https://github.com/openshift/origin-web-console-server.git
cd origin-web-console-server
curl https://glide.sh/get | sh
glide install
CONSOLE_REPO_PATH=/root/origin-web-console make vendor-console
OS_BUILD_ENV_PRESERVE=_output/local/bin hack/env make build-images
