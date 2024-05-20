# I wrote this using ChatGPT

import logging
import json
import socket
import os
import time
from pythonjsonlogger import jsonlogger
from datetime import datetime
import pytz
import netifaces

def get_internal_ip():
    for interface in netifaces.interfaces():
        try:
            addrs = netifaces.ifaddresses(interface) [netifaces.AF_INET]
            for addr in addrs:
                if not addr['addr'].startswith('127.'):
                    return addr['addr']
        except KeyError:
            continue
    return 'N/A'

class CustomJsonFormatter(jsonlogger.JsonFormatter):
    def add_fields(self, log_record, record, message_dict):
        super(CustomJsonFormatter, self).add_fields(log_record, record, message_dict)
        log_record['user'] = os.getenv('USER') or os.getenv('USERNAME') or 'Unknown'
        log_record['ip'] = get_internal_ip()
        log_record['location'] = time.tzname[0]

log_handler = logging.StreamHandler()
formatter = CustomJsonFormatter()
log_handler.setFormatter(formatter)
logger = logging.getLogger("JsonLogger")
logger.addHandler(log_handler)
logger.setLevel(logging.INFO)

log_directory = "/var/log"
log_filename = "logger.log"
log_filepath = os.path.join(log_directory, log_filename)

if not os.path.exists(log_directory):
    os.makedirs(log_directory)

file_handler = logging.FileHandler(log_filepath)
file_handler.setFormatter(CustomJsonFormatter())
logger.addHandler(file_handler)

def log_message(level, message):
    if level.lower() == 'info':
        logger.info(message)
    elif level.lower() == 'error':
        logger.error(message)

log_message('info', 'This is an informational message')
log_message('error', 'This is an error message')