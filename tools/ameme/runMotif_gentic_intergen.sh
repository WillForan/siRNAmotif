#!/usr/bin/env bash


export OUTPUTDIR="outputs/gen_ingene/$(date +%F-%H-%M)/"
mkdir -p $OUTPUTDIR;

RESULTSFILE="results/results-gen_ingene-$(date +%F-%H-%M).txt"

export PARSER=./parseAMEME_aboveAvg.pl
export RUNS=4


function runmeme() {
    echo "===== back-gene, test-ingene ====="
    export RANDFILE=../../fas/randomInGene-2011-05-25-15-10.fa
    export STARTFILE=../../fas/randomIntergenic-2011-05-12-14.fa
    ./recurse_motif.sh

    echo "===== back-intergene, test-gene====="
    export RANDFILE=../../fas/randomIntergenic-2011-05-12-14.fa
    export STARTFILE=../../fas/randomInGene-2011-05-25-15-10.fa
    ./recurse_motif.sh
    echo "===== back-intergene, test-upgene====="
    export RANDFILE=../../fas/randomIntergenic-2011-05-12-14.fa
    export STARTFILE=../../fas/randomUpGene.fa
    ./recurse_motif.sh
}

for m in {m0,m1,m2}; do #not using 'coding'
    for n in {1,2,3,4}; do
      export AMEMEOPTIONS="background=$m gif=/dev/null numMotifs=$n"
      runmeme
     done
done 2>&1 |tee $RESULTSFILE
