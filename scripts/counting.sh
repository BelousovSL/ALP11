#!/bin/bash

readonly DEFAULT_SOURCE_FILE=/var/log/nginx/access.log 
readonly STATE_FILE=/root/scripts/state
readonly BUFFER_FILE=/tmp/werwer3re.txt
readonly FILE_RESULT=/tmp/wqdqdawewe.txt

source_file=$1

if [[ -z "$source_file" ]]; then
   source_file=$DEFAULT_SOURCE_FILE
fi

if [[ -f "$STATE_FILE" ]]; then
   status_work=`head $STATE_FILE -n 1`
   hash_first_line=`tail $STATE_FILE -n 1`
else
   status_work=wait
   hash_first_line=`echo $(head $source_file -n 1) | md5sum`
fi

if [ "$status_work" == "work" ]; then
   exit
fi

echo -e "work\n$hash_first_line" > $STATE_FILE

last_line=`tail $source_file -n 1`
hash_last_line=`echo $last_line | md5sum`

current_line=0
line_begin=0
line_end=0

while read p; do  
    current_line=$((current_line+1))
    hash_current_line=`echo $p | md5sum`
    
    if [ "$hash_current_line" == "$hash_first_line" ]; then
        time_start_for_log=`echo $p | awk -F '[' '{print $2}' | awk -F ']' '{print $1}'`
        line_begin=$(($current_line+1))  
        continue
    fi

    if [ "$hash_current_line" == "$hash_last_line" ]; then
        time_end_for_log=`echo $p | awk -F '[' '{print $2}' | awk -F ']' '{print $1}'`
        line_end=$current_line
        break
    fi
done <$source_file

sed -n "$line_begin,$line_end p" $source_file > $BUFFER_FILE
IFS=$'\n'

echo "Начало временного отрезка: $time_start_for_log" > $FILE_RESULT
echo "Hash первой строки временного отрезка: $hash_first_line" >> $FILE_RESULT
echo "" >> $FILE_RESULT

echo "Окончание временного отрезка: $time_end_for_log" >> $FILE_RESULT
echo "Hash последней строки временного отрезка: $hash_last_line" >> $FILE_RESULT

echo "" >> $FILE_RESULT
echo 'Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта:' >> $FILE_RESULT
for var in $(grep -o '^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' $BUFFER_FILE | uniq -c | sort -k1rn | awk '{$1=$1;print}' | head -n 10)
do
   echo $var >> $FILE_RESULT
done

echo '' >> $FILE_RESULT
echo 'Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта:' >> $FILE_RESULT
for var in $(awk -F '"' '{print $2}' $BUFFER_FILE | awk -F ' ' '{print $2}' | sed '/^[[:space:]]*$/d' | sort | uniq -c | sort -k1rn | awk '{$1=$1;print}' | head -n 10)
do
   echo $var >> $FILE_RESULT
done

echo '' >> $FILE_RESULT
echo 'Ошибки веб-сервера/приложения c момента последнего запуска:' >> $FILE_RESULT
for var in $(awk -F '"' '{print $3}' $BUFFER_FILE | awk -F ' ' '{print $1}' | sed '/^[1-3]/d' | sort | uniq -c | sort -k1rn | awk '{$1=$1;print}' | head -n 10)
do
   echo $var >> $FILE_RESULT
done

echo '' >> $FILE_RESULT
echo 'Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта:' >> $FILE_RESULT
for var in $(awk -F '"' '{print $3}' $BUFFER_FILE | awk -F ' ' '{print $1}' | sort | uniq -c | sort -k1rn | awk '{$1=$1;print}' | head -n 10)
do
   echo $var >> $FILE_RESULT
done

echo -e "wait\n$hash_last_line" > $STATE_FILE
sendmail $FILE_RESULT
