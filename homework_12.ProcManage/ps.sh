#!/usr/bin/env bash

printf "%6s %-6s %-6s %-6s %-6s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"

system_clk=$(getconf CLK_TCK)

for procdir in /proc/[0-9]*
do
  pid=${procdir#/proc/}
  if [ -d "$procdir/fd" ]
  then
    tty="?"
    for fd in "$procdir"/fd/*
    do
      realtty=$(readlink "$fd")
      case "$realtty" in 
        /dev/tty*|/dev/pts/*)
          tty=${realtty#/dev/}
          break ;;
      esac
    done
  fi
  stat=$(cut -d' ' -f3 $procdir/stat)
  starttime=$(awk '{print $22}' $procdir/stat) 
  starttime_in_seconds=$(echo "scale=2; $starttime / $system_clk" | bc) 
  systemtime=$(cut -d' ' -f1 /proc/uptime) 
  proctime=$(echo "scale=2; $systemtime - $starttime_in_seconds" | bc) 
  time=$(echo "scale=2; $proctime / 3600" | bc)
  if [ ! -s "$procdir/cmdline" -o ! -r "$procdir/cmdline" ]; then
    command=$(awk '{print $2}' $procdir/stat)
  else
    command=$(tr '\0' ' ' < $procdir/cmdline)
  fi
  printf "%6s %-6s %-6s %-6s %s\n" "$pid" "$tty" "$stat" "$time" "$command"
done | sort -t' ' -k 1n
