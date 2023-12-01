open D1, "<mouse_ensemble_name.txt";


while(<D1>)
{
chomp;
@data=split /\t/,$_;

$hash{$data[0]}=$data[1];
#print "$data[0]\t$data[1]\n";
$data[0]=~/(\w+)\./g;
$hashg{$1}=$data[1];
#print "$1\t$data[1]\n";
}
close D1;
open D2, "<$ARGV[0]";
open O2, ">$ARGV[0].g.tsv";
$head=<D2>;
print O2 "$head";

while(<D2>)
{
    #print $_;
    chomp;
@data=split/\t/,$_;
$data[5]=~s/\s+//g;
@ensem=split/,/,$data[5];
#print "@data[5]\n";
@gene=();
foreach(@ensem){
$name=$_;
#print "$name\n";

if(exists($hashg{$name})){
    #print "$name\t$hashg{$name}\n";
    push @gene, $hashg{$name};

}
#print "@gene";
    $info=join (",", @gene);
    #print "$info\n";

}

$data[5]=$info;
$info2=join ("\t",@data);
#print "$info2\n";
print O2 "$info2\n";
}








