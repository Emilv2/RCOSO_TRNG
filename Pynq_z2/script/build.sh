#!/bin/bash

while [ $# -gt 0 ]; do
  if [[ $1 == *"--"* ]]; then
    param="${1/--/}"
    declare "$param"="$2"
  fi

  shift
done

if [ -z "$xsct" ]; then
  echo "xsct binary not set!"
  exit 1
fi
if [ -z "$app_name" ]; then
  echo "app name not set!"
  exit 1
fi
if [ -z "$hw_file" ]; then
  echo "hw file not set!"
  exit 1
fi
if [ -z "$elf_file" ]; then
  echo "elf file not set!"
  exit 1
fi

# https://bugs.eclipse.org/bugs/show_bug.cgi?id=393594#c1
#rm -fr .metadata/.plugins/org.eclipse.cdt.core/*.pdom

#https://forums.xilinx.com/t5/Vitis-Acceleration-SDAccel-SDSoC/Vitis-won-t-start/td-p/1067654
#rm -rf .metadata
#rm -rf IDE.log
#rm -rf .analytics
#rm -rf RemoteSystemsTempFiles

rm -f $elf_file
# sometimes the build fails, not sure why
# try 3 times
cnt=0
while [ ! -f "$elf_file" ]; do
  if [ $cnt -eq 3 ]; then
    exit 1
  fi
  $xsct build.tcl \
    -app_name "$app_name" -hw_file "$hw_file"
  cnt=$((cnt+1))
done
