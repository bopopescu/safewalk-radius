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
sed -i "s|swk_auth_port.*=.*|swk_auth_port = 443|" $PREFIX/etc/bsdradius/bsdradiusd.conf
sed -i "s|swk_protocol.*=.*|swk_protocol=https|" $PREFIX/etc/bsdradius/bsdradiusd.conf
echo "$RADIUS_VERSION" > /opt/safewalk/RADIUS_VERSION
