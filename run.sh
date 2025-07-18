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
GITHUB_PREFIX="https://book1.dpdns.org"

# 无限重试函数
retry_forever() {
    local cmd="$1"
    local name="$2"
    local retries=0

    echo -e "${YELLOW}[*] 开始安装 $name (将无限重试直到成功)${NC}"

    while true; do
        retries=$((retries+1))
        echo -e "${YELLOW}[*] 尝试 $retries: ${NC}$cmd"

        # 执行命令
        if eval "$cmd"; then
            echo -e "${GREEN}[✓] $name 安装成功${NC}"
            return 0
        else
            echo -e "${RED}[!] 尝试 $retries 失败${NC}"

            # 清理残留文件
            if [ -n "$3" ]; then
                echo -e "${YELLOW}[*] 清理残留文件: $3${NC}"
                rm -rf $3
            fi

            # 等待5秒再重试
            echo -e "${YELLOW}[*] 5秒后将再次尝试...${NC}"
            sleep 5
        fi
    done
}

# 显示欢迎信息
echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}        安全工具自动安装脚本 v2.0 (优化版)${NC}"
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
    retry_forever "apt-get install -y whatweb" "WhatWeb"
}

# 安装Interactsh和Nuclei
install_nuclei() {
    # 创建并清理目录
    local module_dir="nuclei"
    echo -e "${YELLOW}[*] 清理 $module_dir 目录...${NC}"
    rm -rf "$module_dir"
    mkdir -p "$module_dir" && cd "$module_dir" || return 1

    # 下载并安装Interactsh（显示进度）
    cmd="wget --progress=bar:force ${GITHUB_PREFIX}/projectdiscovery/interactsh/releases/download/v1.2.4/interactsh-server_1.2.4_linux_amd64.zip && \
         unzip -q -o interactsh-server_1.2.4_linux_amd64.zip && \
         chmod +x interactsh-server && \
         mv interactsh-server /usr/local/bin/"

    retry_forever "$cmd" "Interactsh" "interactsh-server_1.2.4_linux_amd64.zip" || { cd ..; return 1; }

    # 下载并安装Nuclei（显示进度）
    cmd="wget --progress=bar:force ${GITHUB_PREFIX}/projectdiscovery/nuclei/releases/download/v3.4.7/nuclei_3.4.7_linux_amd64.zip && \
         unzip -q -o nuclei_3.4.7_linux_amd64.zip && \
         chmod +x nuclei && \
         mv nuclei /usr/local/bin/"

    retry_forever "$cmd" "Nuclei" "nuclei_3.4.7_linux_amd64.zip" || { cd ..; return 1; }

    # 清理
    cd ..
    rm -rf "$module_dir"
}

# 安装RustScan
install_rustscan() {
    # 创建并清理目录
    local module_dir="rustscan"
    echo -e "${YELLOW}[*] 清理 $module_dir 目录...${NC}"
    rm -rf "$module_dir"
    mkdir -p "$module_dir" && cd "$module_dir" || return 1

    # 下载并安装RustScan（显示进度）
    cmd="wget --progress=bar:force ${GITHUB_PREFIX}/bee-san/RustScan/releases/download/2.4.1/x86_64-linux-rustscan.tar.gz.zip && \
         unzip -q -o x86_64-linux-rustscan.tar.gz.zip && \
         gzip -d x86_64-linux-rustscan.tar.gz && \
         tar xf x86_64-linux-rustscan.tar && \
         chmod +x rustscan && \
         mv rustscan /usr/local/bin/"

    retry_forever "$cmd" "RustScan" "x86_64-linux-rustscan.tar.gz.zip" || { cd ..; return 1; }

    # 清理
    cd ..
    rm -rf "$module_dir"
}

# 安装Gobuster
install_gobuster() {
    # 创建并清理目录
    local module_dir="gobuster"
    echo -e "${YELLOW}[*] 清理 $module_dir 目录...${NC}"
    rm -rf "$module_dir"
    mkdir -p "$module_dir" && cd "$module_dir" || return 1

    # 确定下载链接和文件名
    local DOWNLOAD_URL="${GITHUB_PREFIX}/OJ/gobuster/releases/download/v3.7.0/gobuster_Linux_x86_64.tar.gz"
    local FILE_NAME=$(basename "$DOWNLOAD_URL")

    # 下载并安装Gobuster（显示进度，规范gz解压流程）
    cmd="wget --progress=bar:force $DOWNLOAD_URL && \
         gzip -d $FILE_NAME && \
         tar xf ${FILE_NAME%.gz} && \
         chmod +x gobuster && \
         mv gobuster /usr/local/bin/"

    retry_forever "$cmd" "Gobuster" "$FILE_NAME" || { cd ..; return 1; }

    # 清理
    cd ..
    rm -rf "$module_dir"
}

# 安装SQLMap（使用wget下载压缩包）
install_sqlmap() {
    # 清理目录
    local module_dir="sqlmap"
    local zip_file="sqlmap-master.zip"
    echo -e "${YELLOW}[*] 清理 $module_dir 目录和压缩包...${NC}"
    rm -rf "$module_dir" "$zip_file"

    # 下载并解压sqlmap
    cmd="wget --progress=bar:force ${GITHUB_PREFIX}/sqlmapproject/sqlmap/archive/refs/heads/master.zip -O $zip_file && \
         unzip -q -o $zip_file && \
         mv sqlmap-master $module_dir"

    retry_forever "$cmd" "sqlmap" "$zip_file $module_dir"
}

# 下载SecLists字典（使用wget下载压缩包）
install_seclists() {
    # 清理目录
    local module_dir="SecLists"
    local zip_file="SecLists-master.zip"
    echo -e "${YELLOW}[*] 清理 $module_dir 目录和压缩包...${NC}"
    rm -rf "$module_dir" "$zip_file"

    # 下载并解压SecLists
    cmd="wget --progress=bar:force ${GITHUB_PREFIX}/danielmiessler/SecLists/archive/refs/heads/master.zip -O $zip_file && \
         unzip -q -o $zip_file && \
         mv SecLists-master $module_dir"

    retry_forever "$cmd" "SecLists" "$zip_file $module_dir"
}

# 安装WAFW00F
install_wafw00f() {
    retry_forever "apt-get install -y wafw00f" "WAFW00F"
}

# 安装Metasploit
install_metasploit() {
    # 清理残留文件
    echo -e "${YELLOW}[*] 清理Metasploit残留文件...${NC}"
    rm -rf "metasploit.gpg"

    # 添加Metasploit仓库（显示curl进度）
    cmd="curl -# https://apt.metasploit.com/metasploit-framework.gpg.key | gpg --dearmor > metasploit.gpg && \
         mv metasploit.gpg /usr/share/keyrings/ && \
         echo \"deb [signed-by=/usr/share/keyrings/metasploit.gpg] http://apt.metasploit.com/ buster main\" | tee /etc/apt/sources.list.d/metasploit.list"

    retry_forever "$cmd" "添加Metasploit仓库" "metasploit.gpg" || return 1

    # 更新并安装
    cmd="apt-get update -y && apt-get install -y metasploit-framework"
    retry_forever "$cmd" "Metasploit Framework" || return 1
}

# 安装frp
install_frp() {
    # 创建并清理目录
    local module_dir="frp"
    echo -e "${YELLOW}[*] 清理 $module_dir 目录...${NC}"
    rm -rf "$module_dir"
    mkdir -p "$module_dir" && cd "$module_dir" || return 1

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

    # 下载并安装frp（规范gz解压流程）
    local FILE_NAME="frp_0.63.0_linux_${FRP_ARCH}.tar.gz"
    cmd="wget --progress=bar:force ${GITHUB_PREFIX}/fatedier/frp/releases/download/v0.63.0/$FILE_NAME && \
         gzip -d $FILE_NAME && \
         tar xf ${FILE_NAME%.gz} && \
         cp frp_0.63.0_linux_${FRP_ARCH}/frps /usr/local/bin/ && \
         cp frp_0.63.0_linux_${FRP_ARCH}/frpc /usr/local/bin/"

    retry_forever "$cmd" "frp" "$FILE_NAME" || { cd ..; return 1; }

    # 清理
    cd ..
    rm -rf "$module_dir"

    echo -e "${GREEN}[✓] frp安装完成${NC}"
    echo -e "${BLUE}[!] 配置文件需要手动创建或从官方获取${NC}"
    echo -e "${BLUE}[!] 使用命令 'frps -c /path/to/frps.ini' 或 'frpc -c /path/to/frpc.ini' 启动${NC}"
}

# 安装gost
install_gost() {
    # 创建并清理目录
    local module_dir="gost"
    echo -e "${YELLOW}[*] 清理 $module_dir 目录...${NC}"
    rm -rf "$module_dir"
    mkdir -p "$module_dir" && cd "$module_dir" || return 1

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

    # 下载并安装gost（规范gz解压流程）
    local FILE_NAME="gost_2.12.0_linux_${GOST_ARCH}.tar.gz"
    cmd="wget --progress=bar:force ${GITHUB_PREFIX}/ginuerzh/gost/releases/download/v2.12.0/$FILE_NAME && \
         gzip -d $FILE_NAME && \
         tar xf ${FILE_NAME%.gz} && \
         cp gost /usr/local/bin/"

    retry_forever "$cmd" "gost" "$FILE_NAME" || { cd ..; return 1; }

    # 清理
    cd ..
    rm -rf "$module_dir"

    echo -e "${GREEN}[✓] gost安装完成${NC}"
    echo -e "${BLUE}[!] 配置文件需要手动创建或从官方获取${NC}"
    echo -e "${BLUE}[!] 使用命令 'gost -C /path/to/config.yaml' 启动${NC}"
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
