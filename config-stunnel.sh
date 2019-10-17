#!/bin/bash
INT_IP=192.168.101.10

#Uncomment EXT_IP you are using NAT fro communication between nodes
#EXT_IP=

[ -d out ] || mkdir out

python3.6 ./stunnel-config-generator.py $INT_IP $EXT_IP

iptables-save | grep -i "stunnel rule" | sed 's/-A OUTPUT/iptables -t nat -D OUTPUT/g'  > ./out/iptables.tmp
echo "#!/bin/bash" > ./out/iptables-rules.sh
cat ./out/iptables.tmp >> ./out/iptables-rules.sh
cat ./out/iptables-rules.txt >> ./out/iptables-rules.sh

chmod +x ./out/iptables-rules.sh
sudo ./out/iptables-rules.sh

cat stunnel-header.conf > ./out/stunnel-full.conf
cat ./out/stunnel.conf >> ./out/stunnel-full.conf

#
# Uncomment this to generate keys with script
# If you are using certificate generation script "as is", you should correct "verify" parameter in stunnel-full.conf from '2' to '0' 
#
#read -p "Do you want to generate server and client certs? [y/n] " -n 1 -r
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Yy]$ ]]
#then
#  /opt/cprocsp/bin/amd64/certmgr -inst -f ./cacerts.p7b -all -store uRoot
#  chmod +x ./create-certs.sh
#  ./create-certs.sh  
#fi

sudo /opt/cprocsp/sbin/amd64/stunnel_thread ./out/stunnel.conf
