#!/usr/bin/perl -w

my $usage="\nUsage: $0 [-hrg] fastaFileName1 fastaFileName2 ...\n".
    "  -h: help\n".
    "  -g: remove gaps '-' from the sequence\n".
    "Concatenate FASTA sequences from several files.  If multiple files are \n".
    "given, sequences in all files are concatenated.\n";

our($opt_h, $opt_g, $opt_r);

use Bio::SeqIO;

use Getopt::Std;
getopts('hgr') || die "$usage\n";
die "$usage\n" if (defined($opt_h));

my $format = "fasta";
my @seqArr = ();

die "ERROR: give at least two fasta files\n$usage\n" unless (@ARGV >= 2);
my $numFiles = scalar(@ARGV);

while (my $file = shift) {
    my $seqio_obj = Bio::SeqIO->new(-file => $file, -format => $format);
    my @arrFromThisFile = ();
    while (my $seq = $seqio_obj->next_seq()) {
	push(@arrFromThisFile, $seq);
	my $na = $seq->id();
    }

#    if (defined($opt_r)) {
#	@arrFromThisFile = sort { - ($a->id() cmp $b->id()) } @arrFromThisFile;
#    } else {
#	@arrFromThisFile = sort { $a->id() cmp $b->id() } @arrFromThisFile;
#    }

    push @seqArr, \@arrFromThisFile;
}

my @numSeqArr = ();  # number of sequences in each file
my @maxSeqLenArr = (); # max lengths of sequences for each file
for my $fileNum (0..($numFiles -1)) {
    push @numSeqArr, scalar(@{$seqArr[$fileNum]});

    push @maxSeqLenArr, MaxSeqLen(@{$seqArr[$fileNum]});

#    for my $j (0..5) {
#	my $s = $seqArr[$fileNum][$j]->id();
#	print "$k $j: $s\n";
#    }

}

# Can do more fancy stuff around here, but this is ok for now

my @result = @{$seqArr[0]};  # take the seq from the first file
foreach my $fileNum (1..($numFiles-1)) {
    foreach my $s (0..($numSeqArr[$fileNum] - 1)) {
	my $thisSeq = $result[$s]->seq() . $seqArr[$fileNum][$s]->seq();
	$result[$s]->seq($thisSeq) ;
    } 
}


my $seqOut = Bio::SeqIO->new(-fs => \*STDOUT, -format => $format);
foreach my $s (@result) {
    if(defined($opt_g)) {
	my $tmp = $s->seq();
	$tmp =~ s/-//g;
	$s->seq($tmp);
    }
    $seqOut->write_seq($s);
}


#print (join " ", @maxSeqLenArr, "\n");

exit;

sub MaxSeqLen {
    my $max = -1;
    foreach my $s (@_) {
	my $len = $s->length;
	$max = ($len > $max) ? $len: $max;
    }
    return $max;
}





