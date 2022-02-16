FROM ubuntu:16.04

# Base ENV
ENV http_proxy http://proxyhost:proxyport
ENV https_proxy http://proxyhost:proxyport

# Change APT Source for Chinese Users
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# Download basic build tools
RUN apt-get update \
    && apt-get install --yes --no-install-recommends wget unzip build-essential \
    git bc swig libncurses5-dev libpython3-dev libssl-dev pkg-config zlib1g-dev \
    libusb-dev libusb-1.0-0-dev python3-pip gawk \
    && rm -rf /var/lib/apt/lists/*

# Download cross-compile toolchain
RUN wget http://releases.linaro.org/components/toolchain/binaries/7.2-2017.11/arm-linux-gnueabi/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi.tar.xz \
    && tar -vxJf gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi.tar.xz \ 
    && cp -r gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi /opt/ \
    && echo "PATH=\"$PATH:/opt/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabi/bin\"" > /etc/bash.bashrc \

# Setting workdir and env
WORKDIR /home/lichee

ENV ARCH="arm" 
ENV CROSS_COMPILE="arm-linux-gnueabi-"

# Remove Proxy
ENV http_proxy ""
ENV https_proxy ""

# Download Lichee Nano UBOOT and init config
RUN git clone --depth=1 https://gitee.com/LicheePiNano/u-boot.git -b nano-lcd800480 u-boot \
    && cd u-boot \
    && make ARCH=arm CROSS_COMPILE=arm-linux-gnueabi- f1c100s_nano_uboot_defconfig

# Download Lichee Nano linux and init config
RUN git clone --depth=1 -b master https://gitee.com/LicheePiNano/Linux.git linux \
    && cd linux \
    && make ARCH=arm f1c100s_nano_linux_defconfig 

# Download Buildroot
RUN wget https://buildroot.org/downloads/buildroot-2021.02.4.tar.gz \
    && tar xvf buildroot-2021.02.4.tar.gz
