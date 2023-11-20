FROM kalilinux/kali-rolling


ARG GITHUB
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PIP_NO_CACHE_DIR=off

WORKDIR /opt

RUN echo "echo 0 >/proc/sys/kernel/randomize_va_space" >> ~/.bashrc
RUN apt-get update && apt-get install -y gnupg2 wget

RUN echo  "deb https://mirrors.aliyun.com/kali kali-rolling main non-free contrib"  > /etc/apt/sources.list
RUN echo  "deb-src https://mirrors.aliyun.com/kali kali-rolling main non-free contrib " >> /etc/apt/sources.list

RUN mkdir -p  ~/.pip
RUN echo "[global]"  > ~/.pip/pip.conf
RUN echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple"  >> ~/.pip/pip.conf
RUN echo "[install]" >> ~/.pip/pip.conf
RUN echo "trusted-host = https://pypi.tuna.tsinghua.edu.cn" >> ~/.pip/pip.conf

RUN wget https://archive.kali.org/archive-key.asc
RUN apt-key add archive-key.asc

RUN dpkg --add-architecture i386
RUN apt-get update && apt-get install libc6:i386 gcc-multilib binwalk gdbserver vim libssl-dev curl git wget cmake make unzip g++ pkg-config procps \
   strace ltrace python3 python3-pip hydra libgmp3-dev libmpc-dev python3.11-venv  -y


RUN git clone ${GITHUB}/radareorg/radare2 -b 5.8.8
WORKDIR /opt/radare2
RUN sys/install.sh
RUN r2pm -U
RUN r2pm -i r2ghidra


WORKDIR /opt
RUN git clone ${GITHUB}/RsaCtfTool/RsaCtfTool.git
WORKDIR /opt/RsaCtfTool
RUN pip3 install -r "requirements.txt"

WORKDIR /opt
RUN python3 -m pip install pipx
RUN git clone --recursive ${GITHUB}/byt3bl33d3r/CrackMapExec
WORKDIR /opt/CrackMapExec
RUN pipx install .

WORKDIR /opt

ENTRYPOINT [ "/bin/bash" ]
