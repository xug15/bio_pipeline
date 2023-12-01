open D, "<$ARGV[0]";
open O1, ">$ARGV[0].filter.3.7.tsv";
$head=<D>;
print O1 $head;
while(<D>)
{
chomp;
@data=split "\t",$_;
if($data[6]>0.7)
{
print O1 "$_\n";
}

}

close D;

