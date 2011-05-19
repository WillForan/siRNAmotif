#!/usr/bin/env perl
use strict; use warnings;
#print new files (top 1/3 of motif id) to work on
#use warn to display status


#where to store output files
my $outdir="outputs/"; #need ending /
my $MIN=10; #min number of sequences needed to produce output

#intiialize
my $motif='';
my ($score, $pos, $sd);
my @seqs;

#read in output of ameme (likely from pipe)
while(<>){
 #don't don't about colored output, skip the rest of it
 last if m/^Color/;

 #remove p tages so we dont skip header of motif
 $_=~s/<P.*\/P>//g;

 #otherwise skip if there is html
 next if m/<[^\>]+>/;
 
 #motif like: [score] @ [pos] sd [standard devation]  [motif]
 if(/^(\d+.?\d*) @ (\d+.?\d*) sd (\d+.?\d*) ([ATGCatgc]+)/){
   #if there are stored sequences, print them and start again
   if($#seqs>-1) { &printSorted; @seqs=();}

   #set the new motif
   $score=$1; $motif=$4; $pos=$2; $sd=$1;
   #warn "$score $motif @ $pos sd $sd\n"; 
 }
 elsif(/^ \d+.?\d*/){
   #if there is a space then the score, this is a sequence
   chomp;
   my ($score,$name,$seq)= (split / +/)[1,2,3];
   push @seqs, [sprintf('%.2f', $score), $name, $seq];
 }
 #otherwise nothing interesting is happening
 else {next}
}

#and last motif, not nessary -- script picks up on second printing of first motif before quitting
#&printSorted($motif);


######function to print and store sequences
sub printSorted() { #expects to be given a motif sequence
  

  #unless there are too few sequences
  if($#seqs < $MIN) { warn "too few sequences ($#seqs) for $motif, not producing output\n"; return;}
  else { warn "$score\t$motif ($#seqs sequences) @ $pos ($sd)\n"; }

  print "$outdir$motif.fa\n";
  open my $mofile, ">$outdir$motif.fa" or die "cannot open $motif.txt: $!"; 
  
  #sort the sequences in descending order
  my @sorted = sort {return -1*($a->[0] <=> $b->[0]) }  @seqs;

  #make a fasta of the top (1/3)
  #>name-motif-(score@pos-sd)
  #seq
  print $mofile 
  	">",$sorted[$_]->[1]."-$motif(".$sorted[$_]->[0],"\@$pos-$sd)\n",
	$sorted[$_]->[2],"\n" 
    for (0..int($#seqs/3));

  close $mofile;
}
