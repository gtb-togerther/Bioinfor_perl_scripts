#!/usr/bin/perl

# get the accession numbers from FASTA file

while (<>){
    chomp;
    next unless (/^>/);
    s/^>\s*//;

    my @line = split /\s+/;

    my $first = shift (@line);
    my @numbers = split /\|/, $first;
    
    $accNum = $numbers[3];
    $accNum =~ s/\.\d+$//;  # remove version numbers

    print "$accNum\t\t# " . $_ . "\n";
}
