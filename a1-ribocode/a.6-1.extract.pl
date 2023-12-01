open I, "<$ARGV[0]";
open O, ">$ARGV[0].tsv";
$outname=$ARGV[0];
$outname=~s/.out.bam//g;
open I2, "<t_data.ctab";
open O2, ">$outname.trans.tsv";
print O "Trans_id\tGene_id\tname\t${outname}_cov\t${outname}_FPKM\t${outname}_TPM\n";
print O2 "Trans_id\tGene_id\tname\t${outname}_cov\t${outname}_FPKM\t${outname}_TPM\n";
while(<I>){
chomp;
@data=split/\t/,$_;
if($data[2]=~/transcript/ & $_=~/reference_id/)
 {
	 #print "$_\n";
$_=~/reference_id "(.*?)"; ref_gene_id "(.*?)"; ref_gene_name "(.*?)"; cov "(.*?)"; FPKM "(.*?)"; TPM "(.*?)";/;

$name=$1;
$seq="$1\t$2\t$3\t$4\t$5\t$6\n";
#print "$name\n$seq";
print O "$1\t$2\t$3\t$4\t$5\t$6\n";
#print "$name\n$seq";
$hash{$name}=$seq;
 }
}
close O;
close I;
while(<I2>){
chomp;
@data=split/\t/,$_;
#print "$data[5]\n";
if($data[5]=~/t_name/){
next;
}
if(exists($hash{$data[5]}))
{
print O2 "$hash{$data[5]}";
#print "$hash{$data[5]}";
}else{
print O2  "$data[5]\t$data[8]\t$data[9]\t$data[10]\t$data[11]\t0\n";
}
}


