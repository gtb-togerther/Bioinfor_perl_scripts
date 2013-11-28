#!/usr/bin/perl
# given a pattern (or say sequence motif) like "CCGTT"
# extract all the sequences contained the given pattern
# from a file
#
# usage: perl extract_given_pattern_seq.pl CCGTT clean.fa
#
# 2013/08/29, by wjchen
# 2013/09/03, modified by wjchen
# to not use the hash to store all the sequences to
# the hash, but judge if the given pattern can match the current sequence,
# if so, printed it out immediately

use strict;
use warnings;

my $usage = "usage: perl $0 pattern sequence_file";
# Specify the pattern
my $pattern = shift or die "$usage\n";
my $sequence_file = shift or die "$usage\n";
# print "$pattern, $sequence_file\n";

# Open and read in the sequence file
open(SEQ, "<$sequence_file") or die "$!\n";

# change the input delimiter to ">"
$/ = ">";

#my %sequence = ( );
while(<SEQ>){
    if(/^>$/){
        next;
    }
    s/>//; # delete the > at each end
    if(/(.*)\n([ATGCN-]+)\n/){
        # print "$1 => $2\n";
        # Store the sequences in the hash
        # $sequence{$1} = $2;
        # $1 is name, $2 contains the sequences
        my ($name, $seq) = ($1,$2);
        if($2 =~ /$pattern/){
            print ">","$name\n","$seq","\n";
        }
    }
}
close SEQ;

# # print out the sequences match the given pattern
# foreach (sort keys %sequence) {
#     # print "$_ => $sequence{$_}\n";
#     if ($sequence{$_} =~ /$pattern/) {
#         print ">", "$_\n", "$sequence{$_}", "\n";
#     }
# }
