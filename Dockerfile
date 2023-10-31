FROM ubuntu:20.04

ENV http_proxy=$http_proxy

ENV https_proxy=$http_proxy

ENV no_proxy=$no_proxy

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y sudo git gcc meson gdb python3 python3-pip pkg-config libnuma-dev libjson-c-dev libpcap-dev libelf-dev libbpf-dev apt-utils

RUN pip3 install pyelftools

RUN git config --global http.proxy $http_proxy

COPY dpdk-stable-20.11.9 /tmp/dpdk

RUN cd /tmp/dpdk && \
        meson build && \
        ninja -C build && \
        ninja -C build install
