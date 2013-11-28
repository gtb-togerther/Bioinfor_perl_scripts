#!/usr/bin/perl
#
# calc_MFEI.pl
# 
# MFEI = [(MFE/length of the RNA sequence)*100]/(G+C) 
# 
# 2013/06/18, by wjchen
#

use strict;
use warnings;

my $usage = "$0 input_file\n";
my $input_file = shift or die $usage;

# read in the input file
open(INPUT, "<$input_file") or die "Can't open \"$input_file\": $!\n";
chomp(my @input = <INPUT>);
close INPUT;

# handle the input file
# read in each record in three lines
my $input_line_number = scalar @input;

# Print a table head
print "sequence_name\tMFEI\tsequence_length\tGC_num\tMFE\n";

for(my $i=0; $i < $input_line_number - 2; $i += 3) {
    my $sequence_name = $input[$i];
    my $sequence = $input[$i + 1];
    my $structure = $input[$i + 2];

    my $sequence_length = length $sequence;
    my $GC_num = &count_GC ($sequence);
    my $MFE = &max_free_energy($structure);

    my $MFEI =( ( $MFE / $sequence_length ) * 100 ) / $GC_num;

    printf "%s\t%.2f\t%d\t%d\t-%.2f\n", $sequence_name, $MFEI, $sequence_length, $GC_num, $MFE;

}

# count_GC 
# Given a nucleotide sequence
# return the number of GC 
sub count_GC {
    my $sequence = shift;
    my $count = 0;
    
    $count = ( $sequence =~ tr/GgCc//);

    return $count;
}


# max_free_energy
# the value of max_free_energy contained in the structure line
# so extract this value use RE
sub max_free_energy {
    my $structure_line = shift;
    my $mfe = 0;

    if( $structure_line =~ / \(-(\d+\.\d+)\)/ ) {
        $mfe = $1;
    }

    return $mfe;
}

exit;
