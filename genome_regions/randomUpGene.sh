#!/usr/bin/env bash

file=gentic_region.txt
numseqs=300
seqlength=101

while read chrom start end strand; do
 
 

 
 if [ $start -lt $seqlength ];then  echo 'starts too close to beginning' 1>&2; continue; fi;

 #give seq a name (genomic position, direction, start
 echo ">$chrom:$start-${end}($strand)"



 if [ $strand == '+' ]; then
 #    (5')       s--------------e#  sequence
 #|--seqlen-----|                #  taken
     start=$(($start-$seqlength-1))
     end=$(($start+$seqlength))
 else
 #s-------------e  (5')          #  sequence
 #               |e---seqlen---s|#  taken

     end=$(($end+1))
     start=$(($end+$seqlength))

 fi
 
 pos2seq.pl chr$chrom:$start-$end

done < <(shuffle $file|head -n $numseqs)
