

ref=/home/xugang/data/reference/tair/bwa_index/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
output=out_ciri

[[ -d $output ]] || mkdir -p $output


for i in `ls output/a3-rRNA|grep log`;do
        echo $i;
        name="${i/.log/}"
        echo $name
done
fq1='output/a3-rRNA/'$name.'1'
fq2='output/a3-rRNA/'$name.'2'
echo $fq1
echo $fq2
echo $name
[[ -d $output/a1-map ]] || mkdir -p $output/a1-map
echo -e "bwa mem $ref $fq1 $fq2 1> $output/a1-map/$name.sam 2> $output/a1-map/$name-pe.log"
bwa mem $ref $fq1 $fq2 1> $output/a1-map/$name.sam

[[ -d $output/a2-ciri ]] || mkdir -p $output/a2-ciri
echo -e "perl /home/app/ciri/CIRI2/CIRI_v2.0.3/CIRI_v2.0.3.pl -I $output/a1-map/$name.sam -O $output/a2-ciri/$name -F $ref"
perl /home/app/ciri/CIRI2/CIRI_v2.0.3/CIRI_v2.0.3.pl -I $output/a1-map/$name.sam -O $output/a2-ciri/$name -F $ref



