open I, "<$ARGV[0]";
open O, ">$ARGV[0].igb.gtf";
while(<I>)
{
chomp;
@data=split/\t/,$_;
$_=~/orf_id "(.*?)"/;
$orfid=$1;
#print "$orfid\n";
@info=split /;/,$data[8];
foreach(@info){
if($_=~/transcript_id/){
$_="transcript_id \"$orfid\"";
}

}
$info=join(";",@info);
#print "$info\n";
$data[8]=$info;

if($data[2]=~/ORF/){
$data[2]='gene';
}
$info=join ("\t",@data);
print O "$info\n";
}


