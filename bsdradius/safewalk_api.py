import json
from UserDict import UserDict
from bsdradius.logger import *
from bsdradius.Config import main_config
import requests



class SafewalkAPI(UserDict):
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
		safewalk_conf = main_config['SAFEWALK']
		url = '%s://%s:%s%s' % (
		safewalk_conf['swk_protocol'], safewalk_conf['swk_host'], safewalk_conf['swk_api_port'], safewalk_conf['swk_client_list_path'])
		access_token = safewalk_conf['swk_api_access_token']
		headers = {'AUTHORIZATION': 'Bearer {}'.format(access_token)}
		kwargs = {'headers': headers}
		clients=[]
		try:
			r = requests.get(url, verify=False, **kwargs)

			if r.status_code == 200:
				response_object = json.loads(r.text)
				for client in response_object:
					clients.append((client.get('address'), client.get('name'), client.get('secret'), client.get('forward_reply_items'),))
			else:
				raise Exception("Safewalk connection error")
		except:
			raise Exception("Safewalk connection error")
		return clients