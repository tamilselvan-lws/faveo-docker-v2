#!/bin/bash

# Colour variables for the script.
red=`tput setaf 1`

green=`tput setaf 2`

yellow=`tput setaf 11`

skyblue=`tput setaf 14`

white=`tput setaf 15`

reset=`tput sgr0`

# Faveo Banner.

echo -e "$skyblue                                                                                                                    $reset"
sleep 0.05
echo -e "$skyblue                                   _______ _______ _     _ _______ _______                                          $reset"
sleep 0.05
echo -e "$skyblue                                  (_______|_______|_)   (_|_______|_______)                                         $reset"
sleep 0.05
echo -e "$skyblue                                   _____   _______ _     _ _____   _     _                                          $reset"
sleep 0.05
echo -e "$skyblue                                  |  ___) |  ___  | |   | |  ___) | |   | |                                         $reset"
sleep 0.05
echo -e "$skyblue                                  | |     | |   | |\ \ / /| |_____| |___| |                                         $reset"
sleep 0.05
echo -e "$skyblue                                  |_|     |_|   |_| \___/ |_______)\_____/                                          $reset"
sleep 0.05
echo -e "$skyblue                                                                                                                    $reset"
sleep 0.05
echo -e "$skyblue                          _     _ _______ _       ______ ______  _______  ______ _     _                            $reset"
sleep 0.05
echo -e "$skyblue                        (_)   (_|_______|_)     (_____ (______)(_______)/ _____|_)   | |                            $reset"
sleep 0.05
echo -e "$skyblue                         _______ _____   _       _____) )     _ _____  ( (____  _____| |                            $reset"
sleep 0.05
echo -e "$skyblue                        |  ___  |  ___) | |     |  ____/ |   | |  ___)  \____ \|  _   _)                            $reset"
sleep 0.05
echo -e "$skyblue                        | |   | | |_____| |_____| |    | |__/ /| |_____ _____) ) |  \ \                             $reset"
sleep 0.05
echo -e "$skyblue                        |_|   |_|_______)_______)_|    |_____/ |_______|______/|_|   \_)                            $reset"
sleep 0.05
echo -e "$skyblue                                                                                                                    $reset"
sleep 0.05
echo -e "$skyblue                                                                                                                    $reset"
                                                                                        

if [[ $# -lt 8 ]]; then
    echo "Please run the script by passing all the required arguments."
    exit 1;
fi

# Check if the script is run with superuser privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Install 
echo "Checking Prerequisites....."
apt update; apt install unzip curl -y || yum install unzip curl -y


# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root."
    exit 1
fi

# Check if Docker CE is installed
if ! command -v docker &>/dev/null; then
    echo "Docker CE is not installed. Installing Docker CE..."
    
    # Detect the Linux distribution
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "$ID" == "debian" || "$ID" == "ubuntu" ]]; then
            # Install Docker CE on Debian/Ubuntu
            apt-get update
            apt-get install -y apt-transport-https ca-certificates curl software-properties-common
            curl -fsSL https://download.docker.com/linux/$ID/gpg | apt-key add -
            add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$ID $UBUNTU_CODENAME stable"
            apt-get update
            apt-get install -y docker-ce
        elif [[ "$ID" == "centos" || "$ID" == "rhel" ]]; then
            # Install Docker CE on CentOS/RHEL
            yum install -y yum-utils
            yum-config-manager --add-repo https://download.docker.com/linux/$ID/docker-ce.repo
            yum install -y docker-ce
            systemctl start docker
            systemctl enable docker
        else
            echo "Unsupported Linux distribution: $ID"
            exit 1
        fi
    else
        echo "Could not detect the Linux distribution."
        exit 1
    fi
    
    echo "Docker CE installed successfully."
else
    echo "Docker CE is already installed."
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &>/dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    
    # Install Docker Compose
    curl -sSL https://github.com/docker/compose/releases/latest/download/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    echo "Docker Compose installed successfully."
else
    echo "Docker Compose is already installed."
fi

# Verify Docker and Docker Compose versions
docker --version
docker-compose --version

echo "Docker CE and Docker Compose installation and verification completed."



CUR_DIR=$(pwd)
host_root_dir="faveo"

# Initialize variables
domain_name=
email=
license=
orderno=

# Function to get user confirmation
get_confirmation() {
  read -rp "Do you want to proceed? (yes/Y or no/N): " confirmation
  case "$confirmation" in
    [yY][eE][sS]|[yY])
      return 0  # User confirmed
      ;;
    [nN][oO]|[nN])
      return 1  # User declined
      ;;
    *)
      echo "Invalid input. Please enter 'yes/Y' or 'no/N'."
      get_confirmation  # Ask again if input is invalid
      ;;
  esac
}

# Process all arguments with labels
while [ $# -gt 0 ]; do
  case "$1" in
    -d|--domain)
      domainname="$2"
      shift 2
      ;;
    -e|--email)
      email="$2"
      shift 2
      ;;
    -l|--license)
      license="$2"
      shift 2
      ;;
    -o|--orderno)
      orderno="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done


# Now you can process or evaluate these labeled variables as needed
echo "Domain Name: $domainname"
echo "Email: $email"
echo "License: $license"
echo "Order Number: $orderno"

# Ask for user confirmation
get_confirmation

if [ $? -eq 0 ]; then
  # User confirmed, proceed with processing
  echo "Confirmed. Proceeding with the action."
  # Add your evaluation or processing logic here
else
  # User declined, exit
  echo "User declined. Exiting."
  exit 1
fi


# Obtain SSL Certs
if [ ! -d $CUR_DIR/certbot/html ]; then
    mkdir -p $CUR_DIR/certbot/html
elif [ ! -e $CUR_DIR/certbot/html ]; then
    exit 0;
fi;

echo "<h1>Obtain SSL Certs</h1>" > $CUR_DIR/certbot/html/index.html

echo -e "Initializing Temporary Apache container to obtain SSL Certificates..."

docker run -dti -p 80:80 -v $CUR_DIR/certbot/html:/usr/local/apache2/htdocs --name apache-cert httpd:2.4.33-alpine

if [[ $? -eq 0 ]]; then
    echo "Initializing Certbot Container to obtain SSL Certificates for $domainname"
    docker run -ti --rm -v $CUR_DIR/certbot/letsencrypt/etc/letsencrypt:/etc/letsencrypt -v $CUR_DIR/certbot/html:/data/letsencrypt --name certbot certbot/certbot certonly --webroot --email $email  --agree-tos --non-interactive  --no-eff-email --webroot-path=/data/letsencrypt -d $domainname
else
    echo "Temporary Container Failed to Initialise exiting..."
    exit 1;
fi;

docker rm -f apache-cert

crontab -l | { cat; echo "45 2 * * 6 docker run -ti --rm -v $CUR_DIR/certbot/letsencrypt/etc/letsencrypt:/etc/letsencrypt -v $CUR_DIR/faveo/public:/data/letsencrypt --name certbot certbot/certbot certonly --webroot --email $email   --agree-tos --non-interactive  --no-eff-email --webroot-path=/data/letsencrypt -d $domainname >/dev/null 2>&1"; } | crontab -

chown -R $USER:$USER $CUR_DIR/certbot

if [[ $? -eq 0 ]]; then
    echo "SSL Certificates for $domainname obtained Successfully."
else
    echo "Permission Issue."
    exit 1;
fi;

# Faveo File Download

echo -e "\n";
echo "Downloading Faveo Helpdesk"

curl https://billing.faveohelpdesk.com/download/faveo\?order_number\=$orderno\&serial_key\=$license --output faveo.zip


if [[ $? -eq 0 ]]; then
    echo "Download Successfull";
else
    echo "Download Failed. Please check the order number, serial number of Helpdesk entered and your Internet connectivity."
    exit 1;
fi;

echo -e "\n";
echo "Extracting please wait ..."
echo -e "\n";
if [ ! -d $CUR_DIR/$host_root_dir ]; then
    unzip -q faveo.zip -d $host_root_dir
else
    rm -rf $CUR_DIR/$host_root_dir
    unzip -q faveo.zip -d $host_root_dir
fi

if [ $? -eq 0 ]; then
    chown -R www-data:www-data $host_root_dir
    find $host_root_dir -type d -exec chmod 755 {} \;
    find $host_root_dir -type f -exec chmod 644 {} \;
    echo "Extracted"
else
    echo "Extract failure."
fi


# Set DB (root, name, user, password)
db_root_pw=$(openssl rand -base64 12)
db_name=faveo
db_user=faveo
db_user_pw=$(openssl rand -base64 12)

# Set MeiliSearch Master Key
meili_master_key=$(openssl rand -base64 40)

# Write On faveo.env
if [[ $? -eq 0 ]]; then
    rm -f .env
    cp example.env .env
    sed -i 's:MYSQL_ROOT_PASSWORD=:&'$db_root_pw':' .env
    sed -i 's/MYSQL_DATABASE=/&'$db_name'/' .env
    sed -i 's/MYSQL_USER=/&'$db_user'/' .env
    sed -i 's:MYSQL_PASSWORD=:&'$db_user_pw':' .env
    sed -i 's/DOMAINNAME=/&'$domainname'/' .env
    sed -i 's:MASTER_KEY=:&'$meili_master_key':' .env
    sed -i '/ServerName/c\    ServerName '$domainname'' ./apache/000-default.conf
    sed -i 's:domainrewrite:'$domainname':g' ./apache/000-default.conf
    sed -i 's/HOST_ROOT_DIR=/&'$host_root_dir'/' .env
    sed -i 's:CUR_DIR=:&'$PWD':' .env
else
    echo "Database Password Generation Failed"
fi

# Create Volume -DB
if [[ $? -eq 0 ]]; then
    docker volume create --name ${domainname}-faveoDB
fi

docker network rm ${domainname}-faveo

docker network create --driver=bridge --subnet=172.24.2.0/24 ${domainname}-faveo

if [[ $? -eq 0 ]]; then
    echo " Faveo Docker Network ${domainname}-faveo Created"
else
    echo " Faveo Docker Network Creation failed"
    exit 1;
fi

# Docker up
if [[ $? -eq 0 ]]; then
    cp docker-compose-apache.yml docker-compose.yml
    docker-compose up -d
fi

# Faveo credentials
if [[ $? -eq 0 ]]; then
    echo -e "\n"
    echo "#########################################################################"
    echo -e "\n"
    echo "Faveo Docker installed successfully. Visit https://$domainname from your browser."
    echo "Please save the following credentials."
    echo "Database Hostname: faveo-mariadb"
    echo "Mysql Database root password: $db_root_pw"
    echo "Faveo Helpdesk name: $db_name"
    echo "Faveo Helpdesk DB User: $db_user"
    echo "Faveo Helpdesk DB Password: $db_user_pw"
    echo "Faveo Helpdesk MeiliSearch MasterKey: $meili_master_key"
    echo -e "\n"
    echo "#########################################################################"
else
    echo "Script Failed unknown error."
    exit 1;
fi