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


RUN curl -Ls https://github.com/radareorg/radare2/releases/download/5.9.8/radare2-5.9.8.tar.xz | tar xJv
radare2-5.9.8/sys/install.sh


ENTRYPOINT [ "/bin/bash" ]
