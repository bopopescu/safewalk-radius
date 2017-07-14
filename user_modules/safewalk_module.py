# # BSDRadius is released under BSD license.
# # Copyright (c) 2006, DATA TECH LABS
# # All rights reserved.
# #
# # Redistribution and use in source and binary forms, with or without
# # modification, are permitted provided that the following conditions are met:
# # * Redistributions of source code must retain the above copyright notice,
# #   this list of conditions and the following disclaimer.
# # * Redistributions in binary form must reproduce the above copyright notice,
# #   this list of conditions and the following disclaimer in the documentation
# #   and/or other materials provided with the distribution.
# # * Neither the name of the DATA TECH LABS nor the names of its contributors
# #   may be used to endorse or promote products derived from this software without
# #   specific prior written permission.
# #
# # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# # ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# # WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# # DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# # ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# # (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# # LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# # ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# # (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# # SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 
# you can use functions defined in logger module to use BSD RAdius's
# logger system.
from bsdradius.safewalk_logger import *
#from bsdradius.webstuff.logger import *
from bsdradius.Config import main_config
from types import *
import exceptions
import requests
import json
import uuid

class ModusersfileError(exceptions.Exception):
  pass

 
def safewalk_funct_startup():
  info(RADIUS_SAFEWALK_START)
	 
def safewalk_funct_authz(received, check, reply):
  transaction_id = uuid.uuid4().hex
  #info(RADIUS_SAFEWALK_AUTHORIZATION, transaction_id, received = received)
  #info("Looking for username and password", received = received)
  #debug(RADIUS_RECEIVED_PACKAGE, received, received = received)
  #debug(RADIUS_CHECK_PACKAGE, check, received = received)
  reply['transaction_id'] = transaction_id
  #debug(received)
  #debug("Check data")
  #debug(check)
  #debug("Reply data")
  #debug(reply)

  authType = check.get('Auth-Type', [None])[0]
  username = received.get('User-Name', [None])[0]
  password = received.get('User-Password', [None])[0]
  if username is None:
    raise ModusersfileError, 'Attribute "User-Name" must be present in request data'
  if password is None and authType is None:
    raise ModusersfileError, 'Attribute "User-Password" must be present in request data when there is no Auth-Type set'
	
  # prepare reply message
  #reply['Reply-Message'] = "Safewalk Radius server rules"
  # reply['Session-Time'] =  [10]
  # reply['Session-Timeout'] =  630
  #debug(RADIUS_REPLY_PACKAGE, reply, received = received)

  if authType is None:
    # check if received password is correct
    check['Auth-Type'] = ['safewalk']
    return True
  else:
    # pass username and password to module which has set up it's auth type.
    debug(RADIUS_AUTH_TYPE_NONE, transaction_id, received = received)
    check['User-Name'] = [username]
    check['User-Password'] = [password]
    return True
		
def safewalk_funct_authc(received, check, reply):
  #debug(RADIUS_RECEIVED_PACKAGE, received, received = received)
  #debug(RADIUS_CHECK_PACKAGE, check, received = received)
  authType = check.get('Auth-Type', [None])[0]
  if authType == 'safewalk':
    username = received.get('User-Name', [None])[0]
    password = received.get('User-Password', [None])[0]
    ip = received.get('Client-IP-Address', [None])[0]
    state = received.get('State', [None])[0]
    
    transaction_id = state or reply.get('transaction_id')[0]
    info(RADIUS_SAFEWALK_AUTHENTICATION, transaction_id, received, received = received)
    # Do request to server
    payload = {
               'username' : username, 
               'password' : password,
               'radius_client_ip' : ip, 
               'transaction_id' : transaction_id,
               }
    url = main_config['GAIA']['base_url'] + main_config['GAIA']['authentication_path']
    access_token = main_config['GAIA']['authentication_access_token']
    headers = {'AUTHORIZATION': 'Bearer {}'.format(access_token)}
    kwargs = {'headers': headers}
    try:
      r = requests.post(url, payload, verify=False, **kwargs)
    
      if r.status_code not in [200, 401]:
        error(RADIUS_SAFEWALK_ERROR, transaction_id, {'status_code': r.status_code}, received = received)
      
      response_object = json.loads(r.text)

      response_code =  response_object.get('code')
      if 'code' in response_object: del response_object['code']
      if 'transaction-id' in response_object: del response_object['transaction-id']
      if check['forward_reply_items'][0]:
        reply.update(response_object)

      if response_code == 'ACCESS_ALLOWED':
        reply_message = "Access allowed"
        reply['Reply-Message'] = reply_message
        info(RADIUS_AUTH_SUCCEED, transaction_id, {'status_code': r.status_code}, received = received)
        return 'ALLOWED'
      elif response_code == 'ACCESS_CHALLENGE':
        reply_message = str(response_object.get('reply-message'))
        reply['Reply-Message'] = reply_message
        reply['State'] = transaction_id
        info(RADIUS_AUTH_CHALLENGE, transaction_id, {'status_code': r.status_code, 'reply_message' : reply_message}, received = received)
        return 'CHALLENGE'
      elif response_code == 'NO_RESPONSE':
        reply_message = str(response_object.get('reply-message'))
        reply['Reply-Message'] = reply_message
        reply['State'] = transaction_id
        info(RADIUS_AUTH_INACTIVE, transaction_id, {'status_code': r.status_code, 'reply_message' : reply_message}, received = received)
        return 'INACTIVE'
      else:
        reply_message = str(response_object.get('reply-message'))
        reply['Reply-Message'] = reply_message
        info(RADIUS_AUTH_DENIED, transaction_id, {'status_code': r.status_code, 'reply_message' : reply_message}, received = received)
        return 'DENIED'
    except Exception:
      reply_message = "Can't connect to Safewalk Server"
      reply['Reply-Message'] = reply_message
      error(RADIUS_AUTH_DENIED, transaction_id, {'status_code': r.status_code, 'reply_message' : reply_message}, received = received)
      return 'DENIED'
  return True
  	

def safewalk_funct_acct(received):
  info(RADIUS_SAFEWALK_ACCT_STATUS_TYPE, None, {"Acct-Status-Type": received['Acct-Status-Type']}, received = received)
  
			
def safewalk_funct_shutdown():
  info(RADIUS_SAFEWALK_SHUTDOWN)
