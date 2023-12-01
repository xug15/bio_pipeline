open D, "<$ARGV[0]";
open O1, ">$ARGV[0].snp.tsv";
open I, "</home/xugang/data/reference/tair/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa";
while(<I>){
    chomp;
    if($_=~/>(\w+)/)
    {
$chr=$1;
    }else{
        $genome{$chr}.=$_;
    }

}
close I;
while(<D>)
{
chomp;
@data=split "\t",$_;
@a=split ':',$data[5];	
@c=split ':',$data[6];
@g=split ':',$data[7];
@t=split ':',$data[8];
# ref=$data[2];

$dep=$data[3];
$pos=$data[1];
$possub=$pos-1;
$ref=substr($genome{$data[0]},$possub,1);
#
if($dep>4){
if($ref=~/A/)
 {
#processing
if(@c[1]>3)
{
    $af=$c[1]/$dep;
print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$c[0]\t$c[1]\t$af\n";
}
if(@t[1]>3)
{
    $af=$t[1]/$dep;
print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$t[0]\t$t[1]\t$af\n";
}
if(@g[1]>3)
{
    $af=$g[1]/$dep;

print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$g[0]\t$g[1]\t$af\n";
}
# processing
 }
#########

if($ref=~/C/)
 {
#processing
if(@a[1]>3)
{
    $af=$a[1]/$dep;

print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$a[0]\t$a[1]\t$af\n";
}
if(@t[1]>3)
{
    $af=$t[1]/$dep;

print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$t[0]\t$t[1]\t$af\n";
}
if(@g[1]>3)
{
    $af=$g[1]/$dep;

print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$g[0]\t$g[1]\t$af\n";
}
# processing
 }
 ###

 if($ref=~/G/)
 {
    

#processing
if(@c[1]>3)
{
    $af=$c[1]/$dep;
print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$c[0]\t$c[1]\t$af\n";
}
if(@t[1]>3)
{
    $af=$t[1]/$dep;
print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$t[0]\t$t[1]\t$af\n";
}
if(@a[1]>3)
{
    $af=$a[1]/$dep;
print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$a[0]\t$a[1]\t$af\n";
}
# processing
 }
 if($ref=~/T/)
 {
#processing
if(@c[1]>3)
{
    $af=$c[1]/$dep;
print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$c[0]\t$c[1]\t$af\n";
}
if(@a[1]>3)
{
    $af=$a[1]/$dep;
print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$a[0]\t$a[1]\t$af\n";
}
if(@g[1]>3)
{
    $af=$g[1]/$dep;
print O1 "$data[0]\t$pos\t$ref\t$data[3]\t$g[0]\t$g[1]\t$af\n";
}
# processing
 }
 ###


}

}

close D;

