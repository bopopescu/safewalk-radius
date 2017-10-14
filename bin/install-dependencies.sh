#!/bin/sh

PYTHONPATH=/opt/bsdradius/lib/python2.7/site-packages/
export PYTHONPATH


easy_install -d $PYTHONPATH /opt/bsdradius/libs/pytz-2015.4.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/chardet-3.0.4.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/idna-2.6.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/certifi-2017.7.27.1.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/urllib3-1.22.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/requests-2.18.4.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/psycopg2-2.5.1.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/anyjson-0.3.3.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/amqp-1.4.6.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/kombu-3.0.26.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/billiard-3.3.0.20.tar.gz
easy_install -d $PYTHONPATH /opt/bsdradius/libs/celery-3.1.17.tar.gz



