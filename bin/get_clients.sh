#!/bin/bash

source /home/safewalk/safewalk-server-venv/bin/activate
CLIENT_ID=$1

export CLIENT_ID

django-admin.py shell --settings=gaia_server.settings<<EOF

from gaia_radius_interface.models import RadiusClient
import json

clients = RadiusClient.objects.filter(is_active=True)
r_clients=[]
for c in clients:
  r_clients.append({
    'name': c.name,
    'address': c.address,
    'secret': c.secret,
    'forward_reply_items': c.forward_reply_items
  })

with open('/tmp/radius_clients', mode='w') as f:
    json.dump(r_clients, f)
    print 'guardado'

EOF

deactivate
