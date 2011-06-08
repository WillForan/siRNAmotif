#!/usr/bin/env bash

file=gentic_region.txt
numseqs=300
seqlength=1000

i=0;

shuffle $file | while read chrom start end strand; do

    #if we've done more then enough end
    if [ $i -gt $numseqs ]; then break; fi

    #can't get 1000 upstream of this 
    if [ $start -lt $seqlength ];then  echo 'starts too close to beginning' 1>&2; continue; fi;

    #count it
    i=$(($i+1));


    #give seq a name (genomic position, direction, start
    echo ">chr$chrom:$start-${end}($strand)"



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

done 
