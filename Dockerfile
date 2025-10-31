# syntax=docker/dockerfile:1
ARG ROOTFS_RELEASE
FROM ghcr.io/iximiuz/labs/rootfs:ubuntu-24-04

ARG ARKADE_BIN_DIR
ARG LAB_USER

USER root

RUN <<EOF
set -eu

apt-get update
apt-get install -y \
  build-essential \
  openjdk-21-jre \
  unzip

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list

apt-get update
apt-get install -y jenkins
EOF

RUN <<EOF
set -eu

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list

apt-get update
apt-get install -y \
  ansible \
  gh
EOF

USER $LAB_USER
ENV HOME=/home/$LAB_USER

COPY 500.rootfs-custom-jenkins-m/welcome $HOME/.welcome
