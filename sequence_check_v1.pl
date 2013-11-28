#!/usr/bin/perl
# given two files, one contain a seq fragment, another 
# contains fasta files, try to check whether the pattern
# of given fragment can be found in the fasta file
#
# format of seq pattern given file
# bantam-5p	2	CTGGTTATTCGTTTGGTTTGAAT
# let-7	3608	TGAGGTAGTTGGTTGTATAGT
# let-7-3p	19	CTGTACAACTTGCTAACTTTC
# 
# format of fasta file
# >t0000001 373847
# TGAGGTAGTAGGTTGTATAGTT
# >t0000002 253329
# TGGAATGTAAAGAAGTATGTAC
#
# 2013/09/03, by wjchen

use strict;
use warnings;
# read in the command line arguments
my $usage = "usage: perl $0 file_to_check fasta_file";
my $input_file = shift || die "$usage\n";
my $fasta_file = shift || die "$usage\n";

#print "Reading the file: \"$fasta_file\" ...";
open(FAS, "<$fasta_file") || die "$!\n";

# handle the fasta sequences
chomp(my @fasta_sequence = <FAS>);
my $num_fas_lines = scalar(@fasta_sequence);
print "\nThere are ", $num_fas_lines/2, " sequences in the file: \"","$fasta_file","\"";
print "\n\n";
close FAS;

my $fasta_sequences_str = join "", @fasta_sequence;
# print $fasta_sequences_str;
#print "Reading these sequences, please wait ...\n\n";
# store the sequences in the hash
#my %fasta_sequences = ( );
#for(my $i=0; $i < $num_fas_lines - 1; $i += 2) {
#    my $sequence_name = $fasta_sequence[$i];
#    my $sequence = $fasta_sequence[$i+1];
#    $fasta_sequences{$sequence_name} = $sequence;
#}

# Parse the input_file and get the sequence
# if can be found in the Fasta file, print to a out.matched.txt
# or print to a out.unmatched.txt
open(MATCHED, ">>out.matched.txt") || die "$!\n";
open(UNMATCHED, ">>out.unmatched.txt") || die "$!\n";

open(INPUT, "<$input_file") || die "$!\n";
my @input_file = <INPUT>;

my $input_lines = scalar(@input_file);
my $c = 0;
my $matched_num = 0;
my $unmatched_num = 0;

print "There are $input_lines lines in file: \"$input_file\" needs to check\n";
foreach (@input_file) {

    # print some status information
    ++$c;
    print "Processing input line $c out of $input_lines\n";

    my $current_line = $_;
    my $seq_pattern = (split /\t/)[2];
    chomp $seq_pattern;
#    my $hits = 0;
#    my @matching_lines = grep /$seq_pattern/, <FAS>;
#    foreach (keys %fasta_sequences){
#        if($fasta_sequences{$_} =~ /$seq_pattern/){
#            $hits++;
#        }
#    }

    if ( $fasta_sequences_str =~ /$seq_pattern/ ) {
        $matched_num++;
        print MATCHED $current_line;
    }else{
        $unmatched_num++;
        print UNMATCHED $current_line;
    }
}

print "\n\nProcess completed, find $matched_num matched lines in \"$fasta_file\", $unmatched_num unmached lines!\n";

close INPUT;
close MATCHED;
close UNMATCHED;


# sub matched {
#     my $pattern = shift;
#     my $hits = 0;
#     # handle the fasta seq input two lines each time
#     for(my $i=0; $i < $num_fas_lines - 1; $i += 2) {
#         print $i,"\n";
#         my $sequence_name = $fasta_sequence[$i];
#         my $sequence = $fasta_sequence[$i+1];
#         print "$sequence_name, $sequence\n";
#         if ($sequence =~ /$pattern/) {
#             $hits++;
#         }
#     }
# 
#     return $hits;
# }
