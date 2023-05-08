#!/bin/bash

# Update and upgrade the system
sudo apt-get update
sudo apt-get upgrade -y

# Prompt for company name and set hostname
read -p "What is the server name? " servername
sudo hostnamectl set-hostname "$servername"

# Get username and password for new user
read -p "Enter username for new user: " username
read -s -p "Enter password for new user: " password

# Create new user, add to sudo group, and set home directory
sudo useradd -m -s /bin/bash -G sudo $username
echo "$username:$password" | sudo chpasswd
sudo mkdir -p /home/$username
sudo chown $username:$username /home/$username

# Move /root/setup to the user's home directory and set ownership
echo "Moving /root/setup folder to user's home directory and setting ownership..."
sudo cp -R /root/setup /home/$username/
sudo chown -R $username:$username /home/$username/scripts

# Make all .sh files inside the scripts folder executable
echo "Making all .sh files inside the scripts folder executable..."
find /home/$username/setup -type f -name "*.sh" -exec chmod +x {} \;

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker $username
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Portainer agent and connect to Portainer master
echo "Installing Portainer agent..."
sudo docker run -d --name portainer_agent --restart always -v /var/run/docker.sock:/var/run/docker.sock -e AGENT_CLUSTER_ADDR=<PORTAINER_MASTER_IP_ADDRESS> portainer/agent

# Output cool thing showing installation is finished
echo "
   _____ ____  __  __ _____  _      ______ _______ ______ 
  / ____/ __ \|  \/  |  __ \| |    |  ____|__   __|  ____|
 | |   | |  | | \  / | |__) | |    | |__     | |  | |__   
 | |   | |  | | |\/| |  ___/| |    |  __|    | |  |  __|  
 | |___| |__| | |  | | |    | |____| |____   | |  | |____ 
  \_____\____/|_|  |_|_|    |______|______|  |_|  |______|

Installation is complete! Enjoy using Docker, Docker Compose, and Portainer agent.
"

