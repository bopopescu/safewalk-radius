#!/bin/sh

PYTHONPATH=/opt/bsdradius/lib/python2.7/site-packages/
export PYTHONPATH

#easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ requests
#easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ psycopg2
#easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ celery

easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ /opt/bsdradius/libs/requests-2.3.0.tar.gz
easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ /opt/bsdradius/libs/psycopg2-2.5.1.tar.gz
easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ /opt/bsdradius/libs/anyjson-0.3.3.tar.gz
easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ /opt/bsdradius/libs/amqp-1.4.6.tar.gz
easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ /opt/bsdradius/libs/kombu-3.0.26.tar.gz
easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ /opt/bsdradius/libs/billiard-3.3.0.20.tar.gz
easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ /opt/bsdradius/libs/celery-3.1.17.tar.gz



