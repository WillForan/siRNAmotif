#!/usr/bin/env bash
# 
# complementary program to genfasta.sh
#   
# print a bunch of sequences from intergenic regions
# e.g. 
#    ./genRandom.sh 300 > randomIntergenic-$(date +%F-%H:%M).fa
#
# source of intergeic regiosn is FILE(=iReg.txt)
# length is defined by that used in genfasta.sh (SIZEofSEQ=101)

#Max size of reads
SIZEofSEQ=101;
#input file
FILE=./iReg.txt; 
WC=$(wc -l $FILE|cut -f1 -d ' ');

#set number of sequences to use, default to 300
NUMofSEQ=300;
if [ -n "$1" ]; then
  NUMofSEQ=$1;
fi


#get two lines (as one) from intergenic file ( only one if happens to hit '>' line)
function rndline(){
awk \
      -v num=$(( $RANDOM % $WC +1)) \
      '(NR==num){ 
        if(/REST/) {num=num+1; next;}
      	if($4=="+"){ print "chr"$1":"$2"-"$3 } 
	else       { print "chr"$1":"$3"-"$2 } 
      }' $FILE 
}

for (( i = 0; i < NUMofSEQ; i++ )); do
  SEQ=$(/home/RNA/PlasmodiumFalciparum/genome/pos2seq.pl $(rndline))
  len=${#SEQ}

  echo ">$i"
  if [ $len -le $SIZEofSEQ ];then  echo $SEQ;
  #substr of seq of length size_of_seq
  #get a random number between 0 and how much more than sizeOFseq the sequence is
  else echo ${SEQ:$(( $RANDOM % $(($len-$SIZEofSEQ)) )):$SIZEofSEQ}
  fi
done
