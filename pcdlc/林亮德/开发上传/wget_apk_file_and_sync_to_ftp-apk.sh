#!/bin/bash
#
# */10 * * * * 
#112.5.251.213 112.5.251.214 112.5.251.215通过192.168.10.105rsync到


dir=/data/sh/devupload
url_save_dir=${dir}/apk_file
url_save_file=${url_save_dir}/apk_file_$(date "+%F_%H-%M")
apk_dir=/data/devupload/web/upload
#apk_dir=/data1/devupload/web/apkdoanload/
backup_dir=${dir}/backup_apk
remote_dir=/data/ftp-apk.pconline.com.cn/pub/download/201010
#ftp_apk_ip="192.168.168.43 192.168.168.44 192.168.168.45 192.168.229.146 192.168.229.148 192.168.10.105"
#ftp_apk_ip="192.168.229.146 192.168.229.148 192.168.10.105 192.168.231.57 192.168.230.172"
ftp_apk_ip="192.168.231.57 192.168.230.172 192.168.10.105"
#ftp_apk_ip="192.168.231.57 192.168.230.172"
log_dir=${dir}/log
log_file=${log_dir}/$(date "+%F_%H-%M").log

[ ! -d ${backup_dir} ] && mkdir -p ${backup_dir}
[ ! -d ${log_dir} ] && mkdir -p ${log_dir}

[ -f ${url_save_file} ] && /bin/rm -rf ${url_save_file}

pro=$(ps axu|grep wget_apk_file_and_sync_to_ftp-apk.sh|grep -v grep|wc -l)
[ ${pro} -lt 0 ] && echo "still running" >>  ${log_file}  2>&1 && exit 7

#get apk list file
wget -O ${url_save_file} 'http://192.168.238.160:8080/intf/developer/getApkLog.jsp?minute=120&type=1&siteType=0' >>  ${log_file}  2>&1
#wget -O ${url_save_file} 'http://192.168.238.160:8080/intf/developer/getApkLog.jsp?minute=7200&type=1&siteType=0' >>  ${log_file}  2>&1
#wget -O ${url_save_file} 'http://192.168.238.160:8080/intf/developer/getApkLog.jsp?minute=1000&type=1' >>  ${log_file}  2>&1
#wget -O ${url_save_file} 'http://192.168.238.160:8080/intf/developer/getApkLog.jsp?minute=21600&type=1' >>  ${log_file}  2>&1

grep -q 'apk' ${url_save_file}
if [ $? -eq 0 ]
then
	[ -d "/data1/win/$(date +%Y%m%d)/${remote_dir#/*/}" ] || mkdir -p /data1/win/$(date +%Y%m%d)/${remote_dir#/*/}
	cp -a  ${backup_dir}/pconline${line}  /data1/win/$(date +%Y%m%d)/${remote_dir#/*/}
	cat ${url_save_file}|grep -v "^$"|grep 'apk' |while read line
	do
		echo ${line}
		[ -f "${backup_dir}/pconline${line}" ] && continue
		[ -f "${apk_dir}/${line}" ] && /bin/cp -af ${apk_dir}/${line} ${backup_dir}/pconline${line}
		for i in ${ftp_apk_ip}
		do
			/usr/bin/rsync -avzPu --timeout=10 ${backup_dir}/pconline${line} ${i}::ftp_apk/201010/ >>  ${log_file}  2>&1
			[ $? -ne 0 ] && /usr/bin/rsync -avzPu --timeout=10 ${backup_dir}/pconline${line} ${i}::ftp_apk/201010/ >>  ${log_file}  2>&1
		done
        	echo "curl -I http://192.168.238.160:8080/ftpFileSuccess.do?apk_file_name=$line" >> /data1/sh/apk/log/curl.log
	        curl  http://192.168.238.160:8080/ftpFileSuccess.do?apk_file_name=$line >> /data1/sh/apk/log/curl.log
	done


fi


/usr/bin/find ${apk_dir} -mtime +15 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find ${backup_dir} -mtime +13 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find ${url_save_file} -mtime +15 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find ${log_dir} -mtime +13 -exec rm -f {} \; > /dev/null 2>&1

#清理/data/win目录
/usr/bin/find /data/win/ -mtime +100 -exec rm -rf {} \; > /dev/null 2>&1
