apt-get install -y git docker.io python-setuptools python-pip python-dev
pip install -U docker-compose
cd /root
git clone https://github.com/Spantree/docker-sugarcrm.git
cd /root/docker-sugarcrm
docker-compose -d up
