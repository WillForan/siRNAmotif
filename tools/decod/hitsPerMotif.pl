#!/usr/bin/env perl
use strict; use warnings;

####
# HitsPerMotif -- track where motifs begin
####
# Usage: ./hitsPerMotif [optional: 300nt,tRNA,RUF6,snRNA,snoR]
#
# Expects: existance of
#            ./output/width/300..._randomSet   (decod output)
#            ./positions                       (out for this script)
#
# Outputs: to positions/count-locus
#        position count
###
my $prefix="300nt";
$prefix=shift if ($ARGV[0]);

open my $hitFh, "bash -c \"awk '{ if(/negative/){p=0;}if(p==1){print} if(/positive/){p=1;}}' output/{6,7,8,9}/${prefix}VsG1000_{29,35}.txt |
cut -s -f1,2\" |" or die "cannot open hit pipe: $!\n";

sub uniqCount {
    #get first element and count as 1
    my $a=shift;
    my $count=1;
    my @out;

    #check each new element
    for $b (@_){
	#increase count if they're the same
	if($a==$b){
	    $count++ ;
	}
	else{
	    #or print the old with count if not
	    push @out,[$a,$count];
	    #and reset
	    $a=$b;
	    $count=1;
	}
    }
    #get last one
    push @out,[$a,$count];
    return @out;
}


my %upRegion;

while(<$hitFh>){
  chomp;
  my ($region, $hit) = split /\t/;
  push @{$upRegion{$region}}, $hit; 
}

my @output;
for my $region (keys %upRegion) {
    #print $#{$upRegion{$region}},$region, join(",", sort {$a <=>$b} @{$upRegion{$region}}),"\n";
    push @output, [$#{$upRegion{$region}}+1,$region,[uniqCount sort {$a <=>$b} @{$upRegion{$region}}] ] ;
}

my $count=0;
for my $out (sort {$b->[0] <=> $a->[0]} @output){
    #last if ++$count> 10;

    #open a file to write to like positions/count-locus|revcom
    $out->[1]=~m/chr\d+:\d+-\d+(.*\|revcom)?/;
    open my $dataOut, ">positions/$prefix/$out->[0]-$&.txt" or die "cannot open dataOut: $!\n";

    #write to file 
    #position	count
    print $dataOut join("\n",map {"$_->[0] $_->[1]"} @{$out->[2]}),"\n";
    close $dataOut;
}
