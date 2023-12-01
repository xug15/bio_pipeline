use List::Util qw(min max);

open I2, "<$ARGV[1]";
while(<I2>)
{
chomp;
@data=split /\t/,$_;
@sample=split/\//,$data[1];
#print "@sample\n$sample[$#sample]\n";
$sample[$#sample]=~/(.*?)Aligned.toTranscript/;
$hash{$1}=$data[3]."\t".$data[4];
print "$1\t$data[3]\t$data[4]\n";
}

#print %hash;



open I, "<$ARGV[0]";


$filename=$ARGV[0];

$filename=~/EN\w+\.(.*?)\.sam\.sam/;
$sample=$1;

print "$filename\n$sample\n";
if(length($sample)<1){

	die( "\$!, Don't exists $sample psite file\n\n");
}
if(exists($hash{$sample}))
{
print "sample:$sample\n";
@info=split /\t/,$hash{$sample};

@len=split /,/,$info[0];
@psite=split /,/,$info[1];

for($i=0;$i<=$#len;$i++)
{
    #print "$i\t$len[$i]\t$psite[$i]\n";
$dis{$len[$i]}=$psite[$i];
}

}else{
    die( "\$!, Don't exists $sample psite file\n\n");    
}

#print %dis;

open O, ">$ARGV[0].psite.tsv";
open O2, ">$ARGV[0].clean.tsv";

while(<I>){
chomp;
@data=split /\t/,$_;
$data[5]=~/(\d+)M/g;
$len=$1;
$pos=$data[3];
$dis=$len;
        if(exists($dis{$len}))
            {
            $dis=$dis{$len};

            $psite=$dis+$pos;
            $hash2{$psite}++;
            }
}




print O "position\tnumber\n";
print O2 "position\tnumber\n";
$maxb=max(keys(%hash2));
foreach(keys(%hash2)){
print "$_\n";
}
print "\nMax:$maxb\n";

for (my $i=1;$i<$maxb+1;$i++){
if(exists($hash2{$i})){
print O "$i\t$hash2{$i}\n";
print O2 "$i\t$hash2{$i}\n";
}else{
print O "$i\t0\n";
}

}

close O;
close I;
system("sort -k1,1n ".$ARGV[0].".psite.tsv > ".$ARGV[0].".sort.tsv");
system("rm ".$ARGV[0].".psite.tsv");



