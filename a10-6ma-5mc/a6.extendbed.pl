open I, "<$ARGV[0]";
open O, ">$ARGV[0].f.bed";
while(<I>)
{
chomp;
@data=split/\t/,$_;
if($data[1]>100)
	{
		#print O "$_\n";
	$data[1]=$data[1]-20;
	
	}else{
	$data[1]=1;
	}
if($data[2]>100)
        {
		#print O "$_\n";
        $data[2]=$data[2]+20;
	
	
	}else{
	$data[2]=+20;
	
	}
$info=join "\t", @data;
print O "$info\n";
}
close O;
close I;




