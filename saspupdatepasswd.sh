#!/bin/bash
#
# 15.12.2014 COMODO
#
SCRIPTDIR=$(cd $(dirname $0) && pwd)
LOGINDIR=logins
FILELIST="filelist.txt"
DBHOSTS="dbhosts.txt"
source ${SCRIPTDIR}/runsql.sh
#
############################################################################################################################
hostisup()
 {
  nc -w 1 -z $1 5432
  if [ $? -eq 0 ]; then
  HOSTUP=0
  else
  HOSTUP=1
  fi
 }
############################################################################################################################
checklogin()
 {
   cd ${SCRIPTDIR}/logins
   for i in $(ls -1)
    do
     MD5=$(md5sum ${i} | awk '{print $1}')
## If filelist not exist write md5&login to filelist .
     if [ ! -f ${SCRIPTDIR}/${FILELIST} ]
      then
        echo ${MD5} ${i} >> ${SCRIPTDIR}/${FILELIST}
     fi
#
      grep -ciq $i ${SCRIPTDIR}/${FILELIST}
      if  [[ $? -eq 0 ]]  ; then
       OLDMD5=$(grep $i ${SCRIPTDIR}/${FILELIST} | awk '{print $1}')
       echo "debug: ${OLDMD5}  == ${MD5}"
       if [[ ! ${OLDMD5}  == ${MD5} ]]
        then
         updatedb
         echo "updating ${i}"
         sed -i '/'$i'/d' ${SCRIPTDIR}/${FILELIST}
         echo ${MD5} ${i} >> ${SCRIPTDIR}/${FILELIST}
       fi
      else
       echo ${MD5} ${i} >> ${SCRIPTDIR}/${FILELIST}
      fi
    done
 }
###################################################################################################################################
updatedb()
 {
    #echo "Updating DB."
    declare -a DBLIST
    declare -a DBH
    DBH=($(awk -F ":" '{print $2}' $DBHOSTS))
    DBLIST=($(psql template1 -h 10.100.93.2 -U postgres -w  -c "\l"|tail -n+4|cut -d'|' -f 1|sed -e '/^ *$/d'|sed -e '$d' | grep -v template | grep -v postgres))

    for i in "${DBH[@]}"
    do
     HOSTUP=1 ; hostisup $i
     if [ $HOSTUP -eq 0 ]
      then
       echo "Whole DB: $i"
       DBLIST=($(psql template1 -h $i -U postgres -w  -c "\l"|tail -n+4|cut -d'|' -f 1|sed -e '/^ *$/d'|sed -e '$d' | grep -v template | grep -v postgres))
       for j in "${DBLIST[@]}" 
        do
         echo "Host $i , DB:$j"
       done
    # or do whatever with individual element of the array
     fi
    done
 }
#####################################################################################################################################
#checklogin
updatedb
runsql "NEWLOGIN" "NEWPASSWD"
