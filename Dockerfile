# syntax=docker/dockerfile:1
ARG ROOTFS_RELEASE
FROM ghcr.io/iximiuz/labs/rootfs:ubuntu-24-04

ARG ARKADE_BIN_DIR
ARG LAB_USER

USER root

COPY docker.list /etc/apt/sources.list.d/docker.list

RUN <<EOF
set -eu

# Create keyrings directory and add Docker's GPG key
install -m 0755 -d /etc/apt/keyrings && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
chmod a+r /etc/apt/keyrings/docker.gpg

apt-get update
apt-get install --assume-yes \
  build-essential \
  openjdk-21-jre \
  unzip \
  docker-ce

systemctl start docker && chmod 777 /var/run/sock.docker

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | tee /usr/share/keyrings/jenkins-keyring.asc
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list

apt-get update
apt-get install -y jenkins
EOF

RUN <<EOF
set -eu

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg

chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list

apt-get update
apt-get install -y \
  ansible \
  gh
EOF

COPY override.conf /etc/systemd/system/jenkins.service.d/override.conf

USER $LAB_USER
ENV HOME=/home/$LAB_USER

COPY plugins.txt $HOME/plugins.txt

RUN curl -LO https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.13.2/jenkins-plugin-manager-2.13.2.jar
RUN java -jar jenkins-plugin-manager-*.jar --war /usr/share/java/jenkins.war --plugin-download-directory /var/lib/jenkins/plugins/ --plugin-file $HOME/$LAB_USER/plugins.txt && chown -R jenkins:jenkins /var/lib/jenkins/plugins && rm $HOME/$LAB_USER/plugins.txt

RUN curl -L https://gist.githubusercontent.com/mprokopov/14c94e7fc55c6d6dea732e040e75d5a3/raw/4f8d18f866a9caadbd6d36c9faaa6781953b3576/jenkins.yaml -o /var/lib/jenkins/jenkins.yaml && chown jenkins:jenkins /var/lib/jenkins/jenkins.yaml

COPY 500.rootfs-custom-jenkins-m/welcome $HOME/.welcome
