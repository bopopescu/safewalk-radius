#!/bin/sh

PYTHONPATH=/opt/bsdradius/lib/python2.7/site-packages/
export PYTHONPATH

easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ requests
easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ psycopg2
easy_install -d /opt/bsdradius/lib/python2.7/site-packages/ celery
