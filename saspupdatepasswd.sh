#!/bin/bash
#
# 15.12.2014 COMODO
#
SCRIPTDIR=$(cd $(dirname $0) && pwd)
LOGINDIR=logins
FILELIST="filelist.txt"
#
#
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

updatedb()
 {
  echo "Updating DB."
 }

checklogin