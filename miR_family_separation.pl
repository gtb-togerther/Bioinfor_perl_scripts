# to put the lines for the same miR family in a single file
# with it's sequence in fasta format for easy manual compare
# 
# try to use hash with Array value data structure
# or say hashes to anonymous array
# 
# 2013/09/10, by wjchen

use strict;
use warnings;

my $usage = "useage: perl $0 inputfile\n";
my $filename = shift || die "$usage";

open(INPUT,"< $filename") || die "$!\n";

my %family_lines = ( );
while (<INPUT>) {
    my $family_name = (split /\t/)[7];
    $family_lines{$family_name} .= $_;
}

foreach my $family_name (keys %family_lines){
    my $lines = $family_lines{$family_name};
    my @lines = split /\n/, $lines;

    my %out = ( );
    foreach (@lines) {
        my ($tag, $read_num, $sequence, $target_name, $target_seq) = (split /\t/)[0,2,3,4,6];
        my $tag_name = $tag . "_" . $read_num;
        $out{$tag_name} = $sequence;
        $out{$target_name} = $target_seq;
    }

    print "Writting $family_name.fas\n";
    open(OUT, ">> $family_name.fas") || die "$!\n";
    foreach (sort keys %out) {
        print OUT ">$_\n$out{$_}\n";
    }
    close OUT;
}

print "\nProcess completed!\n";
exit;



