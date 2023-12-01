open I, "<$ARGV[0]";
open O, ">$ARGV[0].rc.tsv";
open O2, ">$ARGV[0].h";
$head=<I>;
print O2 "$head";
while(<I>){
chomp;
@data=split "\t",$_;
$id=$data[0].".".$data[1].".".$data[5];
#print "$id\n";
$info1{$id}=$data[0]."\t".$data[1]."\t".$data[2]."\t".$data[3];
if(exists($score{$id})){
$score{$id}+= $data[4];

}else{
$score{$id}= $data[4];
}
$info2{$id}=$data[5]."\t".$data[6]."\t".$data[7]."\t".$data[8];
$methcount=$data[10]*$data[9]/100;
if(exists($meth{$id})){
$meth{$id}+=$methcount;
}else{
$meth{$id}=$methcount;
}
#print "$_\n$methcount\t$meth{$id}\t$score{$id}\n";
}
foreach(keys(%info1)){
	#print "$meth{$_}\t$score{$_}\n";
	$percentage=$meth{$_}/$score{$_}*100;
print O "$info1{$_}\t$score{$_}\t$info2{$_}\t$score{$_}\t$percentage\n";
}
close I;
close O;
close O2;
system("sort -k1,1 -k2,2n ".$ARGV[0].".rc.tsv >".$ARGV[0].".meth.tsv");
system("rm ".$ARGV[0].".rc.tsv");
system("cat ".$ARGV[0].".h ".$ARGV[0].".meth.tsv > " .$ARGV[0].".meth2.tsv && rm ".$ARGV[0].".meth.tsv && rm ".$ARGV[0].".h && mv ".$ARGV[0].".meth2.tsv ".$ARGV[0].".meth.tsv ");



