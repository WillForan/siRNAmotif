#!/usr/bin/env perl
use strict; use warnings;

####
# GetSeq -- from decode output files
####
use DBI;
my $dbh           = DBI->connect('DBI:SQLite:/home/wforan1/seq/srna/data/srna.db')
                or die "Couldn't connect to database: " . DBI->errstr;

my $findCandidate = $dbh->prepare('SELECT reads,maxcov,cov,length,llinas,conservation FROM candidates '
    			.'WHERE chrom==? and start==? and end==?')
                or die "Couldn't prepare statement: " . $dbh->errstr;
my $count=1;
my $score=0;
my %matches=();
my %avgInfo= ('reads' => 0,'maxcov' => 0,'cov' => 0, 'length' => 0 ,'llinas'=>0, 'conservation' => 0);
print join("\t","#","locus position","Mo Occurances", keys(%avgInfo),"count","width","set"),"\n";
for my $width (4,5,6,7,8,9){
    for my $randSet (29,35){
	open my $decodOutFH, "$width/300ntVsG1000_$randSet.txt" or die "cannot open $width-$randSet: $!\n";
	while(<$decodOutFH>){
	    if(m/#Score = (\d*.\d+(E-\d)?)$/){
		$score=$1*1;
		%avgInfo= ('reads' => 0,'maxcov' => 0,'cov' => 0, 'length' => 0 ,'llinas'=>0, 'conservation' => 0);
	    }
	    if(m/^#Motif instances in positive sequences:/){
#		print "$count-$width-$randSet\t", sprintf("%.5f", $score), "\t";
		while(<$decodOutFH>){
		    last if ! m/^>/;
		   (split /\t/)[0] =~ m/(chr\d+:\d+-\d+).*(revcomp)?/;
		   $matches{$1}+=1;
		} 
		for my $locus (keys %matches){
		    $locus=~s/^chr//;
		    #execute on chr#, #,#
		    $findCandidate->execute(split /[:-]/, $locus);
		    my $info = $findCandidate->fetchrow_hashref();
		    if(!$info){ print "ERROR on $locus\n";next }

		    print join("\t","chr$locus",$matches{"chr$locus"},
		              @{$info}{keys(%avgInfo)},$count, $width, $randSet #'reads','maxcov','length','llinas','conservation'
		          ),"\n";
			

		    #locus, motif hits,reads,maxcov,length,llinas,conservation

		    #$avgInfo{$_}+=$info->{$_} for(keys %avgInfo);
		}

		#my $size=scalar(keys %matches);
		#print join("\t", $size, map { sprintf "%.3f", $avgInfo{$_}/$size } (keys %avgInfo) ),"\n";

		$count++;
		%matches=();
	    }
	}
	#end while
	close($decodOutFH);
    }
}
$dbh->disconnect;

