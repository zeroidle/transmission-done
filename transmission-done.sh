#!/bin/sh
SERVER="9091 -n [ID]:[PWD]"
KEY="[TELEGRAM_BOT_API_TOKEN]"
CHATID="[CHAT_ROOM_ID]"
DIR=$(echo $TR_TORRENT_DIR|cut -d'/' -f 3)

if [ $DIR == "Media" ]
then
  STR="($(echo $TR_TORRENT_DIR|cut -d'/' -f 4-))"
fi

TEXT="$TR_TORRENT_NAME $STR is ready."

TORRENTLIST=`transmission-remote $SERVER --list | sed -e '1d;$d;s/^ *//' | awk '{print $1}'`
for TORRENTID in $TORRENTLIST
do
    DL_COMPLETED=`transmission-remote $SERVER --torrent $TORRENTID --info | grep "Percent Done: 100%"`
    STATE_STOPPED=`transmission-remote $SERVER --torrent $TORRENTID --info | grep "State: Seeding\|Stopped\|Finished\|Idle"`
    if [ "$DL_COMPLETED" ] && [ "$STATE_STOPPED" ]; then
        transmission-remote $SERVER --torrent $TORRENTID --remove
    fi
done 
/usr/local/bin/curl -d "chat_id=$CHATID&text=$TEXT" https://api.telegram.org/bot$KEY/sendMessage
