rhaddr=`onstat -g ras | grep -i rhead | awk '{print $2}'`
onstat -g dmp $rhaddr rhead_t 
