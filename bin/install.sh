#!/bin/sh

#if [ "$1" = "" ]; then
#    SAFEWALK_SERVER_DIR=/home/safewalk/safewalk_server/sources
#else
#    SAFEWALK_SERVER_DIR=$1
#fi
PREFIX=/opt/bsdradius

python setup.py install --prefix=$PREFIX
#RADIUS_SECRET=$(awk -F "=" '/RADIUS_SECRET/ {print $2}' $SAFEWALK_SERVER_DIR/gaia_server/common_settings.py | tr -d '"')
#echo "secret: $RADIUS_SECRET"


VERSION_MAJOR=$(cat bsdradius/version.py | grep "major =" | grep -Eo "[0-9]" | xargs)
VERSION_MINOR=$(cat bsdradius/version.py | grep "minor =" | grep -Eo "[0-9]" | xargs)
VERSION_DEBUG=$(cat bsdradius/version.py | grep "debug =" | grep -Eo "[0-9]" | xargs)
RADIUS_VERSION=$VERSION_MAJOR.$VERSION_MINOR.$VERSION_DEBUG

echo "$RADIUS_VERSION" > $PREFIX/version

bin/install-dependencies.sh
sed -i "s|swk_auth_port.*=.*|swk_auth_port=8445|" $PREFIX/etc/bsdradius/bsdradiusd.conf
sed -i "s|swk_protocol.*=.*|swk_protocol=https|" $PREFIX/etc/bsdradius/bsdradiusd.conf
#sed -i "s|RADIUS_VERSION.*=.*|RADIUS_VERSION = '$RADIUS_VERSION'|" $SAFEWALK_SERVER_DIR/gaia_server/common_settings.py

#su - postgres -c "psql safewalk-server -c \"SELECT T.token FROM oauth2_client C, oauth2_accesstoken T, accounts_appuser U WHERE C.name='management-console' and T.client_id=C.id and T.user_id=U.id and U.username='radius' and U.is_system_user=True\" | head -n 3 | tail -n 1 | xargs > /tmp/rat"

#ADMIN_ACCESS_TOKEN=$(cat /tmp/rat)
#rm -rf /tmp/rat
#sed -i "s|swk_api_access_token.*=.*|swk_api_access_token=$ADMIN_ACCESS_TOKEN|" $PREFIX/etc/bsdradius/bsdradiusd.conf