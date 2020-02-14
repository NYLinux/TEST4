#!/bin/bash
get_at()
{
rhead=`onstat -g ras | grep -i rhead | awk '{print $2}'`
autotune_t=`onstat -g dmp 0x0000000044089800 rhead_t | grep autotune | awk '{print $4}'`
echo $rhead
echo $autotune_t
}

i=0
while true
do
if [  -z  "${autotune_t}" ] ; then
	get_at
fi

if [  "${autotune_t}" == "0x0" ] ; then
	get_at
fi

onstat -g dmp ${autotune_t}  autotune_t | grep "ready_cnt\[" | awk  '{sum=$4+$5+$6+$7+$8+$9} {print $4,$5,$6,$7,$8,$9, "=", sum} {allsum+=sum} END {print "Total ready = ", allsum}'; 
i=`expr $i + 1`
onstat -g dmp ${autotune_t}  autotune_t | grep ready_cnt_pos
rdy_cnt=`onstat -g dmp ${autotune_t}  autotune_t | grep ready_cnt_pos | awk '{print $4}'`
if [ ${rdy_cnt} -eq 0 ]
then
	get_at
fi

sleep 1
if [ $i -gt 200 ]
then
	exit
fi
done
