# syntax=docker/dockerfile:1
ARG ROOTFS_RELEASE
FROM ghcr.io/iximiuz/labs/rootfs:ubuntu-24-04

ARG ARKADE_BIN_DIR
ARG LAB_USER

USER root

COPY jenkins.yaml /var/lib/jenkins/jenkins.yaml

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

chown jenkins:jenkins /var/lib/jenkins/jenkins.yaml
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

COPY override.conf /etc/systemd/system/jenkins.service.d/override.conf

# Install Jenkins plugins as root so we can write to /var/lib/jenkins/plugins.
# (The previous order ran as $LAB_USER and also had a path typo.)
COPY plugins.txt /tmp/plugins.txt

ARG PLUGIN_MANAGER_VERSION=2.13.2
RUN <<EOF
set -eu
curl -fsSL -o /tmp/jenkins-plugin-manager.jar \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${PLUGIN_MANAGER_VERSION}/jenkins-plugin-manager-${PLUGIN_MANAGER_VERSION}.jar
java -jar /tmp/jenkins-plugin-manager.jar \
  --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins/ \
  --plugin-file /tmp/plugins.txt
chown -R jenkins:jenkins /var/lib/jenkins/plugins
rm /tmp/jenkins-plugin-manager.jar /tmp/plugins.txt
EOF

USER $LAB_USER
ENV HOME=/home/$LAB_USER

COPY 500.rootfs-custom-jenkins-m/welcome $HOME/.welcome
