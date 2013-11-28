# remove the redundant sequences base on the seq
# try to use the sequence as the hash name to keep uniq
#     perl uniq-seq.pl input-seq.file
#
# 20131021, by wjchen

use strict;
use warnings;

use Bio::SeqIO;
use Bio::Seq;

my $input_file = shift or die "perl $0 input_file\n";

my $in = Bio::SeqIO->new(-file => $input_file, -format => 'Fasta');

my %uniq_sequences = ( );

while( my $seq = $in->next_seq() ){
    my $sequence = $seq->seq();
    my $seq_name = $seq->id;
    $uniq_sequences{$sequence} = $seq_name;
}

# Output
foreach (sort keys %uniq_sequences) {
    print ">", $uniq_sequences{$_}, "\n", "$_", "\n";
}
