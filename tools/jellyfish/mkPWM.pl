#!/usr/bin/env perl
use strict; use warnings;
####
# MkPWM
# create position weight matrix from jellyfish dump output (as parsed by mkPWM.sh)
# expect input in the form of
#
# kmerseq kmerscore
####

#thresholds
my $mismatchThres=1;
my $scoreThres=1;
my $numMotifs=10;
my $maxMismatch=2;

#data strcuture
my @seq;

#count number of mismatchs between strings
sub isMatch{
    my $diff = $_[0] ^ $_[1];
    return $diff =~ tr/\0//c;
}

#make pwm
sub pwm {
    print "=\n";
    print join("\t",@{$top}),"\n";

    #foreach my $s (@seq) {
    ##   print '(',join("\t",@{$s},$top),")\n";
    #   last if $s->[1] < $scoreThres;
    #   next unless isMatch($top,$s->[0]) <= $mismatchThres;
    #   print join("\t",'',@{$s}),"\n";
    #}

    #grep for sequences not thres different than top
    @seq = grep {
	    my $ispart=isMatch($top->[0],$_->[0])<=$mismatchThres;	#is the right distance
	    print join("\t",@{$_}),"\n" if $ispart;		#then print it;
	    !$ispart 						#returns false if it's not part, so is kept in array
	} @seq;

}
#grab kmer and its score
while (<>) {
    chomp;
    #push @seq, [(split / /)];
    my @line=split /\s/;
    push @seq, [@line] if $line[1] > $scoreThres;

}

for (1..$numMotifs) {
    #pick the top one to use as baseline motif
    my $top= shift @seq; 
}
for my $thres (1..$maxMismatch){
    for my $motifnum (1..$numMotifs) {
	    pwm($thres,$start{$motifnum});
    }
}
