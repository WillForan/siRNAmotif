#!/usr/bin/env perl
use strict; use warnings;
use Getopt::Std;
my %opt; 
getopt('n:m:t:f:b:k:',\%opt);
####
# MkPWM
# create position weight matrix from jellyfish dump output (as parsed by mkPWM.sh)
# expect input in the form of
$Getopt::Std::STANDARD_HELP_VERSION=1;
sub HELP_MESSAGE {
    print qq{
    USEAGE: $0 [options]
    Run GEMS like algorithm on kmer frequency fore/back-ground files to elicit motifs

    -r  make output human readable (instead of patcan format)
    -n  number of motifs 
    -m  maximum mismatches to allow in building motif
    -t  # <= background frequence skipped
    -k  kmer base for file name (overrides f and b)
    -f  foreground file (e.g 300_top)
    -b  background file (e.g. randomInGene)\n};
    exit;
}
HELP_MESSAGE if $opt{h};
####


my $READABLE   = $opt{r} || 0;
#thresholds
my $scoreThres = $opt{t} || 1;	#don't consered anything <= background word frequency
my $numMotifs  = $opt{n} || 5;	#??? -- number of similiarities removed from pool at each mismatch iteration
my $maxMismatch= $opt{m} || 2;	#set to 40% length in GEMS paper

#specifying k overides f or b
# and no option can be 0 or ''
my $foreground = defined $opt{k} ? "jellyout/masked/300_top_1000-$opt{k}_0" :0 ||
		 $opt{f} || 
		 'jellyout/masked/300_top_1000-6_0';
my $background = defined $opt{k} ? "jellyout/masked/randomInGene-2011-05-25-15-10-$opt{k}_0" :0 ||
		 $opt{b} || 
                 'jellyout/masked/randomInGene-2011-05-25-15-10-6_0';

#print STDERR "$foreground $background\n"; exit;

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

#get ranked sequences
my $jellydump='jellyfish dump -t -c';
my $pipe = "bash -c 'join -e 0 <($jellydump $foreground) <($jellydump $background)' | 
            awk '{print \$1, \$2/\$3, \$2}' |
            sort -nr -k2|";
#output like:	GATAAC 4.33333 39

open my $randomOverRegionSortedFH, $pipe
     or die "cannot open randomOverRegionSorted: $!\n";

#grab kmer and its score
while (<$randomOverRegionSortedFH>) {
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

    if($READABLE==1){
	#display the  PWM (PSSM)
	print "\nseed $motif->[0][0], $#{$motif} words,  $totalOccur occurances\n";
	#print  " \t", join("\t", (1..6)), "\n"; #print row of postion numbers

	#print letter   .3f% of each score in the letter array                for each letter
	print  "$_\t", join("\t", map {sprintf "%.3f", $_} @{$PWM{$_}}), "\n" for (keys %PWM);
    }

    if(!$READABLE){
	#write motif for patscan
	my @poses;
	for my $pos (0..length($motif->[0][0])-1){
	     push @poses, "(". join(",", map {100*sprintf("%.2f",$PWM{$_}->[$pos]) } ('A', 'C', 'G', 'T')) . ")";
	}
	print "$motif->[0][0]: {", join (",",@poses), "}\n";
    }
}

