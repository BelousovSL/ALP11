#!/bin/bash

readonly DEFAULT_RESULT_FILE=/var/log/nginx/access.log 
readonly WORKING_TIME_MILLISECONDS=300000

source_file=$1
result_file=$2

if [[ -z "$source_file" ]]; then
   echo "Отсутствует параметр источник данных"
fi

if [[ -z "$result_file" ]]; then
   result_file=$DEFAULT_RESULT_FILE
fi

echo $source_file
echo $result_file

# Проверяем что результируеший файл есть, если есть удяляем его 
if [ -f $result_file ]; then
    echo 'Удаляем результируюший файл'
    rm $result_file
fi

# Рассчитываем среднее время срабатывания 
current_count_line=`cat $source_file | wc -l`
average_delay_time_add_log=$( expr $WORKING_TIME_MILLISECONDS / $current_count_line )

while read p; do  
  deviation=$((RANDOM%(601)-300))
  sleep_millisecond=$( expr $average_delay_time_add_log + $deviation )
  sleep_second=$(bc<<<"scale=2;$sleep_millisecond/1000")
  sleep $sleep_second   
  echo "$p" >> $result_file
done <$source_file
