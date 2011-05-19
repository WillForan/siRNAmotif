for seq in ../fas/{randomIntergenic-2011-05-12-14.fa,gt4TATCATTTTT.fa,300_top.fa}; do
    for len in {7..15}; do
	projection-toolkit-0.42//findmotif -s $seq -l $len  2>/dev/null | 
	grep 'CON\|Info' |
	tr -d "\n"|
	sed -e "s/CONSENSUS: /$(basename $seq .fa)\t$len\t/g;s/Info: /\t/g;s/bits/\n/g"; 
    done;
done;
