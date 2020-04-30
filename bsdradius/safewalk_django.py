import json
from UserDict import UserDict
from bsdradius.logger import *
from bsdradius.Config import main_config
import subprocess
import os

CLIENT_ID = os.environ['CLIENT_ID']

if CLIENT_ID:
	RADIUS_CLIENTS_FILE = '/tmp/radius_clients_%s' % CLIENT_ID
else:
	RADIUS_CLIENTS_FILE='/tmp/radius_clients'

class SafewalkDjango(UserDict):
	"""Class for readin configuration data from Safewalk
	"""
	
	def __init__(self):
		UserDict.__init__(self)
		self.data['CLIENTS'] = {}



	def ReadClients(self, verbose = False):
		"""Read or refresh radius client data from DB
			Input: (bool) be verbose and print some debugging info
			Output: (none)
		"""
		result = self._get_clients()
		old_clients = self['CLIENTS'].keys()
		for row in result:
			key = row[0]
			self['CLIENTS'][key] = {'name': row[1], 'secret': row[2], 'forward_reply_items':row[3]}
			if key in old_clients:
				old_clients.remove(key)
		for key in old_clients:
			del self['CLIENTS'][key]
		return old_clients

	def _get_clients(self):
		clients=[]
		command = main_config['PATHS']['django_command_file']
		customer = main_config['SAFEWALK']['customer']
		with open(os.devnull, 'w') as devnull:
			subprocess.call([command, customer], stdout=devnull, stderr=devnull)
		try:
			with open(RADIUS_CLIENTS_FILE) as json_data:
				d = json.load(json_data)
				os.remove(RADIUS_CLIENTS_FILE)
				for client in d:
					clients.append((client.get('address'), client.get('name'), client.get('secret'), client.get('forward_reply_items'),))
		except Exception, e:
			error(e)
		return clients