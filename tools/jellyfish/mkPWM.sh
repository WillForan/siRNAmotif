#!/usr/bin/env bash

jellydump='jellyfish dump -t -c'

function RegionOverRandom() {
    # join desired region to random region with empty (-e) as  0, print as "seq #region/#random"
    # eg.
    #  ATAT 23
    #  TAAT 22
    join -e 0 <($jellydump 300_top_0) <($jellydump randomInGene-2011-05-25-15-10_0) | awk '{print $1, $2/$3, $2}'
}

RegionOverRandom|sort -nr -k2|./mkPWM.pl
