#!/bin/sh

if [ "$1" = "" ]; then
    echo "Please specify the Safewalk Server sources"
    exit 1
fi
PREFIX=/opt/bsdradius
SAFEWALK_SERVER_DIR=$1
python setup.py install --prefix=$PREFIX
RADIUS_SECRET=$(awk -F "=" '/RADIUS_SECRET/ {print $2}' $SAFEWALK_SERVER_DIR/gaia_server/common_settings.py | tr -d '"')
RADIUS_VERSION=$(bin/bsdradiusd -v)

bin/install-dependencies.sh
sed -i 's|clients_query =.*|clients_query = select address, name, secret, forward_reply_items from gaia_radius_interface_radiusclient|' $PREFIX/etc/bsdradius/bsdradiusd.conf | grep clients_query
sed -i '/forward_reply_items/d' $PREFIX/etc/bsdradius/clients.conf
echo "forward_reply_items = false" >> $PREFIX/etc/bsdradius/clients.conf
#sed -i "s|base_url.*=.*|base_url=https://localhost:8000|" $PREFIX/etc/bsdradius/bsdradiusd.conf
#sed -i "s|secret.*=.*|secret = $RADIUS_SECRET|" $PREFIX/etc/bsdradius/clients.conf
#sed -i "s|RADIUS_VERSION.*=.*|RADIUS_VERSION = '$RADIUS_VERSION'|" $SAFEWALK_SERVER_DIR/gaia_server/common_settings.py