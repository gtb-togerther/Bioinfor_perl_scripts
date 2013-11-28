#! D:\programming\Perl\bin\perl -w

use strict;
use Bio::Perl;
# this script will only work with an internet connection
# on the computer it is run on
# 到swissprot 数据库里拿到人的ROA1蛋白质的序列
my $seq_object = get_sequence('swissprot',"ROA1_HUMAN");
write_sequence(">roa1.fasta",'fasta',$seq_object);
exit;

