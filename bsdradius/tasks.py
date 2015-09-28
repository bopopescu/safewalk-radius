'''
Created on Nov 24, 2014

@author: ataboada
'''
from celery import Celery

app = Celery('tasks', broker='amqp://guest@localhost//')

@app.task
def async_log(level, message_id, message_params, received):
  """
  Dummy task. Real task is inside safewalk server at dblogging/tasks.py
  """
  pass
  