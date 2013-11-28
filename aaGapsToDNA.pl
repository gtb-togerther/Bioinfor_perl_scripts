#!/usr/bin/perl

my $usage="Usage: $0 [-t geneticCodeTbl] alignedAASeq dnaSeq";

use Getopt::Std;
getopts('ht:') || die "$usage\n";

if (defined($opt_h)) {
    die "$usage\n";
}

my %aminoAcid;
my %aaSeq;

die "$usage\n" if (@ARGV != 2);

my ($aaFile, $dnaFile) = @ARGV;

# initialize the hash %aminoAcid
if (defined($opt_t)) {  # -t genCodeTbl was given
    open (CODE_TBL, "<$opt_t") || die "ERROR: Can't open $opt_t\n";
    InitGenCode(*CODE_TBL);
    close (CODE_TBL);
} else {                # use the default standard table supplied at the end
    InitGenCode(*DATA);
}

# for debugging
#while (($k, $v) = each %aminoAcid) { print "**$k** => --$v--\n";};

# initialize the aaSeq
ReadInAlignedAA($aaFile);

# for debugging
# while (($k, $v) = each %aaSeq) { print "**$k** => ++$v++\n"; };

ProcessDna($dnaFile);

exit (0);

# Initialize the hashTbl, %aminoAcid{codon},
# by reading in the FH given as the argument
sub InitGenCode {  # take a typeglob of FILEHANDLE as an argument, e.g. *INFILE
    local *FH = shift;
    my $type;
    my @aa, @b1, @b2, @b3;
    my $i;
    my $codon;

    while (<FH>) {
	chomp;
	s/\s+$//;

	if (/^\s*(.*)\s*=/) {  # extract the type of the line
	    $type = $1;
	} else {
	    next;
	}

	s/^\s*(.*)=\s*//;      # get rid of characters before "="

	if ($type =~ /AAs/) {
	    @aa = split (//);
	} elsif ($type =~ /Base1/) {
	    @b1 = split (//);
	} elsif ($type =~ /Base2/) {
	    @b2 = split (//);
	} elsif ($type =~ /Base3/) {
	    @b3 = split (//);
	} else {
	    next;
	}
    }

    if (@aa + @b1 + @b2 + @b3 != 64 * 4) {  # checking the length of arrays
	die "ERROR, Please check the genetic code table is well formatted\n";
    }

    # making a hash table, %aminoAcid, Note all upper cases are used
    for ($i = 0; $i < 64; $i++) {
	$codon = uc ($b1[$i] . $b2[$i] . $b3[$i] );
	$aminoAcid{$codon} = uc $aa[$i];
    }
}

sub ReadInAlignedAA {  # takes an arg; name of a file from which data are read
    my $infile = shift;
    my @line;

    open (INFILE, $infile) || die "Can't open $infile\n";

    while (<INFILE>) {
	chomp;
	if (/^>/) {  # name line in fasta format
	    s/^>\s*//;
	    @line = split (/\|/);     # note it takes only the name before |
	    $line[0] =~ s/\s+$//;
	} else {
	    s/^\s+//;
	    s/\s+$//;
	    next if (/^$/);  # skip empty line
	    $aaSeq{$line[0]} = $aaSeq{$line[0]} . $_;
	}
    }

    close(INFILE);
}

sub ProcessDna {
    my $file = shift;
    my @line;
    my $dnaSeq = "";
    my $alignedDna;

    open (INFILE, "<$file") || die "ERROR: Can't open $file\n";

    while(<INFILE>) {
	chomp;
	if (/^>/) {
	    PrintSeq($aaSeq{$name}, $dnaSeq, $name); # align dna and print it
	    print "$_\n";
	    s/^\s+//;
	    @line = split (/\|/);
	    $line[0] =~ s/\s+$//; $line[0] =~ s/^>\s*//;
	    $name = $line[0];
	    $dnaSeq = "";
	} else {
	    s/^\s+//; s/\s+$//;
	    $dnaSeq = $dnaSeq . $_;
	}
    }
    PrintSeq($aaSeq{$name}, $dnaSeq, $name); # take care of the last line
    close (INFILE);
}

sub PrintSeq {
    my ($aaSeqString, $dnaSeqString, $name) = @_;
    
    if ($dnaSeqString ne "") {
	my $alignedDna = InsertGap($aaSeqString, $dnaSeqString, $name);
	if ($alignedDna =~ /\d+/) {
	    print STDERR "ERROR: $alignedDna-th amino acid of ",
	    "$name does not match the DNA seq.\n";
	    die "Please correct the problem in $aaFile or $dnaFile\n";
	}
	print "$alignedDna\n";
    }

}

sub InsertGap {
    my ($aaSeqString, $dnaSeqString, $name) = @_;

    my @aaSeqArray = split //, $aaSeqString;
    my @dnaSeqArray = split //, $dnaSeqString;

    my $i;
    my $alignedSeq = "";
    my $thisCodon, $thisCodonCopy;

    for ($i = 0; $i < @aaSeqArray; $i++) {
	if ($aaSeqArray[$i] eq "-") {
	    $alignedSeq = $alignedSeq . "---";
	    next;
	} else {
	    $thisCodonCopy = join('', splice @dnaSeqArray, 0, 3);
	    $thisCodon = uc ($thisCodonCopy);
	    $thisCodon =~ s/U/T/g;                 # converting RNA to DNA

	    # checking to see the dna triplet matchs the aa.
	    if (uc($aaSeqArray[$i]) eq 'X') {
		warn "WARN: aa sequence of \'$name\' contains X\n";
	    } elsif(uc($aaSeqArray[$i]) ne $aminoAcid{$thisCodon}) {
		# If the very last base of the DNA sequence is missing,
		# one may still be able to determine the last aa.
		# e.g. If $thisCodon == "GG", then we know it corresponds to G.
		
		# CheckLastBase returns 1 when 2 bases are enough to determine
		# the amino acid ambiguously.
		if (scalar(split(//,$thisCodon)) != 2 || # checking the length
		    CheckLastBase($thisCodon, $aaSeqArray[$i]) != 1) {
			return ($i+1);        # mismatch bet the codon and aa
		    }
	    }
	    $alignedSeq = $alignedSeq . $thisCodonCopy;
	}
    }

    if (@dnaSeqArray != 0) {
	warn "The length of dna seq ($name) is longer than aa seq by " . 
	    scalar(@dnaSeqArray) . " bases.\n";
    }

    return $alignedSeq;
}

sub CheckLastBase {
    my ($twoDNA, $aa) = @_;
    if ($aminoAcid{$twoDNA . "T"} eq $aa && $aminoAcid{$twoDNA . "C"} eq $aa &&
	$aminoAcid{$twoDNA . "A"} eq $aa && $aminoAcid{$twoDNA . "G"} eq $aa) {
	return 1;    # returns 1 if the third base doesn't matter
    }
    return 0;        # returns 0 if two bases are NOT enough to ensure the AA
}

# The Standard Code (transl_table=1) from NCBI
# http://www3.ncbi.nlm.nih.gov/htbin-post/Taxonomy/wprintgc?mode=c#SG1
__DATA__
  AAs  = FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG
Starts = ---M---------------M---------------M----------------------------
Base1  = TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG
Base2  = TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG
Base3  = TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG
