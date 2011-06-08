#!/usr/bin/env bash

file=gentic_region.txt
numseqs=300

seqlength=1000
if [ -n "$1" ]; then
 seqlength=$1
 echo "upstream set to $Upstream" 1>&2
fi

i=0

shuffle $file | while read chrom start end strand; do

 #only get numseqs sequences
 if [ $i -gt $numseqs ]; then break; fi;

 #s----------------------------e#  sequence
 #wxxxxxxxxxxxxxxxxxx----------e#  xxxx is working length
 #          r---------------l   #  r is s+wl, l is r+seqlength
 
 
 len=$(($end-$start));
 
 if [ $len -lt $seqlength ];then continue; fi;

 i=$(($i+1));
 
 workinglen=$(($len-$seqlength));
 if [ $workinglen == 0 ]; then 	
 	position=0;
 else
 	position=$(($RANDOM%$workinglen));
 fi

 #give seq a name (genomic position, direction, start
 echo ">$chrom:$start-${end}_$strand(+$position)"


 start=$(($start+$position))
 end=$(($start+$seqlength))

 if [ $strand == '-' ]; then
   tmp=$start;
   start=$end;
   end=$tmp;

 fi
 
 /home/RNA/PlasmodiumFalciparum/genome/pos2seq.pl chr$chrom:$start-$end

done > ../fas/randomInGene_${seqlength}-$(date +%F-%H-%M).fa
