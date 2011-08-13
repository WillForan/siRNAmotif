#!/usr/bin/env perl
use strict; use warnings;
use v5.10;
####
# Flatten -- print motif, score, background, etc as one line per positive match
#
# used like:
#    for type in {snoR,snRNA,tRNA,RUF6}; do ./flatten.pl {6,7,8,9}/${type}VsG1000_{29,35}.txt > flat/$type.txt; done;
#    
# Output
#      1             2                  3                4
#    Width[6-9], NegSeat [29.35],   motifNum [1-10], Motif score, 
#           5         6              7        8              9    
#    indv score,    Motif,   idv match seq, pos of match , $locus. $rc
####
my $negSet=29;
my $width=6;
my $positive=0;
my $motifNum=0;
my $motif='';
my $score=0;
my %letter=(0 =>'A', 1 =>'C', 2 =>'G',3 =>'T');

while(<>){
    chomp;
    given($_){
	when(/^#Motif width = (\d+)$/) { $width=$1 }
	when(m{^#Negative sequence file = ../../fas/masked/randomInGene_1000-.*-(\d+).fa.masked$}) { $negSet=$1 }
	when(m/^#Score = (\d+.?\d+)/){$score=$1 }
	when(m/^>Motif(\d+)/){
	    $motif='';
	    $motifNum=$1;
	    my @motifarray;
	    #read in motif (4 more lines) and build array
	    for (0..3) {
		$_=<>;
		my $idx=0;
		while(m/(\d+.?\d+)/g){
		    #@motif =( [ 0.00  0.000 1.000 ..]  #A
		    #          [ 0.00  0.000 1.000 ..]  #C
		    #          ....
		    #
		    #               idx
		    #      0     1    2    4  5  6
		    #
		    #A    0.0   1.0
		    #C    0.5   0.0
		    #G    0.5   0.0
		    #T    0.0   0.0 
		    #
		    #$motif[0][1]=1

		    push @{$motifarray[$idx]}, $&;
		    $idx++;
		}
	    }
	    
	    #motif is collected, now flatten to $motif
	    for my $pos (0..$#motifarray){
		for my $nt (0..3) {

		    my $freq = sprintf ( "%2.0f", $motifarray[$pos]->[$nt]*100);

		    if($freq > 0){
			$motif.= $freq if $freq<100; 
			$motif.= $letter{$nt} 
		    }
		}
		$motif.="|" unless $pos==$#motifarray;
	    }
	}
	when(m/^#Motif instances in positive sequences: $/){ $positive=1}
	when(m/^$/){ $positive=0}
	default{
	    # >(+-13715.3-PFA0375c)chr1:308823-308844|revcom  285     TATGTG  7.3440
	    m/^>(chr\d+:\d+-\d+)(\|revcom)?\t(\d+)\t([ATGCatgcN]+)\t(\d+.?\d+)$/;
	    next if !$&;
	    my $locus=$1;
	    my $rc=$2?$2:"";
	    my $pos=$3;
	    my $seq=$4;
	    my $sscore=$5;
	    print join("\t",$width, $negSet,$motifNum, $score, $sscore, $motif, 
		    $seq, $pos,
	            $locus. $rc),"\n" if($positive);
	    
	}

    }
}

