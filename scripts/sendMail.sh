#!/bin/bash

readonly FOLDER_MAILS=/root/mails/

max_number_mail=`ls $FOLDER_MAILS | awk -F ' ' '{print $1}' | awk -F '.' '{print $1}' | sort -k1rn | head -n 1`

if [[ -z "$max_number_mail" ]]; then
   max_number_mail=0
fi

new_number=$(($max_number_mail+1))

IFS=$'\n'
for var in $(cat $1)
do   
   echo "$var" >> "$FOLDER_MAILS$new_number.mail"
done
