#!/usr/bin/env perl
use strict; use warnings;
use Data::Dumper;

my @motif;
use Getopt::Std;
my %opt;
getopts('m:',\%opt);
die "No motif provided (use -m switch)\n" if !exists($opt{'m'});
my $sum=0;
my $i=0;
while($opt{'m'}=~m/([ATGCNatgcn])(0?\.?\d+)/g) {
  #go to next is we're close enough to one
  if($sum>=.99){$sum=0; $i++};
  warn "multiple of same letter ($1) in postion ($2)\n" if exists($motif[$i]->{$1});
  $motif[$i]->{$1}=$2;
  $sum+=$2;

  #print "$1 (pos $i) makes sum $2 bigger: $sum\n"; # just checking :)
}
print Dumper(@motif); #just checking

my $id='none';
my $indx=0;
my @seq;
my $maxscore="-Inf";
my $bestpos=0;
my $count=1;
my $below=0;
my @pos=();

while(<>) {
 chomp;
 if(/^>/) { 
    $id = substr($_,2); 
    $indx=0; 
    $count=1;
    $below=0;
    $maxscore="-Inf";
    $bestpos=0;
    @pos=();
    $_=<>;
 }
 
 #lets assume we have everything on one line
 #if(length($_)-$i<$#motif) {
 #need to wrap around newline
 #}
 $i=0;
 while(length($_)-$i >$#motif){

     #slurp in a enough to compiar to the motif
     @seq=split //, substr($_,$i,$#motif+1);
     
     #init a score
     my $score=0;

     #for each positin in @seq/@motif, tabulate score
     for(my $pos=0; $pos<=$#seq; $pos++) {
       #score is multiplied by liklihood of seeing character in position, 0 if it doesn't exist
       if(!exists $motif[$pos]->{$seq[$pos]}) {
        $score="-Inf";
	last;
       }
       my $posscore= $motif[$pos]->{$seq[$pos]};
       #print " ($pos: $seq[$pos]=$posscore) "; #print check
       $score+=log($posscore);
     }

     #just to check, print whats going on
     print "$i\t", @seq,"\t$score\n";

     #update best if we can
     if ($score==$maxscore) { $count+=1; push @pos, $i; }
     elsif ($score>$maxscore) { 
	#bring score and pos up-to-date
     	$maxscore=$score; $bestpos=$i; 
	#set counts
	$below+=$count; $count=1; 
	#set positions
	@pos=(); push @pos,$i; 
     }
     else { $below+=1; }

     #move window over one
     $i++;
 }
 print "best score $maxscore at ",join(',',@pos), " ($below below)\n";
}
