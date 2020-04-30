#!/bin/bash

source /home/safewalk/safewalk-server-venv/bin/activate
CLIENT_ID=$1

export CLIENT_ID

django-admin.py shell --settings=gaia_server.settings<<EOF

from gaia_radius_interface.models import RadiusClient
import json

CLIENT_ID = os.environ['CLIENT_ID']

if CLIENT_ID:
	RADIUS_CLIENTS_FILE = '/tmp/radius_clients_%s' % CLIENT_ID
else:
	RADIUS_CLIENTS_FILE='/tmp/radius_clients'

clients = RadiusClient.objects.filter(is_active=True)
r_clients=[]
for c in clients:
  r_clients.append({
    'name': c.name,
    'address': c.address,
    'secret': c.secret,
    'forward_reply_items': c.forward_reply_items
  })

with open(RADIUS_CLIENTS_FILE, mode='w') as f:
    json.dump(r_clients, f)

EOF
CLIENT_ID=
deactivate
