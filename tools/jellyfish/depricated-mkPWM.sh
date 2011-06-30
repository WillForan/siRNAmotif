#!/usr/bin/env bash

jellydump='jellyfish dump -t -c'

#what files are we working on?
if [ "$MKPWM_BACK" == "" ]; then
    echo 'using default background' >&2
    MKPWM_BACK='jellyout/masked/randomInGene-2011-05-25-15-10-6_0'
    #MKPWM_BACK='randomIntergenic-2011-05-12-14-6_0' #does not find logo 
fi
if [ "$MKPWM_FOR" == "" ]; then
    echo 'using default forground' >&2
    MKPWM_FOR='jellyout/masked/logo_1000_up_2011-05-27-10-50-6_0'
fi

#show what we're using
#echo export MKPWM_BACK=$(pwd)/$MKPWM_BACK >&2
#echo export MKPWM_FOR=$(pwd)/$MKPWM_FOR >&2
echo export MKPWM_BACK=$MKPWM_BACK >&2
echo export MKPWM_FOR=$MKPWM_FOR >&2

function RegionOverRandom() {
    # join desired region to random region with empty (-e) as  0, print as "seq #region/#random"
    # eg.
    #  ATAT 23
    #  TAAT 22
    join -e 0 <($jellydump $MKPWM_FOR) <($jellydump $MKPWM_BACK) | 
    awk '{print $1, $2/$3, $2}' #provides word, 'score', and # occucrances
}

RegionOverRandom |	#score
   sort -nr -k2|	#rank
   ./mkPWM.pl "$@"	#process
