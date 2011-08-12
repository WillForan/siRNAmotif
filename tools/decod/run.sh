#!/usr/bin/env bash 

if [ "$1 x" == " x" ];then
    echo "Usage: $0 [RUF6,tRNA,snRNA,snoR]"
    echo "puts decod output files in output/{6,7,8,9}/[RUF6,snRNA,snoR,tRNA]VsG1000_{29,35}.txt"
    exit;
fi

foreground="../../genome_regions/$1/1000ntUp$1.fa.masked"
#foreground='../../fas/masked/300_top_1000_noTelomer.fa.masked'
####foreground='300_top_1000_noTelomer.minus3more.fa.masked'
#####foreground= '../../fas/masked/300_top_1000.fa.masked'
background1='../../fas/masked/randomInGene_1000-2011-06-30-13-29.fa.masked'
background2='../../fas/masked/randomInGene_1000-2011-06-30-13-35.fa.masked'

if [ ! -e $foreground ];then
    echo "ERROR: $foreground DNE"
    exit;
fi
if [ ! -e $background1 ] || [ ! -e $background2 ];then
    echo "ERROR: background files do not exist"
    exit;
fi

#pull in runDECOD function
source runDECOD.sh


#for width in "8"; do
for width in {6,7,8,9}; do
    ##unknown motif -- ingene -- two sets
	    #300ntVsG1000_29.txt \
    runDECOD $foreground \
	    $background1 \
	    $1VsG1000_29.txt \
	    $width 

	    #300ntVsG1000_35.txt \
    runDECOD $foreground \
	    $background2 \
	    $1VsG1000_35.txt \
	    $width 


    ##known motifs -- ingene -- two sets
#    runDECOD ../../fas/old/masked/logo_1000_up_2011-05-27-10-50.fa.masked \
#    	../../fas/masked/randomInGene_1000-2011-06-30-13-29.fa.masked \
#    	knownVsInG1000_29.txt \
#    	$width
#
#
#    runDECOD ../../fas/old/masked/logo_1000_up_2011-05-27-10-50.fa.masked \
#    	../../fas/masked/randomInGene_1000-2011-06-30-13-35.fa.masked \
#    	knownVsInG1000_35.txt \
#    	$width
done
