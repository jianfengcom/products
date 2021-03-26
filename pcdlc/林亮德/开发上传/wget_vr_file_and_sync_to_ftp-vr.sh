#!/bin/bash
#
# */10 * * * * 


dir=/data/sh/vr
url_save_dir=${dir}/vr_file
url_save_file=${url_save_dir}/vr_file_$(date "+%F_%H-%M")
vr_dir=/data1/devupload/web/vrdownload
backup_dir=${dir}/backup_vr
remote_dir=/data/ftp-vr.pconline.com.cn/pub/download/201010
#ftp_apk_ip="192.168.168.43 192.168.168.44 192.168.168.45 192.168.229.146 192.168.229.148 192.168.10.105"
ftp_vr_ip="192.168.229.146 192.168.229.148 192.168.230.172 192.168.231.57"
log_dir=${dir}/log
log_file=${log_dir}/$(date "+%F_%H-%M").log

[ ! -d ${backup_dir} ] && mkdir -p ${backup_dir}
[ ! -d ${log_dir} ] && mkdir -p ${log_dir}

[ -f ${url_save_file} ] && /bin/rm -rf ${url_save_file}

pro=$(ps axu|grep wget_vr_file_and_sync_to_ftp-vr.sh|grep -v grep|wc -l)
[ ${pro} -lt 0 ] && echo "still running" >>  ${log_file}  2>&1 && exit 7

#get apk list file
#wget -O ${url_save_file} 'http://192.168.238.160:8080/intf/developer/getApkLog.jsp?minute=60&type=1' >>  ${log_file}  2>&1
wget -O ${url_save_file} 'http://192.168.238.160:8080/intf/vrdownload/getVRLog.jsp?minute=120&type=1' >>  ${log_file}  2>&1


count=$(cat ${url_save_file}|wc -l)
if [ "${count}" -gt 0 ]
then
	cat ${url_save_file}|grep -v "^$" |while read line
	do
		[ -f "${backup_dir}/pconline${line}" ] && continue
		#/bin/cp -af ${vr_dir}/${line} ${backup_dir}/pconline${line}
		[ -f "${vr_dir}/${line}" ] && /bin/cp -f ${vr_dir}/${line} ${backup_dir}/pconline${line}
		for i in ${ftp_vr_ip}
		do
			/usr/bin/rsync -avzPu --timeout=10 ${backup_dir}/pconline${line} ${i}::ftp-vr/201010/ >>  ${log_file}  2>&1
			[ $? -ne 0 ] && /usr/bin/rsync -avzPu --timeout=10 ${backup_dir}/pconline${line} ${i}::ftp-vr/201010/ >>  ${log_file}  2>&1

		done
                        echo "curl -I http://192.168.238.160:8080/ftpFileSuccess.do?apk_file_name=$line" >> /data1/sh/apk/log/curl.log
                        curl  http://192.168.238.160:8080/ftpFileSuccess.do?apk_file_name=$line >> /data1/sh/apk/log/curl.log

	done


fi


#/usr/bin/find ${vr_dir} -mtime +5 -exec rm -f {} \; > /dev/null 2>&1
#/usr/bin/find ${backup_dir} -mtime +2 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find ${backup_dir} -mmin +150 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find ${log_dir} -mtime +3 -exec rm -f {} \; > /dev/null 2>&1
/usr/bin/find ${url_save_file} -mtime +7 -exec rm -f {} \; > /dev/null 2>&1
