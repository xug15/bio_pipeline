open I, "<$ARGV[0]";
#open O, "";

while(<I>){
chomp;
if($_=~/>/){

$name=$_;
$name=~s/>//g;
$hash{$name}='';

}else{
$hash{$name}.=$_;
}

}
if($ARGV[0]=~/\//)
 {
	 #print "$ARGV[0]";
@path=split/\//,$ARGV[0];
#print "@path\n";
#shift @path;
pop @path;
$prex=$path[2];
$path=join '/', @path;
$path.='/';
print "$path$prex\n";
 }else{
 $path='';
 $prex='';
 } 


 foreach(keys(%hash)){
	 open O, ">${path}${prex}$_.fa";
	print O ">$_\n$hash{$_}\n";
	close O;
}


