#!/bin/bash

###Before running this make sure that you have the scan.lib library installed and jq downloaded. This file will not work without those depndencies.###
###Also, make sure that you create a Tools folder in your Documents folder before cloning. Or you can change the source of the scan.lib file to fit your scan.lib location###

source ~/Documents/Tools/Bug_bounty/./scan.lib

while getopts "m:i" OPTION;do
  case $OPTION in
    m)
      MODE=$OPTARG
      ;;
    i)
      INTERACTIVE=true
      ;;
  esac
done

scan_domain(){
  DOMAIN=$1
  DIRECTORY=${DOMAIN}_recon
  echo "***Creating directory $DIRECTORY"
  mkdir $DIRECTORY
  case $MODE in
    nmap-only)
      nmap_scan
      ;;
    dirsearch-only)
      dirsearch_scan
       ;;
     crt-only)
      crt_scan
      ;;
     *)
      nmap_scan
      dirsearch_scan
      crt_scan
      ;;
  esac
}
report_domain(){
  DOMAIN=$1
  DIRECTORY=${DOMAIN}_recon
  echo "Generating recon report for $DOMAIN..."
 TODAY=$(date)
 if [ -f $DIRECTORY/nmap ];then
  echo "***This scan was create on $TODAY***" > $DIRECTORY/report
    grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report
 fi
 if [ -f $DIRECTORY/dirsearch ];then
  echo "***Results for Dirsearch:" >> $DIRECTORY/report
  cat $DIRECTORY/dirsearch >> $DIRECTORY/report
 fi
 if [ -f $DIRECTORY/crt ];then
  echo "Results for crt.sh:" >> $DIRECTORY/report
  jq -r ".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report
 fi
}
if [ $INTERACTIVE ];then
  INPUT="BLANK"
  while [$INPUT != "quit" ];do
    echo "***Please enter domain!***"
    read INPUT
    if [ $INPUT != "quit" ];then
      scan_domain $INPUT
      report_domain $INPUT
    fi
  done
else
  for i in "${@:$OPTIND:$#}";do
    scan_domain $i
    report_domain $i
    
  done
fi 
