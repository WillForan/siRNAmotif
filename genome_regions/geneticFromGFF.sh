#!/usr/bin/env bash

features="/home/RNA/PlasmodiumFalciparum/genome/pf5/Pfalciparum_PlasmoDB-5.5.gff"

#get only features   on a chrom        not whole chrom    chrom start end sense     sorted by chr# and then position
grep ^apidb $features |grep MAL|grep exon|egrep -v '[t,r]RNA' -i | awk -F '[;|	]' '($6-$5>100){print substr($2,4), $5, $6, $8}'|sort -n | uniq > gentic_region.txt
