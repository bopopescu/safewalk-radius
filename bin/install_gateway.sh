#!/bin/sh -x

PREFIX=/opt/bsdradius
if [ "$1" = "" ]; then
    if [ -f $PREFIX/etc/bsdradius/bsdradiusd.conf ]; then
    	RADIUS_ACCESS_TOKEN=$(awk -F "=" '/authentication_access_token/ {print $2}' $PREFIX/etc/bsdradius/bsdradiusd.conf | tr -d '"')
    else
	echo "You need to specify the Authentication Access Token for Radius"
	exit 0
    fi
else
    RADIUS_ACCESS_TOKEN=$1
fi

python setup.py install --prefix=$PREFIX

VERSION_MAJOR=$(cat bsdradius/version.py | grep "major =" | grep -Eo "[0-9]" | xargs)
VERSION_MINOR=$(cat bsdradius/version.py | grep "minor =" | grep -Eo "[0-9]" | xargs)
VERSION_DEBUG=$(cat bsdradius/version.py | grep "debug =" | grep -Eo "[0-9]" | xargs)
RADIUS_VERSION=$VERSION_MAJOR.$VERSION_MINOR.$VERSION_DEBUG
echo "version: $RADIUS_VERSION"

bin/install-dependencies.sh
sed -i 's|clients_query =.*|clients_query = select address, name, secret, forward_reply_items from gaia_radius_interface_radiusclient|' $PREFIX/etc/bsdradius/bsdradiusd.conf | grep clients_query
sed -i "s|authentication_access_token.*=.*|authentication_access_token=$RADIUS_ACCESS_TOKEN|" $PREFIX/etc/bsdradius/bsdradiusd.conf
sed -i "s|base_url.*=.*|base_url=https://localhost|" $PREFIX/etc/bsdradius/bsdradiusd.conf
echo "$RADIUS_VERSION" > /opt/safewalk/RADIUS_VERSION
