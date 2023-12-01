open I,  "<$ARGV[0]";
open I2, "<$ARGV[1]";
open O,  ">tmp2";
$name1=<I>;
chomp($name1);
while(<I>)
{
chomp;
@data=split /\t/,$_;
$name=$data[0].$data[1].$data[2];
$parent{$name}=$_;
#print "$_\n";
}
$name2=<I2>;
@name2=split /\t/,$name2;
shift @name2;
shift @name2;
shift @name2;
$name2_fix=join "\t",@name2;
print O "$name1\t$name2_fix";
while(<I2>)
{
chomp;
@data=split /\t/,$_;
$name=$data[0].$data[1].$data[2];
shift @data;
shift @data;
shift @data;
$info=join "\t", @data;
$hash{$name}=$info;
#print "$_\n";
}
close I;
close I2;
foreach(keys(%parent)){
if(exists($hash{$_}))
 {
 print O "$parent{$_}\t$hash{$_}\n";
 }
}
close O;



