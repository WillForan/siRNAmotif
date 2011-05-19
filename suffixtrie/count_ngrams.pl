#!/usr/bin/env perl
use strict; use warnings;
use Data::Dumper;
use lib 'Array-Suffix-0.5/';
use Suffix;
my $sarray = Array::Suffix->new();
#$sarray->set_token_file('tokenfile.txt');
$sarray->set_newline();
$sarray->set_min_ngram_size(8);
$sarray->create_files("seqlist_arraysuffix.txt");
print Dumper($sarray->get_ngrams());
