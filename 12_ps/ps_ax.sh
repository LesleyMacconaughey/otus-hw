#!/bin/bash

# Получить список всех процессов
processes=$(find /proc/[1-9]* -maxdepth 0 | cut -d '/' -f 3 | sort -n)

# Заголовки столбцов
printf "%-6s %-8s %-8s %-8s %-16s %-16s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"

# Итерация по каждому процессу
for pid in $processes; do
  
  # Получить TTY
  tty=`ls -l /proc/$pid/fd | head -n2 | tail -n1 | sed 's%.*/dev/%%'`
	if [[ $tty == "total 0" ]] || [[ $tty == "null" ]] || [[ $tty == *"socket"* ]]; then
	ttynum="?"
  else
  	ttynum=$tty
  fi

  # Получить информацию о статусе 
  stat=$(cat /proc/$pid/stat | awk '{print $3}')

  # Рассчитываем TIME
  scclktck=`getconf CLK_TCK`
  utime=$(cat /proc/$pid/stat | awk '{print $14}')
  stime=$(cat /proc/$pid/stat | awk '{print $15}')
  ftime=$utime+$stime
  cputime=$((ftime/scclktck))
  time=`date -u -d @${cputime} +"%T"`

  # Получить информацию о команде
  command=$(cat /proc/$pid/cmdline | tr '\0' ' ')

  # Вывести информацию о процессе
  printf "%-6s %-8s %-8s %-8s %-16s %.0f\n" "$pid" "$ttynum" "$stat" "$time" "$command"
done
