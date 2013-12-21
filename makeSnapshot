#!/bin/bash

# Daily, Weekly, Monthly & Yearly Snapshots
# Version 1.0
# Written by Richard Hobbs
# http://www.rhobbs.co.uk/

echo -n "Start: "; date

################################
# CUSTOMIZABLE VARIABLES BELOW #
################################

# The directory in which snapshots are stored
# NOTE: This will contain 1 complete copy of
# the original data at *least*.
snapdir="/snapshots"

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
if [ -d ${snapdir}/daily.${minus1} ]; then rm -rf ${snapdir}/daily.${minus1}; fi
for ((ss=${minus1}; ss >= 2; ss--))
do
  ssminus1=`expr ${ss} - 1`
  if [ -d ${snapdir}/daily.${ssminus1} ]; then mv ${snapdir}/daily.${ssminus1} ${snapdir}/daily.${ss}; fi
done
if [ -d ${snapdir}/daily.0 ]; then cp -al ${snapdir}/daily.0 ${snapdir}/daily.1; fi

# WEEKLY

if [ "${doweekly}" == "yes" ]
then

  minus1=`expr ${maxweekly} - 1`
  if [ -d ${snapdir}/weekly.${minus1} ]; then rm -rf ${snapdir}/weekly.${minus1}; fi
  for ((ss=${minus1}; ss >= 1; ss--))
  do
    ssminus1=`expr ${ss} - 1`
    if [ -d ${snapdir}/weekly.${ssminus1} ]; then mv ${snapdir}/weekly.${ssminus1} ${snapdir}/weekly.${ss}; fi
  done
  if [ -d ${snapdir}/daily.0 ]; then cp -al ${snapdir}/daily.0 ${snapdir}/weekly.0; fi

fi

# MONTHLY

if [ "${domonthly}" == "yes" ]
then

  minus1=`expr ${maxmonthly} - 1`
  if [ -d ${snapdir}/monthly.${minus1} ]; then rm -rf ${snapdir}/monthly.${minus1}; fi
  for ((ss=${minus1}; ss >= 1; ss--))
  do
    ssminus1=`expr ${ss} - 1`
    if [ -d ${snapdir}/monthly.${ssminus1} ]; then mv ${snapdir}/monthly.${ssminus1} ${snapdir}/monthly.${ss}; fi
  done
  if [ -d ${snapdir}/daily.0 ]; then cp -al ${snapdir}/daily.0 ${snapdir}/monthly.0; fi

fi

# YEARLY

if [ "${doyearly}" == "yes" ]
then

  minus1=`expr ${maxyearly} - 1`
  if [ -d ${snapdir}/yearly.${minus1} ]; then rm -rf ${snapdir}/yearly.${minus1}; fi
  for ((ss=${minus1}; ss >= 1; ss--))
  do
    ssminus1=`expr ${ss} - 1`
    if [ -d ${snapdir}/yearly.${ssminus1} ]; then mv ${snapdir}/yearly.${ssminus1} ${snapdir}/yearly.${ss}; fi
  done
  if [ -d ${snapdir}/daily.0 ]; then cp -al ${snapdir}/daily.0 ${snapdir}/yearly.0; fi

fi

# LIVE DATA

for dir in "${dirs[@]}"
do
  echo "Rsyncing \"${dir}\"..."
  rsync -avS --delete ${dir}/ ${snapdir}/daily.0/${dir}/
done

touch ${snapdir}/daily.0

echo -n "End: "; date

