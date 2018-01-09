#Kibana

FROM ubuntu:16.04
 
#Prevent daemon start during install
RUN	echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d && \
    chmod +x /usr/sbin/policy-rc.d

RUN DEBIAN_FRONTEND=noninteractive apt-get clean
RUN DEBIAN_FRONTEND=noninteractive apt-get autoclean
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y --no-install-recommends

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y supervisor && \
	mkdir -p /var/log/supervisor
CMD ["/usr/bin/supervisord", "-n"]

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y vim less nano ntp net-tools inetutils-ping curl git telnet wget openjdk-8-jdk-headless nginx

#ElasticSearch
RUN wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.7.2.tar.gz && \
    tar xf elasticsearch-*.tar.gz && \
    rm elasticsearch-*.tar.gz && \
    mv elasticsearch-* elasticsearch && \
    elasticsearch/bin/plugin -install mobz/elasticsearch-head

#Kibana
RUN wget https://download.elastic.co/kibana/kibana/kibana-4.1.2-linux-x64.tar.gz && \
    tar xf kibana-*.tar.gz && \
    rm kibana-*.tar.gz && \
    mv kibana-* kibana

#Logstash
RUN wget https://download.elasticsearch.org/logstash/logstash/logstash-1.5.4.tar.gz && \
	tar xf logstash-*.tar.gz && \
    rm logstash-*.tar.gz && \
    mv logstash-* logstash
    
#LogGenerator
#RUN git clone https://github.com/vspiewak/log-generator.git && \
#	cd log-generator && \
#	/usr/share/maven/bin/mvn clean package

#Geo
#RUN wget -N http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz && \
#	gunzip GeoLiteCity.dat.gz && \
#    mv GeoLiteCity.dat /log-generator/GeoLiteCity.dat

#Configuration
ADD ./ /docker-elk
RUN cd /docker-elk && \
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.saved && \
    cp nginx.conf /etc/nginx/nginx.conf && \
    cp supervisord-kibana.conf /etc/supervisor/conf.d 

#    cp logback /logstash/patterns/logback && \
#    cp logstash-forwarder.crt /logstash/logstash-forwarder.crt && \
#    cp logstash-forwarder.key /logstash/logstash-forwarder.key

ADD elasticsearch.yml /elasticsearch/config/

#80=ngnx, 5601=kibna, 9200=elasticsearch, 49021=logstash, 49022=lumberjack, 9999=udp
EXPOSE 5601 9200 49021 49022 25826 9999/udp
