open D, "<$ARGV[0]";
open O, ">$ARGV[0].indel.plotdata.tsv";
$head=<D>;
print O "chrom\tpos\tRef\tAlt\tdeep\tindel\tfq\n";
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
if($dp>10 & $idv/$dp>0.1)
{
	#	print $_;
$_=~/DP=(\w+);/;
$dp=$1;
$_=~/IDV=(\w+);/;
$iv=$1;
$_=~/IMF=(.*?);/;
$fq=$1;
print O "$data[0]\t$data[1]\t$data[3]\t$data[4]\t$dp\t$iv\t$fq\n";
}
}
}

close O;
close D;


