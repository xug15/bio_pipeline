open I, "<$ARGV[0]";
open O, ">$ARGV[1]";

$head=<I>;
#@head=split //,$_;
$total=<I>;
$total=~s/# //g;
$rRNA=<I>;
$rRNA=~s/# reads with at least one reported alignment/rRNA/g;
$nonrRNA=<I>;
$nonrRNA=~s/# reads that failed to align/non rRNA/g;
print O $head;
print O $total;
print O $rRNA;
print O $nonrRNA;

