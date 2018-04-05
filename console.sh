PATCHID="2929"
PATCHBRANCH="kubevirt"
yum -y install docker mercurial nodejs wget git
wget https://dl.google.com/go/go1.8.7.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.8.7.linux-amd64.tar.gz
mkdir -p /root/go/{bin,src}
echo 'export GOPATH=/root/go' >> .bashrc
echo 'export GOBIN=$GOPATH/bin' >> .bashrc
echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> .bashrc
export GOPATH=/root/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin:$GOBIN
systemctl enable docker
systemctl start docker
npm install -g bower
curl https://glide.sh/get | sh
cd /root/go/src
git clone https://github.com/openshift/origin-web-console.git
git clone https://github.com/openshift/origin-web-catalog.git
git clone https://github.com/openshift/origin-web-common.git
cd origin-web-catalog
git checkout v3.9.0
bower link --allow-root
cd ../origin-web-catalog
bower link --allow-root
cd ../origin-web-console
git fetch origin pull/$PATCHID/head:$PATCHBRANCH
git checkout kubevirt
cd ../origin-web-common
bower link --allow-root
cd ../origin-web-catalog
bower link --allow-root
cd ../origin-web-console
make install
bower link origin-web-common --allow-root
bower link origin-web-catalog --allow-root
npm install -g grunt-cli
npm install grunt
grunt build
cd /root/go/src
git clone https://github.com/openshift/origin-web-console-server.git
cd origin-web-console-server
git checkout v3.9.0
#glide up -v
CONSOLE_REPO_PATH=/root/go/src/origin-web-console make vendor-console
OS_BUILD_ENV_PRESERVE=_output/local/bin hack/env make build-images
# docker login
# docker push 
