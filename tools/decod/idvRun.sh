#!/usr/bin/env bash 

if [ "$(echo -n $2|sed s/[56789]// ) x" != " x" ] ||
   [ "$2 x" == " x" ];then
    echo "Usage: $0 [RUF6,tRNA,snRNA,snoR] [6,7,8,9] [35,29]"
    echo "puts decod output files in output/[6,7,8,9]/[RUF6,snRNA,snoR,tRNA]VsG1000_[29,35].txt"
    echo "3rd argument is optional"
    exit;
fi

foreground="../../genome_regions/$1/1000ntUp$1.fa.masked"
#foreground='../../fas/masked/300_top_1000_noTelomer.fa.masked'
####foreground='300_top_1000_noTelomer.minus3more.fa.masked'
#####foreground= '../../fas/masked/300_top_1000.fa.masked'
background1='../../fas/masked/randomInGene_1000-2011-06-30-13-29.fa.masked'
background2='../../fas/masked/randomInGene_1000-2011-06-30-13-35.fa.masked'

if [ ! -e $foreground ];then
    echo "ERROR: $foreground DNE"
    exit;
fi
if [ ! -e $background1 ] || [ ! -e $background2 ];then
    echo "ERROR: background files do not exist"
    exit;
fi

#pull in runDECOD function
source runDECOD.sh
width=$2;
if [ "$3" == "29" ] || [ "$3 x" == " x" ]; then
runDECOD $foreground \
	$background1 \
	$1VsG1000_29.txt \
	$width 
fi
if [ "$3" == "35" ] || [ "$3 x" == " x"]; then
runDECOD $foreground \
	$background2 \
	$1VsG1000_35.txt \
	$width 
fi

