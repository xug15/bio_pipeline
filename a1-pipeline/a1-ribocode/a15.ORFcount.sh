output=output
gtf=$output/a9-ribocode-result/ribocode.gtf
orfcountf(){
[ -d $output/a13-ORFcount ] || mkdir -p $output/a13-ORFcount
for i in `ls $output/a6-map|grep sortedByCoord.out.bam$`;do
	echo $i;
name="${i/Aligned.sortedByCoord.out.bam/}";
echo $name;
echo -e "ORFcount -g $gtf -r $output/a6-map/$i -f 1 -l 1 -e 10 -m 25 -M 135 -o $output/a13-ORFcount/$name.count"
ORFcount -g $gtf -r $output/a6-map/$i -f 1 -l 1 -e 10 -m 25 -M 135 -o $output/a13-ORFcount/$name.count
done
}

mergef(){
cd $output/a13-ORFcount
array=($(ls|grep count|grep -v merge.tsv))
head='gene'
for i in ${array[@]};
do
name="${i/.count/}";
echo $name;
head="$head $name";
done
echo $head > head.txt;
# file with name add .count
# extract the first and second elements.
begin1=${array[0]};
begin2=${array[1]};
# array remove the first and second element.
array2=("${array[@]:2}");
# join the frist and second file.
join ${begin1} ${begin2} > merge.tmp
# use the loop to join each file into the merge file.
for i in ${array2[@]};
do
#echo ${i};
join merge.tmp ${i} >>merge.tmp2;
mv merge.tmp2 merge.tmp
done
cat head.txt merge.tmp > merge.tmp2
mv merge.tmp2 merge.tmp
sed -i 's/ \+/\t/g' merge.tmp
mv merge.tmp merge.tsv
rm head.txt
}

getlncORF(){

grep ncRNA output/a9-ribocode-result/ribocode.txt| cut -f 1 | sort -u > output/a9-ribocode-result/ncRNA_ORF.txt
head -n 1 $output/a13-ORFcount/merge_cpm.csv > $output/a13-ORFcount/lncRNA_ORF_cpm.csv;
for i in `cat output/a9-ribocode-result/ncRNA_ORF.txt`;do
	echo $i;
grep $i $output/a13-ORFcount/merge_cpm.csv >> $output/a13-ORFcount/lncRNA_ORF_cpm.csv;
done
}

orfcountf
mergef
Rscript a16.ORFcpm.R
getlncORF


