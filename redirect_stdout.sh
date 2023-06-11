#!/bin/bash
#
#this script demonstrates I/O redirection.
#
#redirect STDOUT to a file.
FILE="/tmp/data"

head -n1 /etc/passwd > ${FILE}

#redirect STDIN to a program
#
read LINE < ${FILE}
echo "LINE contains: ${LINE}"

#redirect STDOUT to a file. overwriting the file.
head -n3 /etc/passwd > ${FILE}
echo
echo "Contents of ${FILE}:"
cat ${FILE}

# redirect STDOUT to a file, appending to the file.
echo "${RANDOM} ${RANDOM}" >> ${FILE}
echo "${RANDOM} ${RANDOM}" >> ${FILE}
echo
echo "Contents of ${FILE}:"
cat ${FILE}
