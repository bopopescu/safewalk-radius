'''
Created on Nov 24, 2014

@author: ataboada
'''
from celery import Celery
from bsdradius.Config import main_config

amqp_broker_usr = 'safewalk'
amqp_broker_pwd = 'b963a869d28fff3cdfaf1748250e2e30'
amqp_host = 'localhost'

app = Celery('tasks', broker='amqp://%s:%s@%s//' % (
  amqp_broker_usr,
  amqp_broker_pwd,
  amqp_host,
))

default_queue_name = 'safewalk-default'
app.conf.CELERY_DEFAULT_QUEUE = default_queue_name
app.conf.CELERY_DEFAULT_EXCHANGE = default_queue_name
app.conf.CELERY_DEFAULT_ROUTING_KEY = default_queue_name

@app.task
def async_log(level, message_id, message_params, received):
  """
  Dummy task. Real task is inside safewalk server at dblogging/tasks.py
  """
  pass
  