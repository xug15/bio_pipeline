open D, "<$ARGV[0]";
open O, ">$ARGV[0].0.8.tsv";
$head=<D>;
print O $head;
while(<D>)
{
	#chomp;
@data=split "\t",$_;
if($data[5]>0.7)
{
print O $_;
}
}

close O;
close D;


