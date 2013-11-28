#!/usr/bin/perl

use strict;
use warnings;

# to print the table formated seq into fasta format
# from
# t0029643        23      37      ATATTGTCCTGTCACAGCAGTAA miRNA   miR-1000
# to
# >t0029643_37
# ATATTGTCCTGTCACAGCAGTAA  
#
# usage: perl tab2fas.pl
# 2013/08/26, by wjchen

foreach my $filename (glob "*.txt") {
    open(TXT, "<$filename") or die "$!\n";
    
    # get the output filename from input to fas
    my $outfilename = $filename;
    $outfilename =~ s/\.txt//g;
    $outfilename .= '.fas';
    open(FAS, ">>$outfilename") or die "$!\n";

    # Read in the input data, print out needed information
    while(<TXT>) {
        # get the data from each line of the file
        my ($seqname, $seqlength, $sequence) = (split /\t/)[0, 2, 3];
        print FAS ">${seqname}_$seqlength\n$sequence\n";
    }

}
