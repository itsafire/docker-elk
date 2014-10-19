#!/bin/bash

cd /logstash
exec /logstash/bin/logstash -f /docker-elk/logstash.d/logstash.conf
