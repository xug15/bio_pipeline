open D, "<$ARGV[0]";
open O1, ">$ARGV[0].del.tsv";
open O2, ">$ARGV[0].dep.tsv";
$head=<D>;
print O $head;
while(<D>)
{
	#chomp;
@data=split "\t",$_;
#print "$_\n";

# test D or I
if($data[5]=~/D|I/)
    {
        #print "$_\n";
        $start=$data[3];
        #print "$start\n";
        # test the read map + strand or - strand
            if($data[8]>0|$data[8]<0)
                { # strand+
                # + strand
                #print "+ \t $_\n";
                while(length($data[5])>0)
                {# while read 
                    # read
                $data[5]=~/^((\d+)\w)/;
                $info=$1;
                $step_length=$2;
                #print "$info\t$step_length\n";
                # get the position
                $start=$start+$step_length;
                # test type.
             
                    for(my $i=0;$i<$step_length;$i++)
                    {
                        #print "$i\n";
                        $position=$data[2]."\t".($start-$i);
                        $depth{$position}++;
                    }
                
                if($info=~/D/)
                {
                    #$start=$start-$step_length;
                        # set position name and del type.
                    $position=$data[2]."\t".($start)."\t"."D";
                    #print "$position\n";
                    $hash{$position}++;
                }
                if($info=~/I/)
                {
                     $start=$start-$step_length;
                        # set position name and del type.
                    $position=$data[2]."\t".($start)."\t"."I";
                    #print "$position\n";
                    $hash{$position}++;
                   
                }

                # remove the infor about map status.
                $data[5]=~s/$info//;
                #print "$data[5]\n";
                #$poso=$data[2]."_".$data[3];
                }# while read 
                


                }# strand+

    }# test D or I
        
}# while end
foreach(keys(%hash)){
    print O1 "$_\t$hash{$_}\n";

}
foreach(keys(%depth)){
    print O2 "$_\t$depth{$_}\n";

}

close O2;
close O1;
close D;
system("sort -k1,1 -k2,2n $ARGV[0].del.tsv > $ARGV[0].del.sort.tsv ");
system("sort -k1,1 -k2,2n $ARGV[0].dep.tsv > $ARGV[0].dep.sort.tsv ");



