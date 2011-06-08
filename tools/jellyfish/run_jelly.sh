#!/usr/bin/env bash

# count kmers (default 6) of masked files
# and put in outdir 
#

if [ "$KMER" == "" ]; then
    KMER=6;
fi

outdir='jellyout/masked/'

function runjelly() {
    NAME=$(basename $1 .fa)-$KMER
    if [ ! -f $outdir$NAME ]; then
	jellyfish count $1 -m $KMER -o $outdir$NAME -c 3 -s 10000000
    fi
    echo "=== $NAME ==="
    jellyfish dump $outdir$NAME* | awk '{if(NR%2==1){ printf substr($0,2) }else{print "\t" $0}}'|
    sort -nr | awk '{print NR,"\t", $0}' |egrep  -v '[AT]{4,}'|head
    #sort -nr | awk '{print NR,"\t", $0}' |egrep --color=always 'T{4,}|A{4,}|$'|head
}

fasdir=/home/wforan1/seq/srna/lab/motif/fas/masked

ls -b ${fasdir}/*masked | while read file; do
  runjelly $file
done

#runjelly $fasdir/300_top_1000.fa.masked
#runjelly $fasdir/randomUpGene_1000nt.fa.masked
#runjelly $fasdir/logo_1000_up_2011-05-27-10-50.fa
#runjelly $fasdir/randomInGene-2011-05-25-15-10.fa
#runjelly $fasdir/randomIntergenic-2011-05-12-14.fa


