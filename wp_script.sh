#!/bin/bash
DOMAIN=$1
DB_NAME=$2
DB_HOST=$3
DB_USER=$4
DB_PASSWORD=$5
WP_USER=$6
WP_PASSWORD=$7
WP_TITLE=$8
WP_EMAIL=$9
echo ${DOMAIN} ${WP_TITLE} ${WP_USER} ${WP_PASSWORD} ${WP_EMAIL}
PACKAGES_LIST='apache2 software-properties-common libapache2-mod-php7.3 php7.3 php7.3-cli php7.3-common php7.3-json php7.3-opcache php7.3-mysql php7.3-mbstring php7.3-zip php7.3-xml mysql-client-core-5.7'

sudo add-apt-repository -y ppa:ondrej/apache2
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update 1> /dev/null
sudo apt install -y ${PACKAGES_LIST}

# configurazione vhost
sudo mkdir /var/www/${DOMAIN}
sudo chown www-data.www-data -R /var/www/${DOMAIN}
cd /tmp/
	sudo cat >> ${DOMAIN}.conf << EOF
<VirtualHost *:80>
	ServerName ${DOMAIN}
	DocumentRoot /var/www/${DOMAIN}

        <Directory />
           Options -Indexes
    </Directory>

	ErrorLog /var/log/apache2/error-${DOMAIN}.log
	CustomLog /var/log/apache2/access-${DOMAIN}.log combined

</VirtualHost>
EOF
sudo mv ${DOMAIN}.conf '/etc/apache2/sites-available/'
sudo a2ensite ${DOMAIN}.conf
sudo service apache2 restart
sudo systemctl enable apache2

# wordpress
cd /tmp
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
DBEXISTS=$(mysql -u${DB_USER} -p${DB_PASSWORD} -h ${DB_HOST} -e "SHOW DATABASES LIKE '"${DB_NAME}"';" | grep "$DBNAME" > /dev/null; echo "$?")
if [ $DBEXISTS -eq 0 ];then
    echo "A database with the name ${DB_NAME} already exists."
else
    echo "Creating the mysql database ${DB_NAME}"
    mysql -u ${DB_USER} -p${DB_PASSWORD} -h ${DB_HOST} -e "CREATE DATABASE ${DB_NAME}"
fi
#mysql -u${DB_USER} -p${DB_PASSWORD} -h ${DB_HOST} -e "CREATE DATABASE ${DB_NAME}"
sudo chown ubuntu /var/www/${DOMAIN}/
cd /var/www/${DOMAIN}/
wp core download
wp core config --dbname=${DB_NAME} --dbuser=${DB_USER} --dbpass=${DB_PASSWORD} --dbhost=${DB_HOST}
wp core install --url=${DOMAIN} --title=${WP_TITLE} --admin_user=${WP_USER} --admin_password=${WP_PASSWORD} --admin_email="admin@provapratica.com"
sudo chmod -R 755 wp-content
sudo chown -R www-data:www-data /var/www/${DOMAIN}/

# agent code deploy
sudo apt install ruby -y
sudo apt install wget -y
cd /tmp
wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start