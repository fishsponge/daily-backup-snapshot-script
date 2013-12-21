#!/bin/bash

# Daily, Weekly, Monthly & Yearly Snapshots
# Version 1.3 - echo comments modified, start date added to beginning, added overlap time being echo'd and comments being echo'd describing snapshots being deleted, moved and created.
# Version 1.2 - "processIsRunning" file created when running and while loop created so script doesn't overlap.
# Version 1.1 - rsync protocol added.
# Version 1.0 - Original.
# Written by Richard Hobbs
# http://www.rhobbs.co.uk/

echo -n "Start: "; date

overlap_start_time=`date +%s`

while [ 1 ]
do
    if [ -f "/root/scripts/makeSnapshots/processIsRunning" ]
    then
        echo "Another \"makeSnapshot\" process is currently running (`date`) so waiting for it to finish..."; sleep 257
    else
        echo "makeSnapshot has finished (or is not running), so starting the process..."; break
    fi
done

overlap_end_time=`date +%s`
overlap_hours=`echo $(( (($overlap_end_time - $overlap_start_time) / 60) / 60 ))`
overlap_minutes=`echo $(( (($overlap_end_time - $overlap_start_time) / 60) - ($overlap_hours * 60) ))`
overlap_seconds=`echo $(( ($overlap_end_time - $overlap_start_time) - ($overlap_minutes * 60) - ($overlap_hours * 60 * 60) ))`
echo "Overlap took $overlap_hours hours, $overlap_minutes minutes, $overlap_seconds seconds."

echo -n "Snapshot creation starts: "; date

touch /root/scripts/makeSnapshots/processIsRunning

################################
# CUSTOMIZABLE VARIABLES BELOW #
################################

# The directory in which snapshots are stored
# NOTE: This will contain 1 complete copy of
# the original data at *least*.
snapdir="/snapshots"
rsyncsnapdir="snapshots"

# Source directories to put into the snapshots
# NOTE: Do *NOT* include the snapshot directory.
dirs[0]='/root/'
dirs[1]='/etc/'
dirs[2]='/home/'

# NOTE: If you reduce the maximum number of snapshots
# you may have to delete the higher numbered snapshots
# yourself.

# Maximum number of daily snapshots
maxdaily=7

# Maximum number of weekly snapshots
maxweekly=5

# Maximum number of monthly snapshots
maxmonthly=12

# Maximum number of yearly snapshots
maxyearly=10

# Day of week to run weekly, monthly & yearly snapshots
# 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat, 7=Sun
# NOTE: All weekly, monthly & yearly snapshots
# will be based on the day before.
daytorun=2



################################
# DO NOT EDIT BELOW THIS LINE  #
################################

if [ ! -d ${snapdir} ]; then echo "${snapdir} doesn't exist.\nPlease check \"\$snapdir=\" in the script or run \"mkdir ${snapdir}\"" >&2; exit 1; fi

if [ `date +%u` == "${daytorun}" ]; then doweekly="yes"; fi
if [ `date +%u` == "${daytorun}" ]; then if [ `date +%d` -le "7" ]; then domonthly="yes"; fi; fi
if [ `date +%u` == "${daytorun}" ]; then if [ `date +%j` -le "7" ]; then doyearly="yes"; fi; fi

if [ ! -d ${snapdir}/daily.0 ]; then echo "\"${snapdir}/daily.0/\" directory doesn't exist, so creating it now."; mkdir ${snapdir}/daily.0 || exit 1; fi

# DAILY

minus1=`expr ${maxdaily} - 1`
if [ -d ${snapdir}/daily.${minus1} ]; then echo "Removing \"daily.${minus1}\"..."; rm -rf ${snapdir}/daily.${minus1}; echo " done"; fi
for ((ss=${minus1}; ss >= 2; ss--))
do
  ssminus1=`expr ${ss} - 1`
  if [ -d ${snapdir}/daily.${ssminus1} ]; then echo "Moving \"daily.${ssminus1}\" to \"daily.${ss}\"..."; mv ${snapdir}/daily.${ssminus1} ${snapdir}/daily.${ss}; echo " done"; fi
done
if [ -d ${snapdir}/daily.0 ]; then echo "Synchronizing \"daily.0\" with \"daily.1\"..."; cp -al ${snapdir}/daily.0 ${snapdir}/daily.1; echo " done"; fi

# WEEKLY

if [ "${doweekly}" == "yes" ]
then

  minus1=`expr ${maxweekly} - 1`
  if [ -d ${snapdir}/weekly.${minus1} ]; then echo "Removing \"weekly.${minus1}\"..."; rm -rf ${snapdir}/weekly.${minus1}; echo " done"; fi
  for ((ss=${minus1}; ss >= 1; ss--))
  do
    ssminus1=`expr ${ss} - 1`
    if [ -d ${snapdir}/weekly.${ssminus1} ]; then echo "Moving \"weekly.${ssminus1}\" to \"weekly.${ss}\"..."; mv ${snapdir}/weekly.${ssminus1} ${snapdir}/weekly.${ss}; echo " done"; fi
  done
  if [ -d ${snapdir}/daily.0 ]; then echo "Synchronizing \"daily.0\" with \"weekly.0\"..."; cp -al ${snapdir}/daily.0 ${snapdir}/weekly.0; echo " done"; fi

fi

# MONTHLY

if [ "${domonthly}" == "yes" ]
then

  minus1=`expr ${maxmonthly} - 1`
  if [ -d ${snapdir}/monthly.${minus1} ]; then echo "Removing \"monthly.${minus1}\"..."; rm -rf ${snapdir}/monthly.${minus1}; echo " done"; fi
  for ((ss=${minus1}; ss >= 1; ss--))
  do
    ssminus1=`expr ${ss} - 1`
    if [ -d ${snapdir}/monthly.${ssminus1} ]; then echo "Moving \"monthly.${ssminus1}\" to \"monthly.${ss}\"..."; mv ${snapdir}/monthly.${ssminus1} ${snapdir}/monthly.${ss}; echo " done"; fi
  done
  if [ -d ${snapdir}/daily.0 ]; then echo "Synchronizing \"daily.0\" with \"monthly.0\"..."; cp -al ${snapdir}/daily.0 ${snapdir}/monthly.0; echo " done"; fi

fi

# YEARLY

if [ "${doyearly}" == "yes" ]
then

  minus1=`expr ${maxyearly} - 1`
  if [ -d ${snapdir}/yearly.${minus1} ]; then echo "Removing \"yearly.${minus1}\"..."; rm -rf ${snapdir}/yearly.${minus1}; echo " done"; fi
  for ((ss=${minus1}; ss >= 1; ss--))
  do
    ssminus1=`expr ${ss} - 1`
    if [ -d ${snapdir}/yearly.${ssminus1} ]; then echo "Moving \"yearly.${ssminus1}\" to \"yearly.${ss}\"..."; mv ${snapdir}/yearly.${ssminus1} ${snapdir}/yearly.${ss}; echo " done"; fi
  done
  if [ -d ${snapdir}/daily.0 ]; then echo "Synchronizing \"daily.0\" with \"yearly.0\"..."; cp -al ${snapdir}/daily.0 ${snapdir}/yearly.0; echo " done"; fi

fi

# LIVE DATA

for dir in "${dirs[@]}"
do
  echo "Rsyncing \"${dir}\"..."
  #rsync -avS --delete ${dir}/ ${snapdir}/daily.0/${dir}/
  #rsync -avSc --delete --password-file=/root/password ${dir}/ username@nas::${rsyncsnapdir}/daily.0/${dir}/
  rsync -avS --delete --password-file=/root/password ${dir}/ username@nas::${rsyncsnapdir}/daily.0/${dir}/
done

touch ${snapdir}/daily.0

rm /root/scripts/makeSnapshots/processIsRunning

echo -n "End: "; date

