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

    cd /root/docker-sugarcrm
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
FROM jchiu/sugarcrm-demo

ENV WWW_FOLDER /var/www/html
ENV PERF_TESTER_HOST PERF_TESTER_HOST_VAL
RUN echo \${PERF_TESTER_HOST} > \${WWW_FOLDER}/hostname

EOF

  cat<<EOF > /etc/rc.local
#!/bin/sh
