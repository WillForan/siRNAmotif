#!/usr/bin/env perl
use strict; use warnings;

####
# GetSeq -- of a numbered motif from decode output files
# eg ./getSeq.pl 1 6/300ntVsG1000_29.txt
# useful for weblogo
####
if($#ARGV!=1) {
    print "USAGE: $0 motif# motif_File\n";
    print "use 0 to as motif# to print all\n";
    exit;
}

my $count=1;
my $score=0;
my $desiredMotif=shift @ARGV;
while(<>){
    if(m/#Score = (\d*.\d+(E-\d)?)$/){
	$score=$1*1;
    }
    if(m/^#Motif instances in positive sequences:/){
	print ">MOTIF${count}_$score\n" if($desiredMotif==0 || $count==$desiredMotif);
	while(<>){
	    last if ! m/^>/;
	    print( (split /\t/)[2], "\n") if($desiredMotif==0 || $count==$desiredMotif);
	}
	last if ($desiredMotif !=0 && $count==$desiredMotif);
	$count++;
    }
}

