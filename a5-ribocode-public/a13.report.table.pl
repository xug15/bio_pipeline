open I, "<$ARGV[0]";
open O, ">$ARGV[1]";
print O "<table border='1'>\n\t<tr>\n";

$head=<I>;
chomp($head);
$head=~s/\.txt//g;
$head=~s/\.log//g;
@head=split "\t",$head;
for(my $i=0;$i<=$#head;$i++){
print O "\t<th>$head[$i]</th>\n";
}
print O "\t</tr>\n";

while(<I>){
chomp;
print O "<tr>\n";

$_=~s/\.txt//g;
$_=~s/\.log//g;
@head=split "\t",$_;
for(my $i=0;$i<=$#head;$i++){
print O "\t<th>$head[$i]</th>\n";
}

print O "</tr>\n";
}



print O "</table>\n";

