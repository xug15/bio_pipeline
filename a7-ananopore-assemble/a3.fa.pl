open I, "<$ARGV[0]";
open O, ">$ARGV[0].target.fa";
open I2, "<$ARGV[1]";
while(<I>){
if($_=~/>/){
$hash{$_}='';
$name=$_;
}else{
$hash{$name}.=$_;
}

}
while(<I2>){
if($_=~/^#/){
	#print $_;
}else{
	#print $_;
@data=split "\t",$_;
push @names,$data[0];
}

}

foreach(keys(%hash)){
	$hash=$_;
	#print "$hash\n";
	#print "@names\n";
	foreach(@names){
	if($hash=~/$_/){
print O "$hash";
print O "$hash{$hash}";
	
	}
	}
}

