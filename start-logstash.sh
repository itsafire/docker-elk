#!/bin/bash

echo 'cat <<END_OF_TEXT' >  temp.sh
cat /docker-elk/logstash.d/logstash.conf  >> temp.sh
echo 'END_OF_TEXT'       >> temp.sh
bash temp.sh > /docker-elk/logstash.d/logstash.conf
rm temp.sh

cd /logstash
exec /logstash/bin/logstash -f /docker-elk/logstash.d/logstash.conf
