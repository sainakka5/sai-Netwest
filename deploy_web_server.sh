#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <EC2_Instance_IP>"
    exit 1
fi

EC2_INSTANCE_IP="$1"

# SSH key for accessing the EC2 instance
SSH_KEY_PATH="/path/to/your/private/key.pem"

# Commands to install Nginx and deploy HTML page
SSH_COMMANDS=$(cat <<EOF
sudo apt-get update -y
sudo apt-get install -y nginx

# Deploy HTML page
sudo sh -c 'echo "<html><body><h1>Hello, EC2 Instance!</h1></body></html>" > /var/www/html/index.html'

# Restart Nginx to apply changes
sudo service nginx restart
EOF
)

# Execute commands on the EC2 instance
ssh -i "$SSH_KEY_PATH" "ec2-user@$EC2_INSTANCE_IP" "$SSH_COMMANDS"

echo "Web server installed and HTML page deployed on EC2 instance at $EC2_INSTANCE_IP
