#!/usr/bin/env bash

export RUNS=4

RESULTSFILE="results-$(date %F-%H-%M).txt"


function runmeme() {
    echo "=====Control Run 1====="
    export RANDFILE=../fas/randomIntergenic-2011-05-12-14\:24.fa 
    export STARTFILE=../fas/randomIntergenic-2011-05-12-14\:27.fa 
    ./recurse_motif.sh

    export RANDFILE=../fas/randomIntergenic-2011-05-12-14.fa 
    echo "=====Control Run 2====="
    export STARTFILE=../fas/randomIntergenic-2011-05-12-14\:24.fa 
    ./recurse_motif.sh

    echo "=====Control Run 3====="
    export STARTFILE=../fas/randomIntergenic-2011-05-12-14\:27.fa 
    ./recurse_motif.sh

    echo "====Actual===="
    export STARTFILE=../fas/300_top.fa
    ./recurse_motif.sh
}
export AMEMEOPTIONS="background=m2 gif=/dev/null numMotifs=2 controlRun=on"

for m in {m0,m1,m2,coding}; do
    for n in {1,2,3,4,5}; do
      export AMEMEOPTIONS="background=$m gif=/dev/null numMotifs=$n controlRun=on"
      runmeme
     done
done 2>&1 |tee $RESULTSFILE
