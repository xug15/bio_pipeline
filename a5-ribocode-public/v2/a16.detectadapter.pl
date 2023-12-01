use List::Util 'max';
open I, "<$ARGV[0]";
open O1, ">$ARGV[0].kp";
open O2, ">$ARGV[0].rm";

while(<I>){
chomp;
$_=~s/\s\s+/\t/g;
#@data=split/\t/, $_;
@data=split/:/,$_;
@file=split/\//,$data[0];
print "$file[$#file]\t$data[2]\n";
print "$_\n";
$file[$#file]=~/log.(\w+).(\d+).log/;
print "$1\t$2\n";
$name=$1;
$id=$2;
$data[2]=~/\((.*?)%\)/;
$percent=$1;
#print "$name\t$id\t$percent\n";
$hash{$id}=$percent;
}

my $max = max(values %hash);
my %hash_max = map { $hash{$_}==$max ? ($_, $max) : () } keys %hash;

foreach(keys(%hash_max)){
print "$_\t$hash_max{$_}\n";
$max_index=$_;
}

foreach(keys(%hash)){
if($_ eq $max_index)
{
print O1 "${name}_trimmed.$_.fastq\n";
}else{
print O2 "${name}_trimmed.$_.fastq\n";
}
}

