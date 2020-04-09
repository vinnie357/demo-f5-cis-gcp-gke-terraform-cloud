#!/bin/bash
ip=${ip}
user=${adminAccount}
#echo -n "Enter host ip"
#read ip
#echo -n "Enter adminUsername"
#read user
echo -n "Enter your ssh private key path ~/.ssh/id_rsa"
read sshkey
eval $(ssh-agent -s)
ssh-add $sshkey
ssh -oStrictHostKeyChecking=no $user@"$ip" 'modify cli preference pager disabled display-threshold 0; revoke sys license'