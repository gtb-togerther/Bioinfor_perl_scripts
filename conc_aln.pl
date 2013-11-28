#!/usr/bin/perl

# conc_aln.pl
# to Concatenate the fasta alignmens by sequence names
# Don't need every single file has the same number of sequence names
# if one seq don't present in some files, add 'N' or '-' to fill the gap
#
# 2013/07/25, by wjchen;
# usage: put all aln.fas files in the same folder, type perl conc_aln.pl in
# command line environment

use strict;
use warnings;

#############################################
# get the uniq name list of given files
# ###########################################

my %uniq_name_list = ();

foreach my $filename ( glob "*.out" ) {

    unless( open(IN, "<$filename")) {
        print STDERR "Cannot open file \"$filename\":$!\n";
    }

    while(<IN>) {
        if(/^>(\w+)/) {
            $uniq_name_list{$1}++;
        }
    }
}


#############################################
# store the concatenated sequences in a hash
# under the key of species names
# ###########################################
my %concatenated_sequences = ();
foreach (keys %uniq_name_list) {
    $concatenated_sequences{$_} = "";
}

foreach my $filename ( glob "*.out" ) {
    unless( open(IN, "<$filename")) {
        print STDERR "Cannot open file \"$filename\":$!\n";
    }

    print "Appending \"$filename\"\n";

    $/ = ">";

    my %handling = ();
    my $aln_length = 0;
    # handle every single input aln file
    while(<IN>) {
        if(/^>$/) {
            next; # remove the 1st > at the very beginning
        }
        s/>//; # remove the > at the end
        if (/(\w+).*\n(.*)\n/) {
            $handling{$1} = $2; # store the sequence in a temp hash
            $aln_length = length $2;
        }
    }

    # fill in the miss species with "-"
    foreach my $species (keys %uniq_name_list) {
        unless (exists $handling{$species}) {
            $handling{$species} = "N" x $aln_length;
        }
    }

    # append the handling sequences to the %concatenated_sequences
    foreach my $species ( keys %concatenated_sequences ){
        $concatenated_sequences{$species} .= $handling{$species};
    }
}

##########################################
# Output
##########################################

open(OUT,">output.fas");
foreach (sort keys %concatenated_sequences) {
    print OUT ">$_\n$concatenated_sequences{$_}\n";
}

print "\nCompleted and program exit!";

close IN;
close OUT;
exit;
