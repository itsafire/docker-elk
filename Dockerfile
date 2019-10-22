#Kibana

FROM ubuntu:18.04
 
#Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

RUN DEBIAN_FRONTEND=noninteractive apt-get clean && \
    DEBIAN_FRONTEND=noninteractive apt-get autoclean && \
    DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y supervisor && \
	mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y vim less nano ntp net-tools inetutils-ping curl git telnet wget nginx ca-certificates openjdk-11-jre-headless

#ElasticSearch
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.4.0-amd64.deb && \
    dpkg -i elasticsearch*.deb && \
    rm elasticsearch-*.deb

#Kibana
RUN wget https://artifacts.elastic.co/downloads/kibana/kibana-7.4.0-linux-x86_64.tar.gz && \
    tar xf kibana-*.tar.gz && \
    rm kibana-*.tar.gz && \
    mv kibana-* kibana && \
    chown -R www-data:www-data kibana
    

RUN wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.4.0-amd64.deb && \
    dpkg -i metricbeat*.deb && \
    rm metricbeat*.deb

#Logstash
RUN wget https://artifacts.elastic.co/downloads/logstash/logstash-7.4.0.deb && \
    dpkg -i logstash*.deb && \
    rm logstash-*.deb

#Configuration
ADD logstash.d/logstash.conf /etc/logstash/
ADD nginx.conf /etc/nginx/nginx.conf
ADD supervisord-kibana.conf /etc/supervisor/conf.d

#80=ngnx, 5601=kibna, 9200=elasticsearch, 49021=logstash, 49022=lumberjack, 9999=udp
EXPOSE 5601 9200 49021 49022 25826 9999/udp
