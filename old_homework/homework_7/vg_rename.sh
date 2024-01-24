#!/bin/bash

old_name=VolGroup00
new_name=new_vg_name

vgrename -v $old_name $new_name;
sed -i "s/\/${old_name}-/\/${new_name}-/g" /etc/fstab;
sed -i "s/\([/=]\)${old_name}\([-/]\)/\1${new_name}\2/g" /boot/grub2/grub.cfg;
sed -i "s/${old_name}/${new_name}/g" /etc/default/grub;
dracut -f -v /boot/initramfs-$(uname -r).img $(uname -r);
systemctl reboot -f;