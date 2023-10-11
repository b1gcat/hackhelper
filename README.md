# 一键脚本

```bash
echo  "deb https://mirrors.aliyun.com/kali kali-rolling main non-free contrib
deb-src https://mirrors.aliyun.com/kali kali-rolling main non-free contrib " > /etc/apt/sources.list

wget archive.kali.org/archive-key.asc
apt-key add archive-key.asc
apt-get update

apt-get install -y golang
go env -w GOPROXY=https://goproxy.cn,direct 

#package
wget https://ghproxy.com/https://github.com/ginuerzh/gost/releases/download/v2.11.5/gost-linux-amd64-2.11.5.gz
wget https://ghproxy.com/https://github.com/fatedier/frp/releases/download/v0.45.0/frp_0.45.0_linux_amd64.tar.gz
wget https://ghproxy.com/https://github.com/fatedier/frp/releases/download/v0.45.0/frp_0.45.0_windows_amd64.zip
wget https://ghproxy.com/https://github.com/shadow1ng/fscan/releases/download/1.8.2/fscan64.exe
wget https://ghproxy.com/https://github.com/shadow1ng/fscan/releases/download/1.8.2/fscan_amd64 

#collect package
wget https://ghproxy.com/https://github.com/b1gcat/hackhelper/releases/download/v1.0.1/cf

#frp config
echo "[common]
#remote vps addr
server_addr = 47.100.100.12
server_port =  64447
tls_enable = true
pool_count = 5

[plugin_socks54328]
type = tcp
remote_port = 54328
plugin = socks5
use_encryption = true" > c.ini


echo "[common]
bind_addr = 0.0.0.0
bind_port = 64447

dashboard_port = 7500
dashboard_user = admin1" > s.ini


#https://github.com/chaitin/xpoc/
wget https://ghproxy.com/https://github.com/chaitin/xpoc/releases/download/0.0.8/xpoc_linux_amd64.zip
unzip xpoc_linux_amd64.zip
./xpoc_linux_amd64 up

#afl
mkdir docker_arl
wget -O docker_arl/docker.zip https://ghproxy.com/github.com/TophantTechnology/ARL/releases/download/v2.5.5/docker.zip
cd docker_arl
unzip -o docker.zip
docker-compose pull
docker volume create arl_db
docker-compose up -d
```



# 常用命令

```bash
nohup ./gost -L=admin:woshitiancaixxx@:12306&
```



# 账号

```yaml
securitytrails: # 网站 https://securitytrails.com/
api_key: v94C1s0xgSR21tbSJsOV9G5rk6vpMuf3

virustotal: # 网站 https://www.virustotal.com/gui/
api_key: e657597e3ee430033c36c89b5ed9f9b04f4c039b888aa5f5c9e12697f63cb11e

zoomeye:
api_key: 53F4dEdF-216F-b528d-8EfE-3E9c8a5e26e

ceye: #http://ceye.io/:
qvn0kc.ceye.io
```



#    

