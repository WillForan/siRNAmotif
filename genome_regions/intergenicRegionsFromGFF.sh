#!/usr/bin/env bash


features="/home/RNA/PlasmodiumFalciparum/genome/pf5/Pfalciparum_PlasmoDB-5.5.gff"

chrm_sense=0;		chrm_antisense=0;
end_sense=0; 
end_antisense=0;

#get only features   on a chrom        not whole chrom    chrom start end sense     sorted by chr# and then position
grep ^apidb $features |grep MAL | awk -F '[;|	]' '(NR>14){print substr($2,4), $5, $6, $8}'|sort -n | uniq | while read chrm start end strand; do
    ##########
    #sense
    #########
    if [ $strand == "+" ]; then
      
      #on a new chrom
      if [ $chrm_sense != $chrm ]; then
	  #1)print |------ and --------|
	  #2) update chrom
	 echo $chrm_sense $(($end_sense-1)) REST  +
	 echo $chrm 1  $(($start-1))  +
	 chrm_sense=$chrm

      #
      #  >>>>>>>>>>>>>>>>>>>>>>>
      #  s-------e   s---------e
      #  
      elif [ $end_sense -lt  $start ]; then
         #print gap
	 echo $chrm $(($end_sense-1)) $(($start-1)) +
      #else
        #echo "($end_sense >= $start)"
      fi

      # else s------e
      #          s--------e

      end_sense=$end
      #echo "(end moved to $end_sense)"

    ##########
    #antisense
    #########
    else
      
      #on a new chrom
      if [ $chrm_antisense != $chrm ]; then
	  #1)print |------ and --------|
	  #2) update chrom
	 echo $chrm_antisense $(($end_antisense-1)) REST  +
	 echo $chrm 1  $(($start-1))  +
	 chrm_antisense=$chrm

      #
      #  >>>>>>>>>>>>>>>>>>>>>>>
      #  s-------e   s---------e
      #  
      elif [ $end_antisense -lt  $start ]; then
         #print gap
	 echo $chrm $(($end_antisense-1)) $(($start-1)) +
      #else
        #echo "($end_antisense >= $start)"
      fi

      # else s------e
      #          s--------e

      end_antisense=$end
      #echo "(end moved to $end_antisense)"
   fi

    #echo \($chrm $start $end $strand\)
done

echo $chrm_sense $(($end_sense-1)) REST  +
echo $chrm_antisense $(($end_antisense-1)) REST  -
