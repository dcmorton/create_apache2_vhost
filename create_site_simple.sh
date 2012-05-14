#!/bin/bash
#
# Original script for nginx by: Seb Dangerfield - sebdangerfield.me.uk
# Available here: http://www.sebdangerfield.me.uk/2011/03/automatically-creating-new-virtual-hosts-with-nginx-bash-script/
# Modified from nginx to apache2 by Derek Morton - derekmorton.name

APACHE_CONFIG='/etc/apache2/sites-available'
APACHE_SITES_ENABLED='/etc/apache2/sites-enabled'
WEB_DIR='/var/www'
SED=`which sed`
CURRENT_DIR=`dirname $0`

if [ -z $1 ]; then
	echo "No domain name given"
	exit 1
fi
DOMAIN=$1

# check the domain is roughly valid!
PATTERN="^([[:alnum:]]([[:alnum:]\-]{0,61}[[:alnum:]])?\.)+[[:alpha:]]{2,6}$"
if [[ "$DOMAIN" =~ $PATTERN ]]; then
	DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
	echo "Creating hosting for:" $DOMAIN
else
	echo "invalid domain name"
	exit 1 
fi

#Replace dots with underscores
SITE_DIR=`echo $DOMAIN | $SED 's/\./_/g'`

# Now we need to copy the virtual host template
CONFIG=$APACHE_CONFIG/$DOMAIN
sudo cp $CURRENT_DIR/virtual_host.template $CONFIG
sudo $SED -i "s/DOMAIN/$DOMAIN/g" $CONFIG
sudo $SED -i "s!ROOT!$WEB_DIR/$SITE_DIR!g" $CONFIG

# set up web root
sudo mkdir $WEB_DIR/$SITE_DIR
sudo chown www-data:www-data -R $WEB_DIR/$SITE_DIR
sudo chmod 600 $CONFIG

# create symlink to enable site
sudo ln -s $CONFIG $APACHE_SITES_ENABLED/$DOMAIN

# reload Apache to pull in new config
sudo service apache2 reload

# put the template index.html file into the new domains web dir
sudo cp $CURRENT_DIR/index.html.template $WEB_DIR/$SITE_DIR/index.html
sudo $SED -i "s/SITE/$DOMAIN/g" $WEB_DIR/$SITE_DIR/index.html
sudo chown www-data:www-data $WEB_DIR/$SITE_DIR/index.html
sudo chmod 775 -R $WEB_DIR/$SITE_DIR

echo "Site Created for $DOMAIN"