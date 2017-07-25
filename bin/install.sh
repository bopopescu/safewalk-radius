#!/bin/sh

if [ "$1" = "" ]; then
    SAFEWALK_SERVER_DIR=/home/safewalk/safewalk_server/sources
else
    SAFEWALK_SERVER_DIR=$1
fi
PREFIX=/opt/bsdradius

python setup.py install --prefix=$PREFIX
RADIUS_SECRET=$(awk -F "=" '/RADIUS_SECRET/ {print $2}' $SAFEWALK_SERVER_DIR/gaia_server/common_settings.py | tr -d '"')
echo "secret: $RADIUS_SECRET"


VERSION_MAJOR=$(cat bsdradius/version.py | grep "major =" | grep -Eo "[0-9]" | xargs)
VERSION_MINOR=$(cat bsdradius/version.py | grep "minor =" | grep -Eo "[0-9]" | xargs)
VERSION_DEBUG=$(cat bsdradius/version.py | grep "debug =" | grep -Eo "[0-9]" | xargs)
RADIUS_VERSION=$VERSION_MAJOR.$VERSION_MINOR.$VERSION_DEBUG
echo "version: $RADIUS_VERSION"

bin/install-dependencies.sh
sed -i 's|clients_query =.*|clients_query = select address, name, secret, forward_reply_items from gaia_radius_interface_radiusclient|' $PREFIX/etc/bsdradius/bsdradiusd.conf | grep clients_query
sed -i '/forward_reply_items/d' $PREFIX/etc/bsdradius/clients.conf
echo "forward_reply_items = false" >> $PREFIX/etc/bsdradius/clients.conf
sed -i "s|base_url.*=.*|base_url=https://localhost:8445|" $PREFIX/etc/bsdradius/bsdradiusd.conf
sed -i "s|secret.*=.*|secret = $RADIUS_SECRET|" $PREFIX/etc/bsdradius/clients.conf
sed -i "s|RADIUS_VERSION.*=.*|RADIUS_VERSION = '$RADIUS_VERSION'|" $SAFEWALK_SERVER_DIR/gaia_server/common_settings.py
