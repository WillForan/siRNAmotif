#!/usr/bin/env perl
use strict; use warnings;
####
# MkPWM
# create position weight matrix from jellyfish dump output (as parsed by mkPWM.sh)
# expect input in the form of
#
# kmer_seq kmer_score kmer_freq(in intereted area)
####

#thresholds
my $scoreThres=1;	#don't consered anything <= background word frequency
my $numMotifs=10;	#???
my $maxMismatch=2;	#set to 40% length in GEMS paper

#data strcuture
#$seq[1]=[ 'AAAAA', 3, 134 ]
#          seq, times overrep., actual freq
my @seq;

#count number of mismatchs between strings
sub isMatch{
    my $diff = $_[0] ^ $_[1];
    return $diff =~ tr/\0//c;
}

#make pwm
sub pwm {
    my ($thres, $top)=@_;
    my @belongToTop;
    #move related sequences from general pool into array for top
    #grep for sequences that do not diff by thres from top
    @seq = grep {
	    my $ispart=isMatch($top,$_->[0])<=$thres;	#is the within thres
	    push @belongToTop, $_ if $ispart;				#add to seqs in top;
	    !$ispart 							#returns false if it's not part, so is kept in array
	} @seq;
    #print "found $#belongToTop allowing $thres mismatches for $top (amoung $#seq)\n";
    return @belongToTop;

}
#grab kmer and its score
while (<>) {
    chomp;
    #push @seq, [(split / /)];
    my @line=split /\s/;
    push @seq, [@line] if $line[1] > $scoreThres;

}

my @motifs;
#intialize motif template and remove those one mismatch away
# motif[1] = [ [AAAAA, 4, 44], [AAAAT, 3, 145], ...] 
# motif[2] = [ [ATTAA, 3, 23], [ATTAT, 2,  25], ...] 

for (0..$numMotifs-1) {
    #pick the top one to use as baseline motif
    my $top= shift @seq; 
    #add it to it's own position
    push @{$motifs[$_]}, $top;
    #add all others like it (distance 1)
    push @{$motifs[$_]}, pwm(1,$top->[0]);
}

##match sequences that are more than 1 and up to maxMismatch away
#for each threshold 2 to whatever
for my $thres (2..$maxMismatch){
    #for each motif number
    for (0..$numMotifs-1) {
	#add any new hits
	push @{$motifs[$_]},pwm($thres,$motifs[$_][0][0]);
    }
}

use Data::Dumper;
#print the outputs
foreach my $motif (@motifs) {
    print "\n==== $#{$motif}\n";
    my %PWM;
    #A => [3,0,2,3]
    #T => [1,4,2,1]
    
    foreach  (@{$motif}) {
	#print join("\t",@{$_}),"\n";
	#my $seq=$_->[0];
	my $freq=$_->[2];
	my @s = split //, $_->[0];
	for my $pos (0..$#s) {
	    #eg  PWM{A}[0]=20, or a in the 1st pos happens 20 times 
	    $PWM{$s[$pos]}[$pos]+=$freq;
	}
	
    }
    print Dumper(%PWM),"\n";
}

