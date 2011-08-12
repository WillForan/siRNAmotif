#!/bin/bash

if [ ! -e rnacoding.txt ];then
    echo "ERROR: need rnacoding.txt to exist in this directory"
    exit;
fi
if [ "$1 x" == " x" ] || [ "$1" == "-h" ];then
    echo "extract only one type of RNA coding (regexp) from rnacoding and build 1000nt upstream region for decode"
    echo "USAGE: $0 regexp [check]"
    echo "  e.g. $0 tRNA"
    echo ""
    echo "note1: regex is used in naming the file. Dont use real regexp"
    echo "note2: including a second argument will display matches and prompt to continue"
    exit
fi

if [ "$2 x" != " x" ];then
    echo "====MATCHES==="
    #awk -F"\t" -v name=$1 '(match($5,name)){print}' rnacoding.txt |grep --color=always "$1" | tee >(cat 1>&2) |wc -l
    awk -F"\t" -v name=$1 '(match($5,name)){print; count+=1} END{print "total: " count}' rnacoding.txt |grep --color=always -P "$1|$" 
    echo -e "\n\nProceed? (Ctrl-C: no, enter: yes)"
    read;
fi

mkdir $1;
cd $1;

#586	chr1	218754	219062	RNAse MRP	0	-
awk -F"\t" -v name=$1 '{
      if(!match($5,name)){ next}
      if($7=="+"){
	  print $2":"$3-1000"-"$3-1
      }else{
          print $2":"$4+1000"-"$4+1
      }
    }' ../rnacoding.txt |
 xargs  /home/RNA/PlasmodiumFalciparum/genome/2bit2seq.pl  |
 tee 1000ntUp$1.fa;

RepeatMasker -norna 1000ntUp$1.fa
