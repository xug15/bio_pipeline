open D1, "<$ARGV[0]";
open D2, "<$ARGV[1]";
open O1, ">$ARGV[1].uniq.tsv";
while(<D1>)
{
chomp;
@data=split "\t",$_;
$key=$data[0]."_".$data[1];
$hash{$key}=$_;
#print "$key\t$_\n";
}
close D1;
$head= <D2>;
print O1 "$head";
while(<D2>){
chomp;
@data=split "\t",$_;
$key=$data[0]."_".$data[1];
if(exists($hash{$key})){

}else{
print O1 "$_\n";
}
}


