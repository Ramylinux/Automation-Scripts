#! /bin/bash 
umount /backup-admin/Hard-Lamination-Seg
echo -e " \n connect Server: Server-ACC\n"
mount -t cifs //Server-ACC/SegmentBackup/AutoBackup /backup-admin/Hard-Lamination-Seg/ -o credential=/etc/samba/cred.txt || echo " error mount-Lam(First Step) " | mail -s " error mount-Lam " ramy@localhost

echo -e " Connect .. ok\n "

DIR=backup-`date +%d_%m_%Y`
DATE=`date +%Y_%m_%d`

TARGET=backup-admin/Segment-Lamination/$DIR
SOURCE=backup-admin/Hard-Lamination-Seg 
FILE1=LamHRSysBkp.bak$DATE* 
FILE2=LamHRDateBkp.bak$DATE*
FILE3=SegmentsLam_backup_$DATE*
ADDRESS=ramy@localhost
ADDRESS2=ramy@$HOSTNAME


if [ -d /$TARGET ]
then

echo -e "\n Update $DIR Directory \n"

cd /$SOURCE
 

tar -czf  /$TARGET/LamSegData-`date +%d-%m-%Y`.tar.gz  $FILE3 >/$TARGET/Done-LamData-`date +%d-%m-%Y`.txt 2>/$TARGET/Error-LamData-`date +%d-%m-%Y`.txt && du -h /$TARGET/* >> /$TARGET/Done-LamData-`date +%d-%m-%Y`.txt && cat /$TARGET/Done-LamData-`date +%d-%m-%Y`.txt | mail -s "Done Backup-LamData`date +%F`" $ADDRESS $ADDRESS2 || cat /$TARGET/Error-HRData-`date +%d-%m-%Y`.txt | mail -s "Error Backup-LamData`date +%F`" $ADDRESS $ADDRESS2


cd /
cd ; umount /$SOURCE  && echo -e "\n disconnect Server ... ok\n" || echo " (umount Error)  Server-Lam Connect" | mail -s "umount Error-Lam-`date +%F`" $ADDRESS2 $ADDRESS

else

mkdir /$TARGET

cd /$SOURCE


tar -czf  /$TARGET/LamSegData-`date +%d-%m-%Y`.tar.gz  $FILE3 >/$TARGET/Done-LamData-`date +%d-%m-%Y`.txt 2>/$TARGET/Error-LamData-`date +%d-%m-%Y`.txt && du -h /$TARGET/* >> /$TARGET/Done-LamData-`date +%d-%m-%Y`.txt && cat /$TARGET/Done-LamData-`date +%d-%m-%Y`.txt | mail -s "Done Backup-LamData`date +%F`" $ADDRESS $ADDRESS2 || cat /$TARGET/Error-HRData-`date +%d-%m-%Y`.txt | mail -s "Error Backup-LamData`date +%F`" $ADDRESS $ADDRESS2


cd /

cd ; umount /$SOURCE  && echo -e "\n disconnect Server ... ok\n" || echo " (umount Error)  Server-Lam Connect" | mail -s "umount Error-lam-`date +%F`" $ADDRESS2 $ADDRESS


fi

chown -R ramy:ramy /$TARGET
