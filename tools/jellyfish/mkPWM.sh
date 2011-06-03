#!/usr/bin/env bash

jellydump='jellyfish dump -t -c'

function RegionOverRandom() {
    # join desired region to random region with empty (-e) as  0, print as "seq #region/#random"
    # eg.
    #  ATAT 23
    #  TAAT 22
    join -e 0 <($jellydump logo_1000_up_2011-05-27-10-50-6_0) <($jellydump randomInGene-2011-05-25-15-10_0) | 
    awk '{print $1, $2/$3, $2}' #provides word, 'score', and # occucrances
}

RegionOverRandom|	#score
   sort -nr -k2|	#rank
   ./mkPWM.pl		#process
