open I, "<$ARGV[0]";
open O, ">$ARGV[0].tsv";
print O "gene\ttranscript\tname\tcov\tFPKM\tTPM\n";

while(<I>)
{
chomp;
@data=split /\t/,$_;
if($data[2]=~/transcript/){
$data[8]=~/gene_id "(.*?)";/;
$data[8]=~/transcript_id "(.*?)";/;
$data[8]=~/reference_id "(.*?)";/;
$tr=$1;
$data[8]=~/ref_gene_id "(.*?)";/;
$id=$1;
$data[8]=~/ref_gene_name "(.*?)";/;
$name=$1;
$data[8]=~/cov "(.*?)";/;
$cov=$1;
$data[8]=~/FPKM "(.*?)";/;
$fpkm=$1;
$data[8]=~/TPM "(.*?)";/;
$tpm=$1;
if($id=~/^STRG/){

}else{

print O "$id\t$tr\t$name\t$cov\t$fpkm\t$tpm\n";
}
}
}
close D1;
