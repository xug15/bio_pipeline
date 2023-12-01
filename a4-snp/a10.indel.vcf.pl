open D, "<$ARGV[0]";
open D2, "<$ARGV[1]";
open O1, ">$ARGV[0].ratio.tsv";


while(<D2>)
{
	chomp;
@data=split "\t",$_;
$_=~/DP=(\d+)/;
$dp=$1;
#print "$data[0]\t$data[1]\t$dp\n";
$position=$data[0]."\t".$data[1];
$position{$position}=$dp;
}

close D2;
print O1 "chr\tpos\ttype\tnum_indl\tdepth\tratio\n";
while(<D>)
{
chomp;
@data=split "\t",$_;
$position=$data[0]."\t".$data[1];
if(exists($position{$position})){
    $ratio=$data[3]/($position{$position}+1);
    print O1 "$_\t$position{$position}\t$ratio\n";
}
}

