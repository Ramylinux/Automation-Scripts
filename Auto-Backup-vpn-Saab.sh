#! /bin/bash

DIRVPN=/backup-admin/vpn-backup-auto
pkill openvpn 
echo -e "\n Kill openvpn \n" > $DIRVPN/vpn-saab.log
openvpn --config $DIRVPN/saab-factory.conf >> $DIRVPN/vpn-saab.log &

echo " Connect VPN Saab-Factory ...  "

for NO in $(seq 1 3)
do
ping -c10 -W1  Server-ACC &>/dev/null

if [ $? = 0 ] 
then
echo " Server Saab is UP - $NO" >>$DIRVPN/vpn-saab.log

################################################

if [ $NO -eq 3 ] 
then

umount /backup-admin/Hard-ACC-Saab
echo -e " \n connect Server: Server-ACC\n"
mount -t cifs //Server-ACC/Acc /backup-admin/Hard-ACC-Saab/ -o credential=/etc/samba/cred.txt || echo " error mount " | mail -s " error mount " ramy@localhost
echo -e " Connect .. ok\n "

DIR=backup-`date +%d-%m-%Y`
TARGET=backup-admin/ACC-Saab/$DIR
SOURCE=backup-admin/Hard-ACC-Saab 
FILES=Acc
ADDRESS=ramy@localhost 
ADDRESS2=ramy@$HOSTNAME

if [ -d /$TARGET ]
then

echo -e "\n Update $DIR Directory \n"

tar -czf /$TARGET/ACC-Saab-`date +%d-%m-%Y`.tar.gz  /$SOURCE/* >/$TARGET/Done-ACC-Saab-`date +%d-%m-%Y`.txt 2>/$TARGET/Error-ACC-Saab-`date +%d-%m-%Y`.txt && du -h /$TARGET/* >> /$TARGET/Done-ACC-Saab-`date +%d-%m-%Y`.txt && cat /$TARGET/Done-ACC-Saab-`date +%d-%m-%Y`.txt | mail -s "Done Backup-ACC-Saab-`date +%F`" $ADDRESS $ADDRESS2 || cat /$TARGET/Error-ACC-Saab-`date +%d-%m-%Y`.txt | mail -s "Error Backup-ACC-Saab-`date +%F`" $ADDRESS $ADDRESS2


umount /$SOURCE  && echo -e "\n disconnect Server ... ok\n" || echo " (umount Error)  ACCServer-Saab Connect" | mail -s "umount Error-ACC-Saab-`date +%F`" $ADDRESS2 $ADDRESS

else

mkdir /$TARGET

tar -czf /$TARGET/ACC-Saab-`date +%d-%m-%Y`.tar.gz  /$SOURCE/* >/$TARGET/Done-ACC-Saab-`date +%d-%m-%Y`.txt 2>/$TARGET/Error-ACC-Saab-`date +%d-%m-%Y`.txt && du -h /$TARGET/* >> /$TARGET/Done-ACC-Saab-`date +%d-%m-%Y`.txt && cat /$TARGET/Done-ACC-Saab-`date +%d-%m-%Y`.txt | mail -s "Done Backup-ACC-Saab-`date +%F`" $ADDRESS $ADDRESS2 || cat /$TARGET/Error-ACC-Saab-`date +%d-%m-%Y`.txt | mail -s "Error Backup-ACC-Saab-`date +%F`" $ADDRESS $ADDRESS2


umount /$SOURCE  && echo -e "\n disconnect Server ... ok\n" || echo " (umount Error)  ACCServer-Saab Connect" | mail -s "umount Error-ACC-Saab-`date +%F`" $ADDRESS2 $ADDRESS


fi
chown -R ramy:ramy /$TARGET


fi
############################################################################


else
echo " Server Saab is Down - $NO" >>$DIRVPN/vpn-saab.log

fi
done
