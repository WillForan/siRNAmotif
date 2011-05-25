#!/usr/bin/env perl
use strict; use warnings;

#libaries
use lib '/home/RNA/lib/perl/lib/perl5/';
use HTML::Template;
use CGI;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser); 
use Data::Dumper;

my $cgi  = CGI->new;
print $cgi->header('text/html');
#print "Content-type: text/html\n\n";

my $root='/home/wforan1/seq/srna/lab/motif/tools/ameme/';

#if(length $ENV{'QUERY_STRING'} < 1){
#listing if we don't know what to do
if(!$cgi->param('file') && !($cgi->param('date')||$cgi->param('type') )  ){
    opendir my $dir, $root.'results/' or die 'cannot open results directory\n';

    while(my $file = readdir($dir) ){
     if($file=~/results-(.*)-(2011-[0-9\-]+).txt$/) { #change here if ever generating output after this year
	 print "<a href=\"?file=$file&date=$2&type=$1\" >$file </a><br>\n";
     }
    }
    print "--\n";
    exit;
}
if($cgi->param('date') && $cgi->param('type') && $cgi->param('run') && $cgi->param('seq')  ){
 my $file="$root/outputs/".
     $cgi->param('type')   ."/".
     $cgi->param('date')   ."/results/".
     $cgi->param('run')    ."-".
     $cgi->param('motifs') ."-".
     $cgi->param('back')   ."-".
     $cgi->param('seq')    .".txt";
 print `cat $file 2>&1`;
 exit
}

#print file
print <<HERDOC
<html><head>
<title>Motifs</title>
<script type="text/javascript" src="/srna/js/jquery-1.5.1.min.js"></script> 
<script type="text/javascript" src="/srna/js/jquery.tablesorter.min.js"></script> 
<script>
\$(document).ready(function(){\$("#tab").tablesorter(); });
</script>
<link rel="stylesheet" href="/srna/css/blue/style.css" type="text/css">
</head>
<body>
HERDOC
;

my $cmd="$root/results/tabDelimOutput.sh $root/results/". $cgi->param('file'). " | ";
open my $rstPipe, $cmd or die 'broken pipe';

my @fields=('score','seq','pos','std','numseq','background','motifs','run','iteration','from');

print '<table id="tab" class="tablesorter"><thead>',"\n";
print "<tr><th>", join('</td><th>', @fields),'</th></tr></thead>',"\n<tbody>\n";

while (my $line = <$rstPipe>){
    my @param;
    my @line=split("\t",$line);

    my $run=$line[8]+1;
    my $seq=$line[9];
    my $back=$line[5];
    my $motifs=$line[6];

    push @param, "$_=".$cgi->param($_) for ('type','date');
    push @param, "run=$run", "seq=$seq", "back=$back", "motifs=$motifs";

    $line[9]="<a href='?". join('&',@param) . "'>$seq</a>";

    print "<tr><td>", join('</td><td>', @line),'</td></tr>',"\n";
}
print "</table>"
