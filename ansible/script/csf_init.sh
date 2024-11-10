#!/bin/bash

function install_csf() {
  cd ~/ || exit
  rm -fv csf.tgz
  wget http://download.configserver.com/csf.tgz
  tar -xzvf csf.tgz
  cd csf || exit
  sudo sh install.sh
}

function init_csf() {

  TESTING = "0"
  # ipv4 rule
  sudo sed -i -e 's/^TCP_IN = \".*\"$/TCP_IN = \"443,465,999\"/' \
    -e 's/^TCP_OUT = \".*\"$/TCP_OUT = \"20,21,22,25,53,80,110,113,443,587,993,995,1:60000\"/' \
    -e 's/^UDP_IN = \".*\"$/UDP_IN = \"443,999\"/' \
    -e 's/^UDP_OUT = \".*\"$/UDP_OUT = \"1:60000\"/' \
    -e 's/^ICMP_IN = \".*\"$/ICMP_IN = \"0\"/' \
    /etc/csf/csf.conf
  # ipv6 rule
  sudo sed -i -e 's/^TCP6_IN = \".*\"$/TCP6_IN = \"443,465,999\"/' \
    -e 's/^TCP6_OUT = \".*\"$/TCP6_OUT = \"20,21,22,25,53,80,110,113,443,587,993,995,1:60000\"/' \
    -e 's/^UDP6_IN = \".*\"$/UDP6_IN = \"443,999\"/' \
    -e 's/^UDP6_OUT = \".*\"$/UDP6_OUT = \"1:60000\"/' \
    /etc/csf/csf.conf
  # test mode off
  sudo sed -i -e 's/^TESTING = \".*\"$/TESTING = \"0\"/' \
    /etc/csf/csf.conf
  # restart csf
  sudo csf -r
}

# 安装 csf
if install_csf; then
  # 初始化 csf
  init_csf
fi
