#!/bin/sh
LANG=zh_CN.GB18030
JAVA_HOME=/usr/java/jdk1.8.0_151
ANT_HOME=/data/PRG/apache-ant-1.9.4
PUBLISH_HOME=/data/web/pconline-dl-new-spider/WEB-INF/classes
SPIDER_SH_LOG=/data/LOG/spider_sh_log
TASK_NAME=itunesSpider

CUR_DATE="`date +%Y-%m-%d`"

PROCESS_RUN=`ps aux|grep build.xml |grep $TASK_NAME|grep -v grep|wc -l`
echo "$PROCESS_RUN"
if [ "${PROCESS_RUN}" != "0" ]
then
	echo 'process running'
	exit 1
else
	
	export JAVA_HOME ANT_HOME LANG

	[[ -f $SPIDER_SH_LOG/$TASK_NAME.log ]] && mv -vf $SPIDER_SH_LOG/$TASK_NAME.log $SPIDER_SH_LOG/$TASK_NAME.log.1
	
	echo "$(date +%F\ %T) start $0"
	$ANT_HOME/bin/ant -buildfile $PUBLISH_HOME/build.xml $TASK_NAME >> $SPIDER_SH_LOG/$TASK_NAME.log  2>&1
	echo "$(date +%F\ %T) finish $0"
	
fi