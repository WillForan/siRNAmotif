#!/usr/bin/perl
use strict; use warnings;

#####
##  Display motifs in a color coded bar
####
my $scale=1;
my $WIDTH=1000/$scale; #640;
my $HEIGHT=12; #480;
my %color=(1 => 'yellow' ,
           2 => 'blue'   ,
           3 => 'red'    ,
           4 => 'black'  );

print qq{
<svg height="$HEIGHT" width="$WIDTH" 
     xmlns="http://www.w3.org/2000/svg" 
     xmlns:svg="http://www.w3.org/2000/svg" 
     xmlns:xlink="http://www.w3.org/1999/xlink"
>};

my $width=6/$scale;
while(<>){
    chomp;
    my ($pos,$count)=split /\s+/;
    $pos=$pos/$scale;
    print 
      qq| <rect height="$HEIGHT" id="$pos" 
          style="fill: $color{$count}; fill-opacity: .3; stroke-width: 0" 
	  width="$width" x="$pos" y="0" />\n
        |;
}
print "</svg>\n"


