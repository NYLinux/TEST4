#!/bin/ksh
alias onst='onstat -S 0'
TMPRINTOFFSETS=1

if [ -z "$INFORMIXDIR" ]
then
        echo "INFORMIXDIR not set"
        exit
fi

now=`date +%Y%m%d-%H%M`
echo "$now"

echo $1
rstcb=`onst -u |tee onstat.u |  grep "$1 " | cut -d" " -f1`
echo "rstcb = $rstcb"
scb=`onst -g dmp 0x$rstcb rstcb_t |tee rstcb.$1.t |grep scb | awk '{print $4}'`
echo "scb = $scb"
sqtcb=`onst -g dmp $scb scb_t |tee scb.$1.t |grep sqtcblist | awk '{print $4}'`
echo "sqtcb=$sqtcb"
sdb=`onst -g dmp $sqtcb sqtcb_t |tee sqtcb.$1.t |grep "sdb " | awk '{print $4}'`
echo "sdb=$sdb"
sd_cblist=`onst -g dmp $sdb sdb_t |tee sdb.$1.t | grep sd_cblist | awk '{print $4}'`
echo "sd_cblist=$sd_cblist"
echo "+---------------------"
i=0
for cbl_cb in `onst -g dmp $sd_cblist 'cblist,LL(cbl_next)' | grep cbl_cb | awk '{print $4}`
do
i=`expr $i + 1`
echo "conblock $i = $cbl_cb"
onst -g dmp $cbl_cb conblock > conblock.$i.$cbl_cb
extree=`grep extree conblock.$i.$cbl_cb | awk '{print $4}'`
echo "extree=$extree"
#onst -g dmp $extree extree > conblock.$cbl_cb.extree.$extree.$i
onst -g dmp $extree extree > conblock.$i.extree
extype=`grep "0000" conblock.$i.extree | awk '{print $4}'`
echo "extype=$extype"
if [ $extype -eq 16 ]; then
        exscan=`grep ex_scan conblock.$i.extree | awk '{print $4}'`
        echo "exscan $i=$exscan"
        onst -g dmp $exscan exscan > conblock.$i.extree.exscan
        nd_file=`grep nd_file conblock.$i.extree.exscan | awk '{print $4}'`
        echo "nd_file $i = $nd_file"
        onst -g dmp $nd_file tabdesc > conblock.$i.extree.exscan.tabdesc
        td_ddinfo=`grep td_ddinfo conblock.$i.extree.exscan.tabdesc | awk '{print $4}'` 
        echo "td_ddinfo $i = $td_ddinfo"
        onst -g dmp $td_ddinfo ddtabdesc > conblock.$i.extree.exscan.tabdesc.ddtabdesc
        echo "TABLE for conblock $i"
        grep "fn_" conblock.$i.extree.exscan.tabdesc.ddtabdesc
        nd_range=`grep nd_range conblock.$i.extree.exscan | awk '{print $4}'`
        echo "nd_range $i = $nd_range"
    if [ "$nd_range" != "0x0" ]; then
        onst -g dmp $nd_range rangeel > conblock.$i.extree.exscan.rangeel
        rg_index=`grep rg_index conblock.$i.extree.exscan.rangeel | awk '{print $4}'`   
        rg_ddinfo=`grep rg_ddinfo conblock.$i.extree.exscan.rangeel | awk '{print $4}'` 
        rg_ddidxinfo=`grep rg_idxinfo conblock.$i.extree.exscan.rangeel | awk '{print $4}'`     
        echo "rg_index $i = $rg_index"
        onst -g dmp $rg_index keydesc2_t > conblock.$i.extree.exscan.rangeel.keydesc2_t
        echo "rg_ddinfo $i = $rg_ddinfo"
        onst -g dmp $rg_ddinfo ddidxlist > conblock.$i.extree.exscan.rangeel.ddidxlist
        echo "rg_index $i = $rg_index"
        onst -g dmp $rg_index idxlist > conblock.$i.extree.exscan.rangeel.idxlist
        egrep name conblock.$i.extree.exscan.rangeel.*
     else
        echo "Sequential Scan"
     fi
else
        if [ $extype -eq 1 ]; then 
                exjoin=`grep ex_join conblock.$i.extree | awk '{print $4}'`
                echo "exjoin $i=$exjoin"
                onst -g dmp $exjoin exjoin > conblock.$i.extree.exjoin
                nd_file=`grep nd_file conblock.$i.extree.exjoin | awk '{print $4}'`
                echo "nd_file $i = $nd_file"
                onst -g dmp $nd_file tabdesc > conblock.$i.extree.exjoin.tabdesc
                td_ddinfo=`grep td_ddinfo conblock.$i.extree.exjoin.tabdesc | awk '{print $4}'` 
                echo "td_ddinfo $i = $td_ddinfo"
                onst -g dmp $td_ddinfo ddtabdesc > conblock.$i.extree.exjoin.tabdesc.ddtabdesc
                echo "TABLE for extype 16 conblock $i"
                grep "fn_" conblock.$i.extree.exjoin.tabdesc.ddtabdesc
                nd_range=`grep nd_range conblock.$i.extree.exjoin | awk '{print $4}'`
                echo "nd_range $i = $nd_range"
                onst -g dmp $nd_range rangeel > conblock.$i.extree.exjoin.rangeel
                rg_index=`grep rg_index conblock.$i.extree.exjoin.rangeel | awk '{print $4}'`   
                rg_ddinfo=`grep rg_ddinfo conblock.$i.extree.exjoin.rangeel | awk '{print $4}'` 
                rg_ddidxinfo=`grep rg_idxinfo conblock.$i.extree.exjoin.rangeel | awk '{print $4}'`     
                echo "rg_index $i = $rg_index"
                onst -g dmp $rg_index keydesc2_t > conblock.$i.extree.exjoin.rangeel.keydesc2_t
                echo "rg_ddinfo $i = $rg_ddinfo"
                onst -g dmp $rg_ddinfo ddidxlist > conblock.$i.extree.exjoin.rangeel.ddidxlist
                echo "rg_index $i = $rg_index"
                onst -g dmp $rg_index idxlist > conblock.$i.extree.exjoin.rangeel.idxlist
                grep name conblock.$i.extree.exjoin.rangeel.*
                ex_outer=`grep "ex_outer " conblock.$i.extree.exjoin | awk '{print $4}'`
                exi=0
                while [ "$ex_outer" != "0x0" ]
                do
                        echo "ex_outer = $ex_outer"
                        exi=`expr $exi + 1`
                        onst -g dmp $ex_outer extree > conblock.$i.extree.exjoin.ex_outer.$exi
Lextype=`grep "0000" conblock.$i.extree.exjoin.ex_outer.$exi | awk '{print $4}'`
echo "Lextype=$Lextype"
if [ $Lextype -eq 16 ]; then
                  Lexscan=`grep ex_scan conblock.$i.extree.exjoin.ex_outer.$exi | awk '{print $4}'`
                  echo "Lexscan = $Lexscan"
                   onst -g dmp $Lexscan exscan > conblock.$i.extree.exscan.ex_outer.$exi.exscan
            nd_file=`grep nd_file conblock.$i.extree.exscan.ex_outer.$exi.exscan | awk '{print $4}'`
                        onst -g dmp $nd_file tabdesc > conblock.$i.extree.exscan.ex_outer.$exi.exscan.tabdesc
                        td_ddinfo=`grep td_ddinfo conblock.$i.extree.exscan.ex_outer.$exi.exscan.tabdesc | awk '{print $4}'`
                        onst -g dmp $td_ddinfo ddtabdesc > conblock.$i.extree.exscan.ex_outer.$exi.exscan.tabdesc.ddtabdesc
                        echo "TABLE for conblock $i OUTER JOIN"
                        grep "fn_" conblock.$i.extree.exscan.ex_outer.$exi.exscan.tabdesc.ddtabdesc
                        nd_range=`grep nd_range conblock.$i.extree.exscan.ex_outer.$exi.exscan | awk '{print $4}'`
    if [ "$nd_range" != "0x0" ]; then
                        onst -g dmp $nd_range rangeel > conblock.$i.extree.exscan.ex_outer.$exi.exscan.rangeel
                        rg_index=`grep rg_index conblock.$i.extree.exscan.ex_outer.$exi.exscan.rangeel | awk '{print $4}'`
                        rg_ddinfo=`grep rg_ddinfo conblock.$i.extree.exscan.ex_outer.$exi.exscan.rangeel | awk '{print $4}'`
                        rg_ddidxinfo=`grep rg_idxinfo conblock.$i.extree.exscan.ex_outer.$exi.exscan.rangeel | awk '{print $4}'`
                        onst -g dmp $rg_index keydesc2_t > conblock.$i.extree.exscan.ex_outer.$exi.exscan.rangeel.keydesc2_t
                        onst -g dmp $rg_ddinfo ddidxlist > conblock.$i.extree.exscan.ex_outer.$exi.exscan.rangeel.ddidxlist
                        onst -g dmp $rg_index idxlist > conblock.$i.extree.exscan.ex_outer.$exi.exscan.rangeel.idxlist
                        egrep name conblock.$i.extree.exscan.ex_outer.$exi.exscan.rangeel.*
          else
                  echo "DONE FOR THE OUTER"
    fi
                        ex_outer="0x0"
else
                        Lexjoin=`grep ex_join conblock.$i.extree.exjoin.ex_outer.$exi | awk '{print $4}'`
                        onst -g dmp $Lexjoin exjoin > conblock.$i.extree.exjoin.ex_outer.$exi.exjoin
            nd_file=`grep nd_file conblock.$i.extree.exjoin.ex_outer.$exi.exjoin | awk '{print $4}'`
                        onst -g dmp $nd_file tabdesc > conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.tabdesc
                        td_ddinfo=`grep td_ddinfo conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.tabdesc | awk '{print $4}'`
                        onst -g dmp $td_ddinfo ddtabdesc > conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.tabdesc.ddtabdesc
                        echo "TABLE for conblock $i OUTER JOIN"
                        grep "fn_" conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.tabdesc.ddtabdesc
                        nd_range=`grep nd_range conblock.$i.extree.exjoin.ex_outer.$exi.exjoin | awk '{print $4}'`
                        onst -g dmp $nd_range rangeel > conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.rangeel
                        rg_index=`grep rg_index conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.rangeel | awk '{print $4}'`
                        rg_ddinfo=`grep rg_ddinfo conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.rangeel | awk '{print $4}'`
                        rg_ddidxinfo=`grep rg_idxinfo conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.rangeel | awk '{print $4}'`
                        onst -g dmp $rg_index keydesc2_t > conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.rangeel.keydesc2_t
                        onst -g dmp $rg_ddinfo ddidxlist > conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.rangeel.ddidxlist
                        onst -g dmp $rg_index idxlist > conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.rangeel.idxlist
                        egrep name conblock.$i.extree.exjoin.ex_outer.$exi.exjoin.rangeel.*
                        ex_outer=`grep "ex_outer " conblock.$i.extree.exjoin.ex_outer.$exi.exjoin | awk '{print $4}'`
fi #Lextype 
                done
        fi
fi
echo "+---------------------"
done
