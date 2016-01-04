'''
Created on Nov 21, 2014

@author: ataboada
'''
from bsdradius.tasks import async_log
from bsdradius.webstuff import logger
import uuid

RADIUS_SAFEWALK_SHUTDOWN = 'RADIUS_SAFEWALK_SHUTDOWN'
RADIUS_SAFEWALK_START = 'RADIUS_SAFEWALK_START'

RADIUS_SAFEWALK_AUTHORIZATION = 'RADIUS_SAFEWALK_AUTHORIZATION'
RADIUS_SAFEWALK_AUTHENTICATION = 'RADIUS_SAFEWALK_AUTHENTICATION'
RADIUS_RECEIVED_PACKAGE = 'RADIUS_RECEIVED_PACKAGE'
RADIUS_CHECK_PACKAGE = 'RADIUS_CHECK_PACKAGE'
RADIUS_REPLY_PACKAGE = 'RADIUS_REPLY_PACKAGE'
RADIUS_AUTH_TYPE_NONE = 'RADIUS_AUTH_TYPE_NONE'
RADIUS_SAFEWALK_ERROR = 'RADIUS_SAFEWALK_ERROR'

RADIUS_AUTH_SUCCEED = 'RADIUS_AUTH_SUCCEED'
RADIUS_AUTH_CHALLENGE = 'RADIUS_AUTH_CHALLENGE'
RADIUS_AUTH_INACTIVE = 'RADIUS_AUTH_INACTIVE'
RADIUS_AUTH_DENIED = 'RADIUS_AUTH_DENIED'

RADIUS_SAFEWALK_ACCT_STATUS_TYPE = 'RADIUS_SAFEWALK_ACCT_STATUS_TYPE'



class SafewalkLogger(object):
  
  def log(self, level, message_id, transaction_id=None, message_params={}, received = {}):
    if not transaction_id:
      transaction_id = uuid.uuid4().hex
      
    message_params = message_params.copy()
    received = received.copy()
    if 'User-Password' in message_params.keys():
      message_params['User-Password'] = ['********']
    if 'User-Password' in received.keys():
      received['User-Password'] = ['********']
    try:
      async_log.delay(level, message_id, transaction_id, message_params, received)
    except:
      pass
    if level=='warn':
      level='warning'
    fn = getattr(logger, level)
    fn("MESSAGE: %s PARAMS: %s" % (message_id, message_params))

safewalk_logger = SafewalkLogger()

def debug(*args, **kwargs):
  global safewalk_logger
  safewalk_logger.log('debug', *args, **kwargs)

def info(*args, **kwargs):
  global safewalk_logger
  safewalk_logger.log('info', *args, **kwargs)
  
def warn(*args, **kwargs):
  global safewalk_logger
  safewalk_logger.log('warn', *args, **kwargs)

def error(*args, **kwargs):
  global safewalk_logger
  safewalk_logger.log('error', *args, **kwargs)
  
  
warning = warn