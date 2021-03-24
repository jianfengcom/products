#!/bin/bash
#
# */10 * * * * 


dir=/data1/sh/apk
url_save_dir=${dir}/pc_file
url_save_file=${url_save_dir}/pc_file_$(date "+%F_%H-%M")
pc_dir=/data1/devupload/web/apkdoanload/
backup_dir=${dir}/backup_pc
###20170719
remote_dir=/data1/ftp-new-apk.pconline.com.cn/pub/download/

ftp_ip="192.168.246.68 192.168.246.67"
log_dir=${dir}/log
log_file=${log_dir}/$(date "+%F_%H-%M").log


if [ -f /tmp/.rsync59240_222.tag ];then
   echo "`date +%Y%m%d%H%M%S`:rsync_to59240 is already running" 
   exit 0
fi


[ ! -d ${backup_dir} ] && mkdir -p ${backup_dir}
[ ! -d ${url_save_dir} ] && mkdir -p ${url_save_dir}
[ ! -d ${log_dir} ] && mkdir -p ${log_dir}

[ -f ${url_save_file} ] && /bin/rm -rf ${url_save_file}

###pro=$(ps axu|grep wget_apk_file_and_sync_to_ftp-new-apk.sh|grep -v grep|wc -l)
###[ ${pro} -lt 0 ] && echo "still running" >>  ${log_file}  2>&1 && exit 7

wget -O ${url_save_file} 'http://192.168.238.160:8080/intf/developer/getNewApkLog.jsp?minute=60&type=1&size=300' >>  ${log_file}  2>&1
#wget -O ${url_save_file} 'http://192.168.238.160:8080/testcases/test_getNewApkLog.jsp' >>  ${log_file}  2>&1


count=$(cat ${url_save_file}|wc -l)
if [ "${count}" -gt 0 ]
then
        touch   /tmp/.rsync59240_222.tag
	[ -d "/data1/win/$(date +%Y%m%d)/ftp-new-apk.pconline.com.cn/pub/download/" ] || mkdir -p /data1/win/$(date +%Y%m%d)/${remote_dir#/*/}
	cp -a ${backup_dir}/${Date_dir}/pconline${Date_file}  /data1/win/$(date +%Y%m%d)/${remote_dir#/*/}
	cat ${url_save_file}|grep -v "^$" |while read line
	do
                Date_dir=$(echo $line|awk -F\/ '{print $1}')

                Date_file=$(echo $line|awk -F\/ '{print $2}')

		#[ -f "${backup_dir}/${Date_dir}/pconline${Date_file}" ] && continue
		#[ -f "${backup_dir}/${Date_dir}/pconline${Date_file}" ] || continue
		#[ -f /tmp/1 ] && continue
         

                [ -d "${backup_dir}/${Date_dir}/" ] || mkdir ${backup_dir}/${Date_dir}/

		[ -f "${pc_dir}/${Date_file}" ] && /bin/cp -f ${pc_dir}/${Date_file} ${backup_dir}/${Date_dir}/pconline${Date_file}

		for i in ${ftp_ip}
		do
		  #/usr/bin/rsync -avzPu  --bwlimit=7000 --timeout=10 ${backup_dir}/${Date_dir}/pconline${Date_file} ${i}::ftp-new-apk/${Date_dir}/ >>  ${log_file}  2>&1
		  /usr/bin/rsync -avzPu  --bwlimit=30000 --timeout=10 ${backup_dir}/${Date_dir}/pconline${Date_file} ${i}::ftp-new-apk/${Date_dir}/ >>  ${log_file}  2>&1
			#[ $? -ne 0 ] && /usr/bin/rsync -avzPu  --bwlimit=7000 --timeout=10 ${backup_dir}/${Date_dir}/pconline${Date_file} ${i}::ftp-new-apk/${Date_dir}/ >>  ${log_file}  2>&1
			[ $? -ne 0 ] && /usr/bin/rsync -avzPu  --bwlimit=30000 --timeout=10 ${backup_dir}/${Date_dir}/pconline${Date_file} ${i}::ftp-new-apk/${Date_dir}/ >>  ${log_file}  2>&1

		done

                echo "curl -I http://192.168.238.160:8080/sync/apk/result.do?fileName=$line" >> /data1/sh/apk/log/curl.log
                curl  http://192.168.238.160:8080/sync/apk/result.do?fileName=$line >> /data1/sh/apk/log/curl.log

	done

rm -f  /tmp/.rsync59240_222.tag

fi


#/usr/bin/find ${pc_dir} -mtime +14 -exec rm -f {} \; > /dev/null 2>&1
#/usr/bin/find ${backup_dir} -mtime +1 -exec rm -f {} \; > /dev/null 2>&1
#/usr/bin/find ${backup_dir} -mmin +150 -exec rm -f {} \; > /dev/null 2>&1
#/usr/bin/find ${log_dir} -mtime +30 -exec rm -f {} \; > /dev/null 2>&1
#/usr/bin/find ${url_save_file} -mtime +7 -exec rm -f {} \; > /dev/null 2>&1
