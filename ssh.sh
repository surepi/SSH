#!/bin/bash

# 设置公钥下载链接
public_key_url="https://r2.imgs.ng/id_rsa.pub"

# 下载公钥文件
wget -O /root/.ssh/id_rsa.pub "$public_key_url"

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo "下载公钥文件失败，请检查公钥下载链接或网络连接。"
    exit 1
fi

# 备份 SSH 服务器配置文件
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 检测当前操作系统
if [ -f /etc/redhat-release ]; then
  # CentOS 或 Red Hat 系列操作系统
  # 禁用密码登录
  sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

  # 启用公钥登录
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

  # 设置公钥文件路径
  sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config
  echo "AuthorizedKeysFile     .ssh/authorized_keys /root/.ssh/authorized_keys" >> /etc/ssh/sshd_config

  # 将公钥复制到 /root/.ssh/authorized_keys
  cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

  # 设置正确的权限
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/authorized_keys

  # 重启 SSH 服务
  service sshd restart
elif [ -f /etc/debian_version ]; then
  # Debian 或 Ubuntu 系列操作系统
  # 禁用密码登录
  sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

  # 启用公钥登录
  sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

  # 设置公钥文件路径
  sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/' /etc/ssh/sshd_config
  echo "AuthorizedKeysFile     .ssh/authorized_keys /root/.ssh/authorized_keys" >> /etc/ssh/sshd_config

  # 将公钥复制到 /root/.ssh/authorized_keys
  cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

  # 设置正确的权限
  chmod 700 /root/.ssh
  chmod 600 /root/.ssh/authorized_keys

  # 重启 SSH 服务
  systemctl restart sshd
else
  echo "不支持的操作系统。"
  exit 1
fi