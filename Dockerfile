echo "echo 0 >/proc/sys/kernel/randomize_va_space" >> ~/.bashrc
apt-get update && apt-get install -y gnupg2 wget

echo  "deb https://mirrors.aliyun.com/kali kali-rolling main non-free contrib"  > /etc/apt/sources.list
echo  "deb-src https://mirrors.aliyun.com/kali kali-rolling main non-free contrib " >> /etc/apt/sources.list

dpkg --add-architecture i386
apt-get update && apt-get install libc6:i386 gcc-multilib binwalk vim libssl-dev curl git wget cmake make unzip g++ pkg-config procps \
   strace ltrace hydra libgmp3-dev libmpc-dev  -y
