#!/usr/bin/env perl

#given list of sequences
#print motif suitable for motifScore.pl
#e.g.
#echo -e "ATATATGC\nATATACCC\nATATATAT"|./seq2Logo.pl 
#A 1.000 T 1.000 A 1.000 T 1.000 A 1.000 T 0.667 C 0.333 A 0.333 C 0.333 G 0.333 T 0.333 C 0.667 

use strict; use warnings;
use Data::Dumper;

my $count=0;
my @motif=();
while(<>){
    chomp;
    my @seq= split //;
    for(my $i=0; $i<=$#seq; $i++) {
      $motif[$i]->{$seq[$i]}+=1;
    }
    $count++;
}

#print Dumper(@motif); #check to see if it's working

for my $pos (@motif) {
 for my $char (keys %{$pos}){
  print $char,sprintf('%.3f',$pos->{$char}/$count), " ";
 }
}
print "\n";
