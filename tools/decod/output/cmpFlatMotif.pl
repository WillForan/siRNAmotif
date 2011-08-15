#!/usr/bin/env perl
use strict; use warnings;
use Data::Dumper;
####
# CmpFlatMotif -- elliminate motifs that do not overlap and extend thoses that do
#                 use each extended set to iterate up extending kmer motifs
####

our $width=1;

use Getopt::Std;
my %opts=(f=>'flat/top300.txt');
getopts('f:h',\%opts);
if ($opts{h}){
    print "USAGE : $0 -f flat/file.txt\n";
    print "Output: for each width against one larger, list motifs that overlap with part that extends\n";
    print "Output: ext. width\text. motif\torg motif\tlonger motif\n";
    print "EG:\n\t";
    print q:for t in {tRNA,snRNA,snoR,RUF6,top300}; do echo $t; ./cmpFlatMotif.pl -f flat/$t.txt |awk -F "\t" '($2==$4){print}'; done:;
    print "\n";
    exit;
}
#compare e.g. [A,T,C] and [A,G] for any match/overlap
#return an array with what is in common. e.g. (A)
sub cmpNTs {
    my ($sPos,$bPos) = @_;
    my @motif;
    for my $sNT (@{$sPos}) {
	for my $bNT (@{$bPos}){
	    push @motif, $sNT if($sNT eq $bNT);
	}
    }
    return @motif;
}

#print motifs
sub stringifyMotif{
    #    @_ = [ [A,T], [G,C] , ..]
    # return  "A,T|C,C,..."
    return join ( '|', map { join(',', @{$_}) } @_);
}

# use smaller motif as a window
# find motifs that can overlap
# return array of motifs with _overlap only_ extended
sub cmpMotifs {
    my @sPos = @{ $_[0] };
    my @bPos = @{ $_[1] };

    my @overlapM;
    my @extendedOverlaps;

    #move the start position for big (lager) motif to make a moving window the size of the smaller motif
    for my $start (0..$#bPos-$#sPos){
	#should be a window the size of sPos
	my $end=$start+$#sPos;
	for my $i ($start..$end){
		#get all NTs overlapping
		#start = 0
		#i         :    0      1      2     
		#$bPos     :   [A,T ] [T]    [T]   [A,T] [C,G] 
		#$sPos     :   [T,C]  [T]    [A]   [C,G]
		#i-start   :    0      1      2     
		#@overlapM :   [T]    [T]     LAST

		# start = 1
		#i         :           1      2      3     4
		#$bPos     :   [A,T ] [T]    [T]   [A,T] [C,G] 
		#$sPos     :          [T,C]  [T]   [A]   [C,G]
		#i-start   :           0      1      2     3
		#
		#@overlapM :           [T]   [T]   [A]   [C,G]
		my @over = cmpNTs($sPos[$i-$start],$bPos[$i]);
		last if $#over<0; #allow no gaps/empty overlap
		push @overlapM, [@over];
	}
	#end Positions
	if($#overlapM==$#sPos){ #the overlap is the size of the smaller motif
	    #print join("\t",
	    #		    stringifyMotif(@overlapM), 
	    #		    stringifyMotif(@bPos),
	    #		    $start,
	    #		    stringifyMotif(@sPos)
	    #	  );
	    #extend overlap to parts of the big motif not compared
	    @overlapM= (@bPos[0..$start-1],@overlapM) if($start>0);
	    @overlapM= (@overlapM, @bPos[$end+1..$#bPos]) if($end<$#bPos);

	    print join("\t",$width, stringifyMotif(@overlapM), stringifyMotif(@sPos), stringifyMotif(@bPos)),"\n";
	   
	    push @extendedOverlaps, [@overlapM]

	  }
	 #empty overlap motif
	 @overlapM=();
    
    }
    return @extendedOverlaps;

}



my %allMotifs;

#build motifs hash
open my $motifsFH, "cut -f6 $opts{f} " .q{ |sort -u| perl -ne 'print $_=~tr/\|/\|/ +1,"\t",$_'|sort -n|} or die "cannot open motifs: $!\n";
while(<$motifsFH>){
    my ($size, $motif)=split /\s+/;
    my @motif;
    my $idx=0;
    for my $pos (split /\|/, $motif){
	while($pos=~/[ATGC]/g){
	    push @{$motif[$idx]}, $&;
	}
	$idx++;
    }
    push @{$allMotifs{$size}}, [@motif];

    # @motif = ( [A], [A,T], [T] ..)
    # allMotifs{6} = [ @motif, @motif, .. ]

}
close($motifsFH);

#Motifs
my @widths = sort {$a <=> $b} keys %allMotifs;
my $startWidth = shift @widths;
my @smallMotifs=@{$allMotifs{$startWidth}};

#print intial motifs
print $startWidth,"\t",stringifyMotif(@{$_}),"\n" for (@smallMotifs);

#for 7,8,9
for $width (@widths){
    #fill temp array with overlap and exteded motifs
    my @tmpMotifs;
    #by going through all with width one bigger
    # and extending if possible
    for my $bigM (@{$allMotifs{$width}}) {
	for my $smallM (@smallMotifs) {
	    push @tmpMotifs, cmpMotifs($smallM,$bigM);
	}
    }
    #set this as the new base to compare
    @smallMotifs=@tmpMotifs;
    #end motifs
}
