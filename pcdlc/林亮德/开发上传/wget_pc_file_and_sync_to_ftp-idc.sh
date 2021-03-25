#!/bin/bash
#
# */10 * * * * 


dir=/data/sh/pc
url_save_dir=${dir}/pc_file
url_save_file=${url_save_dir}/pc_file_$(date "+%F_%H-%M")
pc_dir=/data1/devupload/web/pcdownload
backup_dir=${dir}/backup_pc
remote_dir=/data/ftp.pconline.com.cn/pub/download/201010
#ftp_apk_ip="192.168.168.43 192.168.168.44 192.168.168.45 192.168.229.146 192.168.229.148 192.168.10.105"
#ftp_ip="192.168.229.138 192.168.229.147 192.168.229.149 192.168.231.56 192.168.230.210"
ftp_ip="192.168.231.56 192.168.230.210"
log_dir=${dir}/log
log_file=${log_dir}/$(date "+%F_%H-%M").log

[ ! -d ${backup_dir} ] && mkdir -p ${backup_dir}
[ ! -d ${url_save_dir} ] && mkdir -p ${url_save_dir}
[ ! -d ${log_dir} ] && mkdir -p ${log_dir}

[ -f ${url_save_file} ] && /bin/rm -rf ${url_save_file}

pro=$(ps axu|grep wget_pc_file_and_sync_to_ftp-idc.sh|grep -v grep|wc -l)
[ ${pro} -lt 0 ] && echo "still running" >>  ${log_file}  2>&1 && exit 7

#get apk list file
#wget -O ${url_save_file} 'http://192.168.238.160:8080/intf/developer/getApkLog.jsp?minute=60&type=1' >>  ${log_file}  2>&1
wget -O ${url_save_file} 'http://192.168.238.160:8080/intf/vrdownload/getVRLog.jsp?minute=120&type=1' >>  ${log_file}  2>&1


count=$(cat ${url_save_file}|wc -l)
if [ "${count}" -gt 0 ]
then
	cat ${url_save_file}|grep -v "^$" |while read line
	do
		[ -d "/data/win/$(date +%Y%m%d)/${remote_dir#/*/}" ] || mkdir -p /data/win/$(date +%Y%m%d)/${remote_dir#/*/}
		cp -a ${backup_dir}/pconline${line} /data/win/$(date +%Y%m%d)/${remote_dir#/*/}
		[ -f "${backup_dir}/pconline${line}" ] && continue
		#/bin/cp -af ${pc_dir}/${line} ${backup_dir}/pconline${line}
		[ -f "${pc_dir}/${line}" ] && /bin/cp -f ${pc_dir}/${line} ${backup_dir}/pconline${line}
		for i in ${ftp_ip}
		do
			/usr/bin/rsync -avzPu --timeout=10 ${backup_dir}/pconline${line} ${i}::sync_idc/201010/ >>  ${log_file}  2>&1
			[ $? -ne 0 ] && /usr/bin/rsync -avzPu --timeout=10 ${backup_dir}/pconline${line} ${i}::sync_idc/201010/ >>  ${log_file}  2>&1

		done
                        echo "curl -I http://192.168.238.160:8080/ftpFileSuccess.do?apk_file_name=$line" >> /data1/sh/apk/log/curl.log
                        curl  http://192.168.238.160:8080/ftpFileSuccess.do?apk_file_name=$line >> /data1/sh/apk/log/curl.log

	done


fi


/usr/bin/find ${pc_dir} -mtime +14 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find ${backup_dir} -mtime +1 -exec rm -f {} \; > /dev/null 2>&1
#/usr/bin/find ${backup_dir} -mmin +150 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find ${log_dir} -mtime +3 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find ${url_save_file} -mtime +7 -exec rm -f {} \; > /dev/null 2>&1
