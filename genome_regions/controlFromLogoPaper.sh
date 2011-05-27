#!/usr/bin/env bash

Upstream=1000
if [ -n "$1" ]; then
 Upstream=$1
 echo "upstream set to $Upstream" 1>&2
fi

features="/home/RNA/PlasmodiumFalciparum/genome/pf5/Pfalciparum_PlasmoDB-5.5.gff"
genes="./logo_paper_CATGCAC"

while read GeneName; do
    #find exons		   of the gene	  and print the location					of only the first one
    grep exon $features |grep $GeneName|  awk -v pad=$Upstream -v gene=$GeneName -F '[;|	]' '{
    chrm=substr($2,4);
    if($8=="+"){  #positive strand
        #dont go past start of gene
	if($5<pad){start=1} else{start=$5} 
	s=start-pad-1;
	e=$5-1;
    }
    else{  #minus strand
	s=$6+pad+1;
	e=$6+1;
    }
    print "chr"chrm ":" s "-" e ,gene $8
    }'| head -n 1 |while read pos info; do
	echo ">$info"
    	pos2seq.pl $pos
    done;
done <$genes > ../fas/logo_${Upstream}_up_$(date +%F-%H-%M).fa
