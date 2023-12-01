open I, "<$ARGV[0]";
open I2, "<$ARGV[1]";
open O, ">$ARGV[1].2.csv";

while(<I>){
chomp;
@data=split/\t/, $_;

$_=~/gene_id.\"(.*?)\";/;
$id=$1;
$_=~/gene_name.\"(.*?)\";/;
$name=$1;
$gene{$id}=$name;
}
close I;
$head=<I2>;
@head=split/,/,$head;
splice (@head,1,0,'name');
$head=join(',',@head);
print O "$head";
while(<I2>){
chomp;
@data=split/,/,$_;
$na=$data[0];
$data[0]=~s/\.\d+$//g;
splice (@data,1,0,$gene{$na});
$head=join(',',@data);
print O "$head\n";


}


