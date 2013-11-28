# get_seq_from_genome_version2.pl
# modified version, to reverse complement the target sequence, if needed
# to get corresponding sequences from genome (-70+,+70)
# 2013/07/05, by wjchen
#
# 2013/0725, modified by wjchen to use Bio::DB::Fasta to deal with large
# genome databases issue;

use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;
use Bio::DB::Fasta;


my $usage = "usage: perl $0 genome_file blast_out_file\n";
die $usage if (scalar(@ARGV) < 2 );

my ($genome_file, $blast_out_file) = @ARGV;

###################################################################
# use Bio::DB::Fasta to create a genome database
# #################################################################

my $db = Bio::DB::Fasta->new($genome_file);


#######################
# Handling the Blast m8 file
# # separated by \t, 12 fields
# $query_name   $subject_name   $identity   $align_length   $mismatch   $gap
# $query_start  $query_end  $subject_start  $subject_end    $expectation
# $score
#######################

unless( open(BLASTM8, $blast_out_file) ) {
    print STDERR "Cannot open file \"$blast_out_file\"\n\n";
    exit;
}

while( <BLASTM8> ) {
    chomp;
    my ($query_name, $subject_name, $align_length, $mismatch, $subject_start, $subject_end)
      = (split /\t/)[0, 1, 3, 5, 8, 9];
#    print "$query_name is aligned to $subject_name $subject_start to $subject_end\n";

    # mismatch <= 3 and align_length should greater than 18
    # but all record in the file satisfy this criteria
    if($align_length<18 && $mismatch>3) {
        next;
    }

    my $revcom = 0; # a flag to indicate the revers complement cases;
    if ($subject_start > $subject_end) {
        ($subject_start, $subject_end) = ($subject_end, $subject_start);
        $revcom = 1;
#        print $query_name, " ", $subject_name, "\n";
    }

#    print "$subject_name\t$subject_start\t$subject_end\n";

    my $miR_genome_seq = $db->seq($subject_name, $subject_start - 10, $subject_end + 160);
    if($revcom ==0) {
        print ">$query_name", "_", "$subject_name", "_", "$align_length", "\n";
        print "$miR_genome_seq\n";
    } else {
        print ">$query_name", "_", "$subject_name", "_", "$align_length", '_revcom', "\n";
        print &revcom($miR_genome_seq), "\n";
    }

}



##############################################33
# revcom 
#
# A subroutine to compute the reverse complement of DNA sequence

sub revcom {

    my($dna) = @_;

    # First reverse the sequence
    my $revcom = reverse $dna;

    # Next, complement the sequence, dealing with upper and lower case
    # A->T, T->A, C->G, G->C
    $revcom =~ tr/ACGTacgt/TGCAtgca/;

    return $revcom;
}
