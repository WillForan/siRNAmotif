#!/usr/bin/env bash

#
# 1) get $PAD(=100) nt's upstream of a siRNA candidate
# 2) get regions sequence
#


PAD=1000
DB=/home/wforan1/seq/srna/data/srna.db
POS2SEQ=/home/RNA/PlasmodiumFalciparum/genome/pos2seq.pl
BEDFILE=../fas/300_top_$PAD.bed
FAFILE=../fas/300_top_$PAD.fa
rm $BEDFILE $FAFILE;

sqlite3 -separator ' ' $DB  'select chrom,start,end,strand,cov,antiGene from candidates where length>18 and length<24 and antiGene not like "%RNA%" order by maxcov desc limit 300 ' |
while read chrom start end strand cov ag; do
  s=0;

  if [ "$strand" == "-1" ]; then
  #
  # gene    start      s
  #.....<<<<<<|-------|
  #
  # s will be a larger pos number than start, so pos2seq will print rev complement
  #
     start=$end
     s=$(($end+$PAD))
     strand='-'
  else
  #
  # s   start    gene
  # |----|>>>>>>......
  #
      s=$(($start-$PAD))
      strand='+'
      #if we're less than 0
      if [ "${s:0:1}" == "-" ]; then s=0; fi;
  fi

  echo ">($strand-$cov-$ag)chr$chrom:$start-$end"	>> $FAFILE
  $POS2SEQ chr$chrom:$s-$start				>> $FAFILE
  if [ $strand = '+' ]; then
      echo $chrom $s $start chr$chrm:$start-$end-$cov-$ag $strand $s $start 255,0,0 >> $BEDFILE
  else
      echo $chrom $start $s chr$chrm:$start-$end-$cov-$ag $strand $start $s 255,0,0 >> $BEDFILE
  fi

done 

