#!/usr/bin/env perl
use strict; use warnings;
use Data::Dumper;
####
# Motif2Patscan -- covert from decod to patscan
####

#decod
#>Motif35_1.980084041446335E-4
#A [0.0000 1.0000 1.0000 0.0000 1.0000 1.0000]
#C [0.0000 0.0000 0.0000 0.2500 0.0000 0.0000]
#G [1.0000 0.0000 0.0000 0.7500 0.0000 0.0000]
#T [0.0000 0.0000 0.0000 0.0000 0.0000 0.0000]
#
#patscan
# {(0,0,1,0), ... }
#
my @motif=();
my @max=();
my @min=();
my $motifName="Error";

sub printMotif{
    return if $#motif==-1;
    print "#$motifName\n";
    print '{';
     print join(',', 
         map {
                 '('  
         	. join(",", map { sprintf "%.0f", $_*100} @{$_}) 
         	. ')'

             } @motif);
     print "}\n";
     my $min=0;
     $min+=$_ for (@min);
     $min*=100;
     my $max=0;
     $max+=$_ for (@max);
     $max*=100;

     if($max != $min){
	 print "#Min: $min\n"; 
	 print "#Max: $max\n";
     }
     else{
	 print "#Pattern must be $min\n";
     }
    
    #clear motif
    @motif=();
    @max=();
    @min=();
    print "\n";
}
while(<>){
    if(/^>/){
	printMotif; 
	chomp;
	s/^>//;
	$motifName=$_;
	next;
    }
    my $idx=0;
    while(m/(\d+.?\d+)/g){
	#[(0,0,1,0), () ]
	#print "pushing $& at $idx\n";
	push @{$motif[$idx]}, $&;

	$max[$idx]=$& if(!exists($max[$idx]) || $max[$idx]< $&);
	$min[$idx]=$& if( $&>0  &&   ( !exists($min[$idx]) || $min[$idx] > $& )   );
	$idx++;
    }
}
printMotif


