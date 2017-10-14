#!/bin/bash

source /home/safewalk/safewalk-server-venv/bin/activate

django-admin.py shell --settings=gaia_server.settings<<EOF

from gaia_radius_interface.models import RadiusClient
import json

clients = RadiusClient.objects.filter(is_active=True).values('name','address', 'secret', 'forward_reply_items')

with open('/tmp/radius_clients', mode='w') as f:
    json.dump(list(clients), f)
    print 'guardado'

EOF

deactivate
