#!/bin/bash

status=$(zpool status 2> 1.txt && cat 1.txt)
whereisroot="$(lsblk | grep sda1 | awk '{print $7}')"

echo $whereisroot
echo $status

if [[ "$whereisroot" == "/" ]]; then
  whereisroot=1
else
  whereisroot=0
fi

echo $whereisroot

if [[ "$status" == "no pools available" ]]
then
  status=1
else
  status=0
fi

echo $status

sum=$(($whereisroot+$status))

echo $sum

if [ $sum -eq 2 ]; then
  zpool create otus1 mirror /dev/sdb /dev/sdc
  zpool create otus2 mirror /dev/sdd /dev/sde
  zpool create otus3 mirror /dev/sdf /dev/sdg
  zpool create otus4 mirror /dev/sdh /dev/sdi
else
  echo "ZFS exist or incorrect root mount point"
fi
