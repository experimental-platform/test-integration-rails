#!/usr/bin/env bash

# enable fail detection...
set -e
source /initialize.sh
initialize


echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
HOSTIP=$(vagrant ssh-config | awk '/HostName/ {print $2}')

cat /.ssh/id_rsa.pub | vagrant ssh -c "docker exec -i dokku sshcommand acl-add dokku root"

echo -e "\nCLONING repo\n"

git clone https://github.com/experimental-platform/rails-hello-world.git

cd rails-hello-world/

git config user.email "aal@protonet.info"
git config user.name "Protonet Integration Test Rails"
# http://progrium.viewdocs.io/dokku/checks-examples.md
echo -e "WAIT=10\nATTEMPTS=20\n/ Hello" > CHECKS
git add .
git commit -a -m "Initial Commit"

echo -e "\nRUNNING git push to ${HOSTIP}\n"

git remote add protonet ssh://dokku@${HOSTIP}:8022/rails-app
# destroy in case it's already deployed
ssh -t -p 8022 dokku@${HOSTIP} apps:destroy rails-app force || true
# ssh -t -p 8022 dokku@${HOSTIP} trace on
git push protonet master

wget http://${HOSTIP}/rails-app/ || true
echo -e "\n\nWaiting a few seconds for rails to start..."

sleep 30 # TODO: check if this is still necessary

wget http://${HOSTIP}/rails-app/
