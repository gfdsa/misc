#!/usr/bin/python
""" This is a 15 minutes hack so don't expect any fancies from it
The ispapi is this one: https://github.com/retailify/ispapi
Just pass it as --manual-auth-hook and --manual-cleanup-hook
or put in the reneal config as manual_auth_hook and manual_cleanup_hook
"""

import ispapi
import sys
import os
import re
import time

api = ispapi.connect(
    url = 'https://coreapi.1api.net/api/call.cgi',
    entity = '54cd', # production
    login = YOUR ACCOUNT,
    password = YOUR PASSWORD
)
# certbot keeps the FQDN here
domain = re.search('[^.]+\.[^.]+$', os.environ['CERTBOT_DOMAIN']).group(0)

#check if we have the domain (we do but not all, so you can skip it)
response = api.call({
  'Command': "QueryDomainList", 'limit' : 5, 'domain': domain
})
code = response.code()
description = response.description()

print "%s: response code %s, description: %s\n%s"%(domain, code, description, response.as_list())

if code == 200:
  # ok, check if we have the zone ready
  response = api.call( {
    'Command': "StatusDNSZone",
    'dnszone': domain + '.'
  })
  code = response.code()
  description = response.description()

  print "%s: response code %s, description: %s\n%s"%(domain, code, description, response.as_list())
  if code == 200:
    if os.environ.has_key('CERTBOT_AUTH_OUTPUT'):
      # we are in delete mode
      print "deleting"
      response = api.call({
        'Command': 'UpdateDNSZone',
        'dnszone': domain + '.',
        'delrr0': '_acme-challenge.'+os.environ['CERTBOT_DOMAIN']+'. %'
      })
    else:
      # add the record
      print "adding"
      response = api.call({
        'Command': 'UpdateDNSZone',
        'dnszone': domain + '.',
        'addrr0': '_acme-challenge.'+os.environ['CERTBOT_DOMAIN']+'. 30 IN TXT '+os.environ['CERTBOT_VALIDATION']
      })
    code = response.code()
    description = response.description()

    print "%s: response code %s, description: %s\n%s"%(domain, code, description, response.as_list())

# let it settle a bit
time.sleep(30)
