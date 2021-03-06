#!/usr/bin/env bash

#get input options set by vars before running:
#
# AMEMEOPTIONS	-- options for ameme (def to markov2, find 2 motifs, don't make gif)
# RANDFILE	-- fasta of random intergenic region
# RUNS		-- number of recursiosn before completing
# STARTFILE	-- file containing initial sequences in which a motif is saught
# PARSER	-- perl script that will parse output 
# OUTPUTDIR 	-- dir for output files (defaults to "outputs")
#		    (.._topThird.pl or ..._aboveAvg.pl


if [  "$AMEMEOPTIONS" == "" ]; then
    AMEMEOPTIONS="background=m2 gif=/dev/null numMotifs=2"
fi
if [  "$OUTPUTDIR" == "" ]; then
    OUTPUTDIR="outputs"
fi
mkdir -p $OUTPUTDIR/results

if [  "$RANDFILE" == "" ]; then
    RANDFILE=../fas/randomIntergenic-2011-05-12-14\:24.fa 
    #RANDFILE=../fas/randomIntergenic-2011-05-12-14:27.fa
    #RANDFILE=../fas/randomIntergenic-2011-05-12.fa
fi

if [  "$STARTFILE" == "" ]; then
    STARTFILE=../fas/300_top.fa
fi

if [  "$RUNS" == "" ]; then
    RUNS=4;
fi

if [  "$PARSER" == "" ]; then
    PARSER= ./parseAMEME_topThird.pl;
fi

function runmeme(){
    run=$(($run+1));
    back=$(echo $AMEMEOPTIONS|sed 's/.*background=\(m[0-4]\).*/\1/');
    motifs=$(echo $AMEMEOPTIONS|sed 's/.*numMotifs=\([0-9]\).*/\1/');
    ameme good=$1 bad=$RANDFILE $AMEMEOPTIONS 2>> ${OUTPUTDIR}/STDERR.txt | tee ${OUTPUTDIR}/results/$run-$motifs-$back-$(basename $1 .fa).txt | $PARSER | while read filename; do
	if [ $run -lt $RUNS ]; then
	   echo "=> $filename (iteration $run)";
	   runmeme $filename
	fi
    done;
}

run=0;
#echo running intitial
echo "=> $STARTFILE with $AMEMEOPTIONS"
runmeme $STARTFILE



