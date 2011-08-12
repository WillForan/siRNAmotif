#!/usr/bin/env bash

#length of sequence jellyfish should count
if [ "$KMER" == "" ]; then
    KMER=6;
fi

jellyout='/home/wforan1/seq/srna/lab/motif/tools/jellyfish/jellyout/masked/'
maskdir=/home/wforan1/seq/srna/lab/motif/fas/masked/
fasdir=/home/wforan1/seq/srna/lab/motif/fas/

#get all not yet masked fas
#   ie. get all files not in maskdir but in fa dir
comm -23\
	<(ls -b ${fasdir}*fa|sort |xargs -I{} basename {}) \
	<(ls -b ${maskdir}*masked |sort|xargs -I{} basename {} .masked) |
while read file; do
     RepeatMasker -dir $maskdir -norna $fasdir$file
     echo "unmasked file: $file, masked" 1>&2;
done


#count any new files (or any new Kmer)
ls -b ${maskdir}*masked | while read file; do
    NAME=$(basename $file .fa.masked)-$KMER
    if [ ! -f $jellyout${NAME}_0 ]; then
	jellyfish count $file -m $KMER -o $jellyout$NAME -c 3 -s 10000000
	echo "uncounted file: $file, counted" 1>&2;
    fi
done

echo " Run with KMER=?; and run tools/jellyfish/mkPWM.pl with -b and -f set"
