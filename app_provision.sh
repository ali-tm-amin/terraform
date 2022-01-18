# Update and upgrade
sudo apt-get update -y
sudo apt-get upgrade -y

# Install web server
sudo apt install nginx -y
sudo systemctl enable nginx  # Server is automatically running

# Download node v6 
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs -y

# install remaining packages
sudo npm install pm2 -g


# Add DB_HOST variable to env
echo "export DB_HOST=mongodb://192.168.10.150:27017/posts" >> .bashrc

# # Replace nginx default file to allow reverse proxy
sudo cp app/vm_config/app_config/default /etc/nginx/sites-available/default

# Restart and enable nginx
sudo systemctl restart nginx
sudo systemctl enable nginx


# Everything up till here work
#  Seed the database
# node /home/vagrant/app/app/seeds/seed.js

# # Start app
# cd app/app
# npm start