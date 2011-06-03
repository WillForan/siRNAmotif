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
my $numMotifs=5;	#???
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


#build me up buttercup (get actual frequence of each letter using #of times kmer exists)
foreach my $motif (@motifs) {

    #loop through once to get total
    my $totalOccur;
    $totalOccur+=$_->[2] for (@{$motif});


    #create matrix
    my %PWM;

    $PWM{$_}=[ (0) x length($motif->[0][0]) ] for ('A','T','G','C');
    #init pwm to an array of 0s of the length of the first motif's first word (motif->[0][0])
    #PWM{'A'} => [ 0, 0, 0, ..]
    #     T   =>  ...
    #     ...

    foreach  (@{$motif}) {
	my $freq=$_->[2];
	my @s = split //, $_->[0];
	for my $pos (0..$#s) {
	    #eg  PWM{A}[0]=20, or a in the 1st pos happens 20 times 
	    $PWM{$s[$pos]}[$pos]+=$freq/$totalOccur;
	}
	
    }

    #display the  PWM (PSSM)
    print "\nseed $motif->[0][0], $#{$motif} words,  $totalOccur occurances\n";
    #print  " \t", join("\t", (1..6)), "\n"; #print row of postion numbers

    #print letter   .3f% of each score in the letter array                for each letter
    print  "$_\t", join("\t", map {sprintf "%.3f", $_} @{$PWM{$_}}), "\n" for (keys %PWM);
}

