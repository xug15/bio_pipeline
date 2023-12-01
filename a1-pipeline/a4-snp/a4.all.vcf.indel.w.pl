open D, "<$ARGV[0]";
open O, ">$ARGV[0].indel.tsv";
$head=<D>;
print O $head;
while(<D>)
{
	#chomp;
@data=split "\t",$_;

if($_=~/INDEL/)
{
$data[7]=~/IDV=(\d+);/;
$idv=$1;
$data[7]=~/DP=(\d+);/;
$dp=$1+1;
if($dp>10 & $idv/$dp>0.3)
{

print O $_;
}
}
}

close O;
close D;


