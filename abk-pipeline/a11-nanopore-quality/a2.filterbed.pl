open I, "<$ARGV[0]";
open O, ">$ARGV[0].f.bed";
while(<I>)
{
chomp;
@data=split/\t/,$_;
if($data[10]>0)
	{
	print O "$_\n";
	}

}
close O;
close I;




