#! /bin/bash 

CUTNU=$(date +%d) || $(cut -c1-2) 

NU=$CUTNU

DIR=backup-admin/Accpac-Lamination
echo "" >/$DIR/Remove-Directory.txt


if [ -d /$DIR/backup-$NU-* ]
then

for N in $(seq 3 6)
do

OK="$(($NU-$N))"

if [ -d /$DIR/backup-$OK-* ]
then
echo "$OK"

#sudo ls -d /$DIR/backup-$OK-* >>/$DIR/Remove-Directory.txt 2>>/$DIR/Remove-Directory.txt
rm -rv /$DIR/backup-$OK-* >>/$DIR/Remove-Directory.txt 2>>/$DIR/Remove-Directory.txt

else
OK2=0$OK

#sudo ls -d /$DIR/backup-$OK2-* >>/$DIR/Remove-Directory.txt 2>>/$DIR/Remove-Directory.txt
rm -rv /$DIR/backup-$OK2-* >>/$DIR/Remove-Directory.txt 2>>/$DIR/Remove-Directory.txt

echo "$OK2 .. OK"
fi

done
cat /$DIR/Remove-Directory.txt | mail -s "Remove Directory-`date +%F`" ramy@$HOSTNAME ramy@localhost

else 

echo -e "\n Sorry . . . This is Directory Not Found \n"



fi

chown  ramy:ramy /$DIR/Remove-Directory.txt

#find  $DIR/backup-0?-* -ok ls -l {} \;
#find -type d -name 'backup-0?-*' -ok ls -l  {} \;

