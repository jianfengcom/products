#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

#Date=$(date +%Y-%m-%d)
Date=$(date +%Y-%m-%d --date="-1 day")

Deldate=$(date +%Y-%m-%d --date="-2 day")

list="/data/script/putlist.txt"
#DateDir=$(cat ${list}|head -1|sed -re 's/(.*[\/])(.*)/\1/')
#cd ${DateDir}

find /data/cac/${Date} -type f -name "*.txt" > ${list}

DateDir=$(cat ${list}|head -1|sed -re 's/(.*[\/])(.*)/\1/')
cd ${DateDir}

for line in $(cat ${list})
do
   file=$(echo ${line}|head -1|sed -re 's/(.*[\/])(.*)/\2/')
   ztfile=$(echo ${file}|awk -F\. '{print $1}')
   zip -r -9 ${ztfile}.tmp.zip ${file} 
   #openssl enc -aes-128-cbc -e -in ${ztfile}.tmp.zip -out ${ztfile}.zip -K "6F823C26602F935289C4410E90A00303" -iv "146C8D2D2384A044084BF7C000ACBB3D"
   openssl enc -aes-128-cbc -e -in ${ztfile}.tmp.zip -out ${ztfile}.zip -K "8AB74A435BD5CAC2E1CD9157CBA9879D" -iv "2A441C711EE00DA67F34D129AC9B65D3"
   md5sum ${ztfile}.zip > ${ztfile}.zip.md5
   rm -f ${ztfile}.tmp.zip
done

lftp -u pconline,bQ8up4PQAmbrgh1iU84Q  sftp://111.205.235.131:65101 << EOF
     cd '/data'
    #[[ -d ${Date} ]] || mkdir ${Date}
     mkdir ${Date}
     cd ${Date}
     lcd /data/cac/${Date}
     mput *.zip
     mput *.md5
     bye
EOF

rm -f *.zip *.md5
rm -rf /data/cac/${Deldate}
cat /dev/null > ${list}
