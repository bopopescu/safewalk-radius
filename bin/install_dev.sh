#!/bin/sh

PREFIX=/opt/bsdradius
python setup.py install --prefix=$PREFIX
RADIUS_VERSION=$(bin/bsdradiusd -v)

bin/install-dependencies.sh
sed -i 's|clients_query =.*|clients_query = select address, name, secret, forward_reply_items from gaia_radius_interface_radiusclient|' $PREFIX/etc/bsdradius/bsdradiusd.conf | grep clients_query
sed -i '/forward_reply_items/d' $PREFIX/etc/bsdradius/clients.conf
echo "forward_reply_items = false" >> $PREFIX/etc/bsdradius/clients.conf
#sed -i "s|base_url.*=.*|base_url=http://localhost:8000|" $PREFIX/etc/bsdradius/bsdradiusd.conf