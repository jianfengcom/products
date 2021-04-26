#!/bin/bash
# sync_eyp_index.sh
# function: sync eyp_index
# modifid @2012.07.05 by Justice

#rsync -avz root@192.168.239.96::eyp_index

PATH=/var/PROGRAM/MANAGEMENT/modules/xbash:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
LANG=zh_CN
export PATH LANG

LOCAL_INDEX="/data/pg_index/eyp_index"
REMOTE_INDEX="eyp_index"  #rsyncd service ::
CHK_SIZE=10 #MB
BAK=/data/BAK
#RESIN_INIT=/etc/init.d/resind_root_m.pconline
RESIN_INIT=/etc/init.d/resind_pconline-m
PORT=8082
BACKEND=192.168.239.96
USER=root
SMTP=192.168.238.144
SUPPORT="bb@pconline.com.cn,yuanhuoqing@pconline.com.cn,guogongpu@pconline.com.cn,heke@pconline.com.cn,huangshaobiao@pconline.com.cn"
time=$(date +%Y%m%d)
deltime=$(date +%Y%m%d -d "yesterday")

sync_index() {
    ipdrop $PORT down
    $RESIN_INIT stop
    sleep 10
    mkdir -p $BAK/index_${time}
    cd "$LOCAL_INDEX"
    #ls | grep -v cache | xargs -n 1 -i cp -fv {} $BAK/index_${time}/
    mv -fv $LOCAL_INDEX/* $BAK/index_${time}/
    rsync -avz --exclude=".*/" --delete $USER@$BACKEND::$REMOTE_INDEX $LOCAL_INDEX/
    #rsync -avz --delete $USER@$BACKEND::$REMOTE_INDEX $LOCAL_INDEX/
    if [[ $? -ne 0 ]]
    then
            recover_index
    else
            chk_size
            rm -rvf $BAK/index_${deltime}/
    fi
    $RESIN_INIT start
    sleep 62
    ipdrop $PORT off
}

chk_size() {
    #REMOTE_SIZE=$(ssh $USER@$BACKEND du -sm $REMOTE_INDEX/ | awk '{ print $1 }')
    REMOTE_SIZE=$(du -sm $LOCAL_INDEX/ | awk '{ print $1 }')
    if [[ $REMOTE_SIZE -ge $CHK_SIZE ]]; then
        #sync_index
        echo "Normally completed!"
    else
        echo "index check fail,remote size($REMOTE_SIZE)MB smaller than limit($CHK_SIZE)MB" | env MAILRC=/dev/null charset="GB18030" from=support@3conline.com smtp=$SMTP nail -n -s "[WARN]$(hostname -s)($(hostname -i)) said: $BACKEND::$REMOTE_INDEX/ too small!" $SUPPORT
        recover_index
    fi
}

recover_index() {
    rm -rfv $LOCAL_INDEX/*
    /bin/cp -rfv $BAK/index_${time}/* $LOCAL_INDEX/
    echo "index sync fail,recover with backup index" | env MAILRC=/dev/null charset="GB18030" from=support@3conline.com 	smtp=$SMTP nail -n -s "[WARN]$(hostname -s)($(hostname -i)) eyp_index sync error!" $SUPPORT
}

case $1 in
chk)
    chk_size
;;
index)
    sync_index    
    chown -R resin.resin $LOCAL_INDEX
;;
*)
    echo "Usage: $0 [index]"
    echo "index  --- sync index only and restart resin"
    exit 0
;;
esac
