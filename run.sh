#!/bin/bash

GITDIR="https://ghproxy.com/https://github.com"
PKGDIR="pkg"

quit() {
    echo "Error $1"
    exit
}

conf() {
	echo  "deb https://mirrors.aliyun.com/kali kali-rolling main non-free contrib
deb-src https://mirrors.aliyun.com/kali kali-rolling main non-free contrib " > /etc/apt/sources.list

    mkdir -p  ~/.pip
    echo "[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn" > ~/.pip/pip.conf

    wget archive.kali.org/archive-key.asc || quit "archive-key"
    apt-key add archive-key.asc
    apt-get update
    mkdir -p ${PKGDIR}

    #frp config
    echo "[common]
#remote vps addr
server_addr = YOUR-IP
server_port =  64447
tls_enable = true
pool_count = 5

[plugin_socks54328]
type = tcp
remote_port = 54328
plugin = socks5
use_encryption = true" > frpc.sample.ini


    echo "[common]
bind_addr = 0.0.0.0
bind_port = 64447

dashboard_port = 7500
dashboard_user = admin1" > frps.sample.ini
}

install_system() {
    apt-get install -y golang || quit "install_software"
    go env -w GOPROXY=https://goproxy.cn,direct 
}

install() {
    path=$1
    name=$(basename $1)

    wget $path -O ${PKGDIR}/${name} || quit "$name"
}

install_software() {
#package
    install ${GITDIR}/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
    install ${GITDIR}/fatedier/frp/releases/download/v0.45.0/frp_0.45.0_linux_amd64.tar.gz
    install ${GITDIR}/fatedier/frp/releases/download/v0.45.0/frp_0.45.0_windows_amd64.zip
    install ${GITDIR}/shadow1ng/fscan/releases/download/1.8.2/fscan64.exe
    install ${GITDIR}/shadow1ng/fscan/releases/download/1.8.2/fscan_amd64 
    install ${GITDIR}/0x727/ObserverWard/releases/download/v2023.9.18/observer_ward_v2023.9.18_x86_64-unknown-linux-musl.tar.gz

#collect package
    install ${GITDIR}/b1gcat/hackhelper/releases/download/v1.0.1/cf
    install ${GITDIR}/b1gcat/hackhelper/releases/download/v1.0.1/cs4.2.zip
    install ${GITDIR}/b1gcat/hackhelper/releases/download/v1.0.1/godzilla.jar
    install ${GITDIR}/b1gcat/hackhelper/releases/download/v1.0.1/shiro_attack-4.5.3-SNAPSHOT-all.jar
    install ${GITDIR}/b1gcat/hackhelper/releases/download/v1.0.1/Behinder_v3.0_Beta_11.t00ls.zip
    install ${GITDIR}/b1gcat/hackhelper/releases/download/v1.0.1/Multiple.Database.Utilization.Tools.-.v2.0.7.zip
    install ${GITDIR}/b1gcat/hackhelper/releases/download/v1.0.1/jdk1.8.0_191.tar
    install ${GITDIR}b1gcat/hackhelper/releases/download/v1.0.1/httpsserv.go
    install ${GITDIR}b1gcat/hackhelper/releases/download/v1.0.1/mimikatz_trunk_Win32.zip
    install ${GITDIR}b1gcat/hackhelper/releases/download/v1.0.1/mimikatz_trunk_x64.zip

    #https://docs.xray.cool/#/scenario/reverse
    #https://stack.chaitin.com/tool/index
    install ${GITDIR}/chaitin/xpoc/releases/download/0.0.8/xpoc_linux_amd64.zip
}

#afl
install_afl() {
    mkdir docker_arl
    wget -O docker_arl/docker.zip ${GITDIR}/TophantTechnology/ARL/releases/download/v2.5.5/docker.zip
    cd docker_arl
    unzip -o docker.zip
    docker-compose pull
    docker volume create arl_db
    docker-compose up -d
}   

install_awvs() {
    #用户名:admin@admin.com
    #密码:Admin123
    docker run -it -d -p 13443:3443 --cap-add LINUX_IMMUTABLE secfa/docker-awvs
}

conf
install_system
install_software
install_afl
