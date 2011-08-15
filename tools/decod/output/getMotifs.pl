#!/usr/bin/env perl
use strict; use warnings;

####
# GetMotif -- from decode output files
####
use Getopt::Std;
#defaults: w->widths, r->random backgrounds, f->foreground, d->base dir
my %opts=(w=>'4,5,6,7,8,9',r=>'29,35',f=>'300ntVsG1000',d=>'./');
getopts('w:r:f:d:',\%opts);

my $score=0;
my $totalcount=1;
my %letter=(0 =>'A', 1 =>'C', 2 =>'G',3 =>'T');
#for my $width (4..9){
for my $width (split /,/,$opts{w}){
    #for my $randfile (29,35){
    for my $randfile (split /,/,$opts{r}){
	#open my $motifFH, "$width/300ntVsG1000_$randfile.txt" or die "cannot open motifFH: $width/300ntVsG1000_$randfile.txt $!\n";
	my $motifFile="$opts{d}/$width/$opts{f}_$randfile.txt";
	open my $motifFH, $motifFile or die "cannot open motifFH: $motifFile $!\n";
	my $count=1;
	while(<$motifFH>){
	    if(m/^>Motif/){
		#chomp;
		#push my @lines, $_;
		my @lines;

		my @motifarray;
		my $motif='';
		while(<$motifFH>){
		    chomp;
		    last if ! m/^[ATGC]/;
		    push @lines, $_;
		    
		    #see flatten.pl for whats goign on here
		    my $idx=0;
		    while(m/(\d+.?\d+)/g){
			push @{$motifarray[$idx]}, $&;
			$idx++;
		    }
		}
		#see flatten.pl for whats goign on here
		for my $pos (0..$#motifarray){
		    for my $nt (0..3) {

			my $freq = sprintf ( "%2.0f", $motifarray[$pos]->[$nt]*100);

			if($freq > 0){
			    $motif.= $freq if $freq<100; 
			    $motif.= $letter{$nt} 
			}
		    }
		    $motif.="_" unless $pos==$#motifarray;
		}
		m/^#Score = (\d+.\d+(E-\d+)?)/;
		#$lines[0].="_".substr(1*$1,0,6)."_w${width}_$randfile";

		print ">$randfile-${width}-${count}-$motif-",sprintf("%.5f",$1),"\n";
		print join("\n",@lines),"\n";
		$count++;
		$totalcount++;
	    }
	}
	close($motifFH);
    }
}
