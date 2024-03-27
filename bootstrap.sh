#!/bin/bash

cf-remote save --hosts vagrant@192.168.56.10 --role hub --name hub
cf-remote install --demo --bootstrap hub --hub hub

# cfbs build
# cf-remote deploy --hub hub

