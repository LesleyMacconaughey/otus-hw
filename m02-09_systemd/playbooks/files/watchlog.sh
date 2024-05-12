#!/bin/bash

#WORD=$1
WORD="ALERT"
#LOG=$2
LOG=/var/log/watchlog.log
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi