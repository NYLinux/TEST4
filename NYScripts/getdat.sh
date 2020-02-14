#!/bin/bash
>${1}.all
for i in `echo stat*`
do
echo $i
cat $i/onstat.${1} >> ${1}.all
done
