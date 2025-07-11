#!/bin/bash

# 安全工具安装脚本
# 此脚本用于在Ubuntu/Debian系统上安装多种安全测试工具

# 定义颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # 恢复默认颜色

# 固定使用GitHub官方地址
GITHUB_PREFIX="https://github.com"

# 显示欢迎信息
echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}        安全工具自动安装脚本 v1.6${NC}"
echo -e "${BLUE}=============================================${NC}"
echo

# 检查是否以root权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}错误: 此脚本需要root权限运行。请使用sudo执行。${NC}"
    exit 1
fi

# 创建工具目录
TOOLS_DIR="$HOME/security-tools"
mkdir -p "$TOOLS_DIR"
cd "$TOOLS_DIR" || exit

# 配置pip镜像源
config_pip_mirror() {
    echo -e "${YELLOW}[*] 配置pip使用清华大学镜像源...${NC}"
    mkdir -p ~/.pip
    cat > ~/.pip/pip.conf << EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
EOF
    echo -e "${GREEN}[✓] pip镜像源配置完成${NC}"
}

# 更新系统
update_system() {
    echo -e "${YELLOW}[*] 更新系统包索引...${NC}"
    apt-get update -y || { echo -e "${RED}更新包索引失败${NC}"; exit 1; }
    echo -e "${GREEN}[✓] 系统包索引更新完成${NC}"
    
    # 配置pip镜像源
    config_pip_mirror
    
    # 升级系统
    echo -e "${YELLOW}[*] 升级系统软件...${NC}"
    apt-get upgrade -y || { echo -e "${RED}系统升级失败${NC}"; exit 1; }
    echo -e "${GREEN}[✓] 系统软件升级完成${NC}"
}

# 安装依赖
install_dependencies() {
    echo -e "${YELLOW}[*] 安装必要的依赖包...${NC}"
    apt-get install -y git wget unzip tar gpg curl python3-pip || { echo -e "${RED}安装依赖失败${NC}"; exit 1; }
    echo -e "${GREEN}[✓] 依赖安装完成${NC}"
}

# 定义工具安装函数

# 安装WhatWeb
install_whatweb() {
    echo -e "${YELLOW}[*] 正在安装WhatWeb...${NC}"
    apt-get install -y whatweb || { echo -e "${RED}安装WhatWeb失败${NC}"; return 1; }
    echo -e "${GREEN}[✓] WhatWeb安装完成${NC}"
}

# 安装Interactsh和Nuclei
install_nuclei() {
    echo -e "${YELLOW}[*] 正在安装Interactsh和Nuclei...${NC}"
    
    # 创建目录
    mkdir -p nuclei && cd nuclei || return 1
    
    # 下载Interactsh
    wget -q "${GITHUB_PREFIX}/projectdiscovery/interactsh/releases/download/v1.2.4/interactsh-server_1.2.4_linux_amd64.zip" || { echo -e "${RED}下载Interactsh失败${NC}"; cd ..; return 1; }
    unzip -q -o interactsh-server_1.2.4_linux_amd64.zip || { echo -e "${RED}解压Interactsh失败${NC}"; cd ..; return 1; }  # -o自动覆盖
    chmod +x interactsh-server
    mv interactsh-server /usr/local/bin/ || { echo -e "${RED}移动Interactsh失败${NC}"; cd ..; return 1; }
    
    # 下载Nuclei
    wget -q "${GITHUB_PREFIX}/projectdiscovery/nuclei/releases/download/v3.4.7/nuclei_3.4.7_linux_amd64.zip" || { echo -e "${RED}下载Nuclei失败${NC}"; cd ..; return 1; }
    unzip -q -o nuclei_3.4.7_linux_amd64.zip || { echo -e "${RED}解压Nuclei失败${NC}"; cd ..; return 1; }  # -o自动覆盖
    chmod +x nuclei
    mv nuclei /usr/local/bin/ || { echo -e "${RED}移动Nuclei失败${NC}"; cd ..; return 1; }
    
    # 清理
    cd ..
    rm -rf nuclei
    echo -e "${GREEN}[✓] Interactsh和Nuclei安装完成${NC}"
}

# 安装RustScan
install_rustscan() {
    echo -e "${YELLOW}[*] 正在安装RustScan...${NC}"
    
    # 创建目录
    mkdir -p rustscan && cd rustscan || return 1
    
    # 下载RustScan
    wget -q "${GITHUB_PREFIX}/bee-san/RustScan/releases/download/2.4.1/x86_64-linux-rustscan.tar.gz.zip" || { echo -e "${RED}下载RustScan失败${NC}"; cd ..; return 1; }
    unzip -q -o x86_64-linux-rustscan.tar.gz.zip || { echo -e "${RED}解压RustScan失败${NC}"; cd ..; return 1; }  # -o自动覆盖
    tar -xzf x86_64-unknown-linux-musl/rustscan-2.4.1-x86_64-unknown-linux-musl.tar.gz || { echo -e "${RED}解压RustScan tar包失败${NC}"; cd ..; return 1; }
    chmod +x rustscan
    mv rustscan /usr/local/bin/ || { echo -e "${RED}移动RustScan失败${NC}"; cd ..; return 1; }
    
    # 清理
    cd ..
    rm -rf rustscan
    echo -e "${GREEN}[✓] RustScan安装完成${NC}"
}

# 安装Gobuster
install_gobuster() {
    echo -e "${YELLOW}[*] 正在安装Gobuster...${NC}"
    
    # 创建目录
    mkdir -p gobuster && cd gobuster || return 1
    
    # 下载Gobuster
    if [ "$(uname -m)" = "x86_64" ]; then
        wget -q "${GITHUB_PREFIX}/OJ/gobuster/releases/download/v3.7.0/gobuster_Linux_amd64.tar.gz" || { echo -e "${RED}下载Gobuster失败${NC}"; cd ..; return 1; }
    else
        wget -q "${GITHUB_PREFIX}/OJ/gobuster/releases/download/v3.7.0/gobuster_Linux_arm64.tar.gz" || { echo -e "${RED}下载Gobuster失败${NC}"; cd ..; return 1; }
    fi
    
    tar -xzf gobuster_Linux_*_amd64.tar.gz || { echo -e "${RED}解压Gobuster失败${NC}"; cd ..; return 1; }
    chmod +x gobuster
    mv gobuster /usr/local/bin/ || { echo -e "${RED}移动Gobuster失败${NC}"; cd ..; return 1; }
    
    # 清理
    cd ..
    rm -rf gobuster
    echo -e "${GREEN}[✓] Gobuster安装完成${NC}"
}

# 安装SQLMap
install_sqlmap() {
    echo -e "${YELLOW}[*] 正在安装SQLMap...${NC}"
    git clone -q "${GITHUB_PREFIX}/sqlmapproject/sqlmap.git" || { echo -e "${RED}克隆SQLMap仓库失败${NC}"; return 1; }
    ln -s "$TOOLS_DIR/sqlmap/sqlmap.py" /usr/local/bin/sqlmap || { echo -e "${RED}创建SQLMap符号链接失败${NC}"; return 1; }
    echo -e "${GREEN}[✓] SQLMap安装完成${NC}"
}

# 下载SecLists字典
install_seclists() {
    echo -e "${YELLOW}[*] 正在下载SecLists字典...${NC}"
    git clone -q "${GITHUB_PREFIX}/danielmiessler/SecLists.git" || { echo -e "${RED}克隆SecLists仓库失败${NC}"; return 1; }
    echo -e "${GREEN}[✓] SecLists字典下载完成${NC}"
}

# 安装WAFW00F
install_wafw00f() {
    echo -e "${YELLOW}[*] 正在安装WAFW00F...${NC}"
    apt-get install -y wafw00f || { echo -e "${RED}安装WAFW00F失败${NC}"; return 1; }
    echo -e "${GREEN}[✓] WAFW00F安装完成${NC}"
}

# 安装Metasploit
install_metasploit() {
    echo -e "${YELLOW}[*] 正在安装Metasploit Framework...${NC}"
    
    # 添加Metasploit仓库
    curl -s https://apt.metasploit.com/metasploit-framework.gpg.key | gpg --dearmor > metasploit.gpg || { echo -e "${RED}下载Metasploit GPG密钥失败${NC}"; return 1; }
    mv metasploit.gpg /usr/share/keyrings/ || { echo -e "${RED}移动Metasploit GPG密钥失败${NC}"; return 1; }
    echo "deb [signed-by=/usr/share/keyrings/metasploit.gpg] http://apt.metasploit.com/ buster main" | tee /etc/apt/sources.list.d/metasploit.list || { echo -e "${RED}添加Metasploit仓库失败${NC}"; return 1; }
    
    # 更新并安装
    apt-get update -y || { echo -e "${RED}更新包索引失败${NC}"; return 1; }
    apt-get install -y metasploit-framework || { echo -e "${RED}安装Metasploit失败${NC}"; return 1; }
    
    # 初始化数据库（可选）
    read -p "是否初始化Metasploit数据库？(y/N): " init_db
    if [[ "$init_db" =~ ^[Yy]$ ]]; then
        msfdb init || echo -e "${YELLOW}[!] 数据库初始化失败，请手动执行'msfdb init'${NC}"
    fi
    
    echo -e "${GREEN}[✓] Metasploit Framework安装完成${NC}"
}

# 安装frp
install_frp() {
    echo -e "${YELLOW}[*] 正在安装frp...${NC}"
    
    # 创建目录
    mkdir -p frp && cd frp || return 1
    
    # 确定系统架构
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        FRP_ARCH="amd64"
    elif [[ "$ARCH" = *"arm"* || "$ARCH" = *"aarch64"* ]]; then
        FRP_ARCH="arm64"
    else
        echo -e "${RED}不支持的系统架构: $ARCH${NC}"
        cd ..
        return 1
    fi
    
    # 下载并安装frp
    echo -e "${YELLOW}[*] 下载frp for Linux...${NC}"
    wget -q "${GITHUB_PREFIX}/fatedier/frp/releases/download/v0.63.0/frp_0.63.0_linux_${FRP_ARCH}.tar.gz" || { echo -e "${RED}下载frp失败${NC}"; cd ..; return 1; }
    tar -xzf frp_0.63.0_linux_${FRP_ARCH}.tar.gz || { echo -e "${RED}解压frp失败${NC}"; cd ..; return 1; }
    mv frp_0.63.0_linux_${FRP_ARCH} frp_linux_${FRP_ARCH}
    
    # 复制二进制文件
    cp frp_linux_${FRP_ARCH}/frps /usr/local/bin/
    cp frp_linux_${FRP_ARCH}/frpc /usr/local/bin/
    
    # 创建配置目录
    mkdir -p /etc/frp
    
    # 复制配置文件
    cp frp_linux_${FRP_ARCH}/frps.ini /etc/frp/
    cp frp_linux_${FRP_ARCH}/frpc.ini /etc/frp/
    
    # 创建systemd服务文件
    cat > /etc/systemd/system/frps.service << EOF
[Unit]
Description=frp server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frps -c /etc/frp/frps.ini
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    cat > /etc/systemd/system/frpc.service << EOF
[Unit]
Description=frp client
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/frpc -c /etc/frp/frpc.ini
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    
    # 重载systemd
    systemctl daemon-reload
    
    # 下载Windows版本供参考
    echo -e "${YELLOW}[*] 下载frp for Windows (供参考)...${NC}"
    wget -q "${GITHUB_PREFIX}/fatedier/frp/releases/download/v0.63.0/frp_0.63.0_windows_amd64.zip" || { echo -e "${RED}下载Windows版frp失败${NC}"; cd ..; return 1; }
    unzip -q -o frp_0.63.0_windows_amd64.zip -d frp_windows_amd64 || { echo -e "${RED}解压Windows版frp失败${NC}"; cd ..; return 1; }  # -o自动覆盖
    
    # 清理
    cd ..
    echo -e "${GREEN}[✓] frp安装完成${NC}"
    echo -e "${BLUE}[!] 请根据需要编辑配置文件: /etc/frp/frps.ini 或 /etc/frp/frpc.ini${NC}"
    echo -e "${BLUE}[!] 使用命令 'systemctl start frps' 或 'systemctl start frpc' 启动服务${NC}"
}

# 安装gost
install_gost() {
    echo -e "${YELLOW}[*] 正在安装gost...${NC}"
    
    # 创建目录
    mkdir -p gost && cd gost || return 1
    
    # 确定系统架构
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        GOST_ARCH="amd64"
    elif [[ "$ARCH" = *"arm"* || "$ARCH" = *"aarch64"* ]]; then
        GOST_ARCH="arm64"
    else
        echo -e "${RED}不支持的系统架构: $ARCH${NC}"
        cd ..
        return 1
    fi
    
    # 下载并安装gost
    echo -e "${YELLOW}[*] 下载gost for Linux...${NC}"
    wget -q "${GITHUB_PREFIX}/ginuerzh/gost/releases/download/v2.12.0/gost_2.12.0_linux_${GOST_ARCH}.tar.gz" || { echo -e "${RED}下载gost失败${NC}"; cd ..; return 1; }
    tar -xzf gost_2.12.0_linux_${GOST_ARCH}.tar.gz || { echo -e "${RED}解压gost失败${NC}"; cd ..; return 1; }
    
    # 复制二进制文件
    cp gost /usr/local/bin/ || { echo -e "${RED}复制gost二进制文件失败${NC}"; cd ..; return 1; }
    
    # 创建配置目录
    mkdir -p /etc/gost
    
    # 创建systemd服务文件
    cat > /etc/systemd/system/gost.service << EOF
[Unit]
Description=GO Simple Tunnel
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/gost -C /etc/gost/config.yaml
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    
    # 创建默认配置文件
    cat > /etc/gost/config.yaml << EOF
# GOST默认配置文件
# 更多配置示例请参考: https://github.com/ginuerzh/gost/blob/master/config/config_example.yaml

# 监听HTTP代理
services:
  - name: http-proxy
    addr: :8080
    handler:
      type: http
    listener:
      type: tcp

# 转发规则
chains:
  - name: direct
    hops:
      - name: hop0
        nodes:
          - name: direct
            addr: :0
            connector:
              type: direct
            dialer:
              type: direct
EOF
    
    # 重载systemd
    systemctl daemon-reload
    
    # 清理
    cd ..
    echo -e "${GREEN}[✓] gost安装完成${NC}"
    echo -e "${BLUE}[!] 配置文件位于: /etc/gost/config.yaml${NC}"
    echo -e "${BLUE}[!] 使用命令 'systemctl start gost' 启动服务${NC}"
    echo -e "${BLUE}[!] 使用命令 'systemctl enable gost' 设置开机自启${NC}"
}

# 安装所有工具
install_all_tools() {
    update_system
    install_dependencies
    install_whatweb
    install_nuclei
    install_rustscan
    install_gobuster
    install_sqlmap
    install_seclists
    install_wafw00f
    install_metasploit
    install_frp
    install_gost
}

# 主菜单
echo -e "${BLUE}请选择要执行的操作:${NC}"
echo -e "${YELLOW}1)${NC} 安装所有工具"
echo -e "${YELLOW}2)${NC} 安装单个工具"
echo -e "${YELLOW}3)${NC} 仅更新系统并配置pip镜像"
echo -e "${YELLOW}4)${NC} 退出"
read -p "请输入选项 [1-4]: " choice

case "$choice" in
    1)
        install_all_tools
        ;;
    2)
        echo -e "${BLUE}请选择要安装的工具:${NC}"
        echo -e "${YELLOW}1)${NC} WhatWeb"
        echo -e "${YELLOW}2)${NC} Interactsh + Nuclei"
        echo -e "${YELLOW}3)${NC} RustScan"
        echo -e "${YELLOW}4)${NC} Gobuster"
        echo -e "${YELLOW}5)${NC} SQLMap"
        echo -e "${YELLOW}6)${NC} SecLists字典"
        echo -e "${YELLOW}7)${NC} WAFW00F"
        echo -e "${YELLOW}8)${NC} Metasploit Framework"
        echo -e "${YELLOW}9)${NC} frp"
        echo -e "${YELLOW}10)${NC} gost"
        read -p "请输入选项 [1-10]: " tool_choice
        
        # 确保系统已更新并安装依赖
        update_system
        install_dependencies
        
        case "$tool_choice" in
            1) install_whatweb ;;
            2) install_nuclei ;;
            3) install_rustscan ;;
            4) install_gobuster ;;
            5) install_sqlmap ;;
            6) install_seclists ;;
            7) install_wafw00f ;;
            8) install_metasploit ;;
            9) install_frp ;;
            10) install_gost ;;
            *) echo -e "${RED}无效选项${NC}" ;;
        esac
        ;;
    3)
        update_system
        install_dependencies
        echo -e "${GREEN}[✓] 系统已更新，pip已配置使用清华大学镜像源${NC}"
        ;;
    4)
        echo -e "${BLUE}已退出安装程序${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}无效选项${NC}"
        exit 1
        ;;
esac

# 安装完成信息
echo
echo -e "${BLUE}=============================================${NC}"
echo -e "${GREEN}操作已完成！${NC}"
echo -e "${BLUE}工具已安装到: ${TOOLS_DIR}${NC}"
echo -e "${BLUE}=============================================${NC}"
