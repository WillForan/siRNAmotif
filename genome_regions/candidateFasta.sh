#!/usr/bin/env bash

#
# 1) get $PAD(=100) nt's upstream of a siRNA candidate
# 2) get regions sequence
#


PAD=1000
DB=/home/wforan1/seq/srna/data/srna.db
POS2SEQ=/home/RNA/PlasmodiumFalciparum/genome/pos2seq.pl
InBedFile=../fas/300_top.bed
UpBedFile=../fas/300_top_${PAD}up.bed
FAFILE=../fas/300_top_$PAD.fa
i=1;
rm $FAFILE;
echo "track name=\"putitive_miRNA\" description=\"candidate miRNA $(date +%F)\" visibility=2 itemRgb=On" > $InBedFile
echo "track name=\"${PAD}UPmiRNA\" description=\"$PAD upstream of candidate miRNA\" visibility=2 itemRgb=On" > $UpBedFile

sqlite3 -separator ' ' $DB  'select chrom,start,end,strand,cov,antiGene from candidates where length>18 and length<24 and antiGene not like "%RNA%" and start>5000 order by maxcov desc limit 300 ' |
while read chrom start end strand cov ag; do
  s=0;


  if [ "$strand" == "-1" ]; then
  # if strand is minus, upstream will start at 'end' and go up
  #
  # gene     end 
  #.....>>>>>>|-------|
  #        up_start  up_end
  # up_start will be a larger pos number than up_end, so pos2seq will print rev complement
  #
     up_end=$end
     up_start=$(($end+$PAD))
     strand='-'

      #print to bed file
      echo chr$chrom $up_end $up_start chr$chrm:$start-$end-$cov-$ag 1 $strand $up_end $up_start 255,0,0 >> $UpBedFile
  else
      # if strand is plus, upstream will start at the start and go down
  #
  #       start   gene
  # |--------|>>>>>>......
  #up_start  up_end

      up_end=$start
      up_start=$(($start-$PAD))
      strand='+'
      #if we're less than 0
      if [ "${up_start:0:1}" == "-" ]; then up_start=0; fi;

      #print to bed file
      echo chr$chrom $up_start $up_end chr$chrm:$start-$end-$cov-$ag 1 $strand $up_start $up_end 255,0,0 >> $UpBedFile
  fi

  echo ">($strand-$cov-$ag)chr$chrom:$start-$end"	>> $FAFILE
  $POS2SEQ chr$chrom:$up_start-$up_end			>> $FAFILE

  #print to bed file
  echo "chr$chrom $start $end miRNAcand$i 1 $strand $start $end 0,0,255 " >> $InBedFile
  i=$(($i+1));

done 

