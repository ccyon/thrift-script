#!/usr/bin/python

import sys
sys.path.append('./gen-py')

from accesspointoverride.ttypes import *

from thrift.transport import TTransport
#from thrift.protocol import TBinaryProtocol
from thrift.protocol import TCompactProtocol

import requests
import time

coord = Coordinate()
coord.latitude = 123.5 
coord.longitude = -123.5


# Attributes:
#     - id: Optional stable, unique id representing this access point
#     - coordinate: Precise coordinate of the access point
#     - types: Identifies what categories this access point belongs to
#     - label: Human readable label for this access point
#     - level: Identifies which level this access point belongs to

ap = AccessPoint()
ap.id = "ap_id"
ap.coordinate = coord
ap.types = [AccessPointType.DROPOFF] 

aps = AccessPoints()
aps.accessPoints = [ap]

override = AccessPointOverride()
override.accessPoints = aps
override.type = AccessPointType.DROPOFF
override.id = "override_id"
overrides = AccessPointOverrides()
overrides.accessPointsOverrides = [override]

interval = TimeInterval()
interval.startTimestamp = 1496583720000
interval.endTimestamp = 1597583720000

override.timeInterval = interval

# - provider
# - id
# - locale
# - overrides
request = AccessPointOverrideRequest()
request.id = "EjQyNjIwIFJlZ2VudCBTdHJlZXQsIFNhbiBGcmFuY2lzY28sIENBLCBVbml0ZWQgU3RhdGVz"
request.provider = "google_places"
request.locale = "en"
request.overrides = overrides

transportOut = TTransport.TMemoryBuffer()
protocolOut = TCompactProtocol.TCompactProtocol(transportOut)
request.write(protocolOut)

bytes = transportOut.getvalue()

headers = {'Content-Type': 'application/vnd.apache.thrift.compact'}
r = requests.post('http://localhost:5334/v1/add_access_point_override', headers=headers, data=bytes)

print(r.text)
print(r.status_code)
