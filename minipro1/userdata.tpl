#!/bin/bash
exec > /var/log/docker.log 2>&1
echo “[ START ]”
echo “[ Phase1] Install essential package”
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
echo “[ Phase2 ] Create GPG key”
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo “[ Phase 03 ] Setup APT repository”
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo “[Phase04]install docker package”
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo “[Phase05] Setup the user(ubuntu)”
sudo usermod –aG docker ubuntu
echo “[Phase06] Enable the docker package”
sudo systemctl enable —-now docker
echo “[ END ]”