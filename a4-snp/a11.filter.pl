open D, "<$ARGV[0]";
open O1, ">$ARGV[0].filter.5.tsv";
$head=<D>;
print O1 $head;
while(<D>)
{
chomp;
@data=split "\t",$_;
if($data[5]>0.5)
{
print O1 "$_\n";
}

}

close D;

