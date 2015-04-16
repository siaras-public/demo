#!/bin/bash

set -eux

sudo apt-get update
sudo apt-get install -y wget git

if [ -z $(which docker) ]; then
    wget -qO- https://get.docker.com/ | sh
fi

if [ -z $(which docker-compose) ]; then
    apt-get install -y python-setuptools python-pip python-dev
    pip install 'docker-compose==1.1.0'
fi

if [ ! -d /root/docker-sugarcrm ]; then
    cd /root
    git clone https://github.com/Spantree/docker-sugarcrm.git
    cd /root/docker-sugarcrm
    git checkout -b 1.0.0 1.0.0

    cat<<EOF > docker-compose.yml
sugarcrm:
  build: .
  ports:
    - "80:80"
  links:
    - "db"
  environment:
    DB_TYPE: mysql
    DB_MANAGER: MysqlManager
db:
  image: mysql
  environment:
    MYSQL_ROOT_PASSWORD: YZiT4p7BXUqpdgpc
    MYSQL_DATABASE: sugarcrm
    MYSQL_USER: sugarcrm
    MYSQL_PASSWORD: wTxbULZMrosNR86J
EOF

    cat<<EOF > Dockerfile
FROM php:5.6-apache

ENV MAJOR_VERSION 6.5
ENV MINOR_VERSION 20
ENV SOURCEFORGE_MIRROR http://softlayer-dal.dl.sourceforge.net
ENV WWW_FOLDER /var/www/html
ENV PERF_TESTER_HOST $(hostname)

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y libcurl4-gnutls-dev libpng-dev unzip cron re2c php5-imap python

RUN docker-php-ext-install mysql curl gd zip mbstring
#       apt-get install -y php5-mysql php5-imap php5-curl php5-gd curl unzip cron

WORKDIR /tmp

RUN curl -O "\${SOURCEFORGE_MIRROR}/project/sugarcrm/1%20-%20SugarCRM%20\${MAJOR_VERSION}.X/SugarCommunityEdition-\${MAJOR_VERSION}.X/SugarCE-\${MAJOR_VERSION}.\${MINOR_VERSION}.zip" && \
        unzip SugarCE-\${MAJOR_VERSION}.\${MINOR_VERSION}.zip && \
        rm -rf \${WWW_FOLDER}/* && \
        cp -R /tmp/SugarCE-Full-\${MAJOR_VERSION}.\${MINOR_VERSION}/* \${WWW_FOLDER}/ && \
        chown -R www-data:www-data \${WWW_FOLDER}/* && \
        chown -R www-data:www-data \${WWW_FOLDER}

RUN echo \${PERF_TESTER_HOST} > \${WWW_FOLDER}/hostname

# RUN sed -i 's/^upload_max_filesize = 2M$/upload_max_filesize = 10M/' /usr/local/etc/php/php.ini

ADD config_override.php.pyt /usr/local/src/config_override.php.pyt
ADD envtemplate.py /usr/local/bin/envtemplate.py
ADD init.sh /usr/local/bin/init.sh

RUN chmod u+x /usr/local/bin/init.sh

ADD crons.conf /root/crons.conf
RUN crontab /root/crons.conf

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/init.sh"]
EOF

    cat<<EOF > /etc/rc.local
#!/bin/sh

(cd /root/docker-sugarcrm; \
    /usr/local/bin/docker-compose up > /tmp/docker.log 2>&1)&
EOF
    chmod 755 /etc/rc.local

    docker-compose build
    /etc/rc.local
fi



