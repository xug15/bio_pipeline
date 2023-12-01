open I2, "<$ARGV[1]";
open I1, "<$ARGV[0]";

my (%hash1,$hash2);
<I2>;
while(<I2>)
{
chomp;
$info=$_;
while(length($info)<1){
    $info=<I2>;
    
}
@data=split/\t/,$info;
$count{$data[0]}=$data[1];
}
<I1>;
while(<I1>)
{
chomp;
$info=$_;
while(length($info)<1){
    $info=<I1>;
    
}
@data=split/\t/,$info;
#$count{$data[0]}=$data[1];
if(exists($count{$data[0]})){
$count{$data[0]}+=$data[1];
}else{
$count{$data[0]}=$data[1];

}

}
open O, ">$ARGV[0].tmp";
print O "position\tnumber\n";
foreach(keys(%count))
{
    
    if($_=~/\w+/){
    print O "$_\t$count{$_}\n";
    }
    
    
}
close O;
system("sort -k1,1n $ARGV[0].tmp>$ARGV[0].sort.tsv");
system("rm $ARGV[0].tmp");
