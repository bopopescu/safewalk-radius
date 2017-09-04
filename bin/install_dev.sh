#!/bin/sh

PREFIX=/opt/bsdradius
python setup.py install --prefix=$PREFIX
RADIUS_VERSION=$(bin/bsdradiusd -v)

bin/install-dependencies.sh
sed -i 's|clients_query =.*|clients_query = select address, name, secret, forward_reply_items from gaia_radius_interface_radiusclient|' $PREFIX/etc/bsdradius/bsdradiusd.conf | grep clients_query

su - postgres -c "psql safewalk-server-v1.2.2 -c \"SELECT T.token FROM oauth2_client C, oauth2_accesstoken T, accounts_appuser U WHERE C.name='management-console' and T.client_id=C.id and T.user_id=U.id and U.username='radius' and U.is_system_user=True\" | head -n 3 | tail -n 1 | xargs > /tmp/rat"

ADMIN_ACCESS_TOKEN=$(cat /tmp/rat)
rm -rf /tmp/rat
sed -i "s|swk_api_access_token.*=.*|swk_api_access_token=$ADMIN_ACCESS_TOKEN|" $PREFIX/etc/bsdradius/bsdradiusd.conf