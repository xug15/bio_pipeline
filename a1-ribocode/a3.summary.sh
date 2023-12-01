outdir=output
patho=`pwd`
#gtf=/home/xugang/data/reference/mouse/gencode.vM25.annotation.clean.gtf
gtf=/home/xugang/data/reference/hg38/Homo_sapiens.GRCh38.100.chr.gtf

[[ -d ${outdir}/a9-summary ]] || mkdir -p ${outdir}/a9-summary

cutadaptstatic(){
cd $patho
cd $outdir/a2-cutadapter

array=($(ls|grep log$))
for i in "${array[@]}";
do
	grep -A 3 'Total reads processed' ${i} > ${i}.txt

done

array=($(ls|grep log.txt$))
head='iterm'

for i in "${array[@]}";
do
	head+=":${i}";

done
echo -e $head > merge.txt
# file with name add .count
# extract the first and second elements.
begin1=${array[0]};
begin2=${array[1]};
# array remove the first and second element.
array2=("${array[@]:2}");
# join the frist and second file.
join -t ':' ${begin1} ${begin2} > merge.tmp
# use the loop to join each file into the merge file.
for i in ${array2[@]};
do
#echo ${i};
join -t ':' merge.tmp ${i} >>merge.tmp2;
mv merge.tmp2 merge.tmp
done
# merge header and
cat merge.txt merge.tmp > merge2.tmp;
# delete the merge.tmp file.
rm merge.tmp merge.txt
# rename the file.
mv merge2.tmp merge.tsv
# replace plates with blanks.
sed -i 's/:/\t/g' merge.tsv
sed -i 's/  //g' merge.tsv
rm *log.txt
cp merge.tsv ../a9-summary/adapter.tsv

}



filterstatic(){
cd $patho
cd $outdir/a3-filter

array=($(ls|grep log$))

head='iterm'

for i in "${array[@]}";
do
        head+=":${i}";

done
echo -e $head > merge.txt
# file with name add .count
# extract the first and second elements.
begin1=${array[0]};
begin2=${array[1]};
# array remove the first and second element.
array2=("${array[@]:2}");
# join the frist and second file.
join -t ':' ${begin1} ${begin2} > merge.tmp
# use the loop to join each file into the merge file.
for i in ${array2[@]};
do
#echo ${i};
join -t ':' merge.tmp ${i} >>merge.tmp2;
mv merge.tmp2 merge.tmp
done
# merge header and
cat merge.txt merge.tmp > merge2.tmp;
# delete the merge.tmp file.
rm merge.tmp merge.txt
# rename the file.
mv merge2.tmp merge.tsv
# replace plates with blanks.
sed -i 's/:/\t/g' merge.tsv
sed -i 's/  //g' merge.tsv

cp merge.tsv ../a9-summary/filter.tsv
}

rRNAf(){
cd $patho
[[ -d ${outdir}/a9-summary ]] || mkdir -p ${outdir}/a9-summary
cd ${outdir}/a5-rmrRNA
array=($(ls|grep err))
head='iterm'
for i in "${array[@]}";
do
	#echo $i;
	head+=":${i}";
done
echo -e $head > merge.txt
# file with name add .count
# extract the first and second elements.
begin1=${array[0]};
begin2=${array[1]};
# array remove the first and second element.
array2=("${array[@]:2}");
# join the frist and second file.
join -t ':' ${begin1} ${begin2} > merge.tmp
# use the loop to join each file into the merge file.
for i in ${array2[@]};
do
#echo ${i};
join -t ':' merge.tmp ${i} >>merge.tmp2;
mv merge.tmp2 merge.tmp
done
# merge header and
cat merge.txt merge.tmp > merge2.tmp;
# delete the merge.tmp file.
rm merge.tmp merge.txt
# rename the file.
mv merge2.tmp rRNA.tsv
# replace plates with blanks.
sed -i 's/:/\t/g' rRNA.tsv
cd -

mv ${outdir}/a5-rmrRNA/rRNA.tsv  ${outdir}/a9-summary/

}


mapf(){
cd $patho
[[ -d ${outdir}/a6-map/b1-summary ]] || mkdir -p ${outdir}/a6-map/b1-summary
rm -rf ${outdir}/a6-map/b1-summary/*
cd ${outdir}/a6-map
for i in `ls|grep .final.out`;
do echo $i
	name=${i/Log.final.out/}
sed -n '9,11'p $i >b1-summary/$name.txt
sed -n '24,27'p $i >> b1-summary/$name.txt
sed -i 's/\t//g' b1-summary/$name.txt
done

cd b1-summary

array=($(ls|grep txt))


#echo ${array[@]}

head='iterm'

for i in "${array[@]}";
do
	#echo $i;
	head+="|${i}";
done

echo -e $head > merge.txt
# file with name add .count
# extract the first and second elements.
begin1=${array[0]};
begin2=${array[1]};
# array remove the first and second element.
array2=("${array[@]:2}");
# join the frist and second file.
join -t '|' ${begin1} ${begin2} > merge.tmp
# use the loop to join each file into the merge file.
for i in ${array2[@]};
do
#echo ${i};
join -t '|' merge.tmp ${i} >>merge.tmp2;
mv merge.tmp2 merge.tmp
done
# merge header and
cat merge.txt merge.tmp > merge2.tmp;
# delete the merge.tmp file.
rm merge.tmp merge.txt
# rename the file.
mv merge2.tmp map.tsv
# replace plates with blanks.
sed -i 's/|/\t/g' map.tsv
mv map.tsv ../../a9-summary/
#rm *txt
cd -

}


statistic(){
cd ${patho}
[[ -d $outdir/a9-summary/b1-length ]] || mkdir -p $outdir/a9-summary/b1-length
[[ -d $outdir/a9-summary/b2-region ]] || mkdir -p $outdir/a9-summary/b2-region

for i in `ls $outdir/a6-map|grep Aligned.sortedByCoord.out.bam`;do
        echo $i;
        name="${i/Aligned.sortedByCoord.out.bam/}";
        echo $name
        echo LengthDistribution -i $outdir/a6-map/$i -o $outdir/a9-summary/b1-length/$name.length.txt  -f bam
	LengthDistribution -i $outdir/a6-map/$i -o $outdir/a9-summary/b1-length/$name.length.txt  -f bam
        echo StatisticReadsOnDNAsContam -i $outdir/a6-map/$i -g $gtf  -o $outdir/a9-summary/b2-region/$name.regin.txt
	StatisticReadsOnDNAsContam -i $outdir/a6-map/$i -g $gtf  -o $outdir/a9-summary/b2-region/$name.regin.txt
done

}
clean(){
cd ${patho}

rm $outdir/a9-summary/b1-length/*txt

}

region_staf(){
cd ${patho}
cd $outdir/a9-summary/b2-region

array=($(ls|grep txt$))
head='iterm'

for i in "${array[@]}";
do
	name=${i/.regin.txt_reads_distribution.txt/}
	head+=":${name}";

done
echo -e $head > merge.txt


# file with name add .count
# extract the first and second elements.
begin1=${array[0]};
begin2=${array[1]};
# array remove the first and second element.
array2=("${array[@]:2}");
# join the frist and second file.
join -t ':' ${begin1} ${begin2} > merge.tmp
# use the loop to join each file into the merge file.
for i in ${array2[@]};
do
#echo ${i};
join -t ':' merge.tmp ${i} >>merge.tmp2;
mv merge.tmp2 merge.tmp
done
# merge header and
cat merge.txt merge.tmp > merge2.tmp;
# delete the merge.tmp file.
rm merge.tmp merge.txt
# rename the file.
mv merge2.tmp merge.tsv
# replace plates with blanks.
sed -i 's/:/\t/g' merge.tsv
sed -i 's/  //g' merge.tsv
cp merge.tsv ../region.tsv
}


report(){
cd ${patho}
cd ${outdir}/a9-summary
[[ -d report ]] || mkdir -p report
echo -e '<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312" />
<meta http-equiv="Content-Language" content="zh-cn" />
</head>
<body>
<h1>Ribosome profiling report</h1>
' > report.html

#echo perl b3.report.table.pl ${outdir}/a9-summary/adapter.tsv ${outdir}/a9-summary/adapter.html.txt
perl ../../a13.report.table.pl adapter.tsv adapter.html.txt
perl ../../a13.report.table.pl filter.tsv filter.html.txt
perl ../../a13.report.table.pl map.tsv map.html.txt
perl ../../a14.rRNA.pl rRNA.tsv rRNA2.tsv
mv rRNA2.tsv rRNA.tsv
perl ../../a13.report.table.pl rRNA.tsv rRNA.html.txt
perl ../../a13.report.table.pl region.tsv region.html.txt
echo -e '<h1>Adapter</h1>' >> report.html
cat adapter.html.txt >> report.html
echo -e '<h1>Low quality reads</h1>' >> report.html
cat filter.html.txt >> report.html
echo -e '<h1>rRNA</h1>' >> report.html
cat rRNA.html.txt >> report.html
echo -e '<h1>Mapping ratio</h1>' >> report.html
cat map.html.txt >> report.html
echo -e '<h1>Mapping region</h1>' >> report.html
cat region.html.txt >> report.html

echo -e '<h1>Length distribution</h1>' >> report.html
for i in `ls b1-length`;do
	echo $i;
	name="${i/.length.txt_reads_length.pdf/}";
	cp b1-length/$i report/
	echo -e "<h2>$name length distribution</h2>" >> report.html
echo -e "<iframe src=\"report/$i\" width=\"100%\" height=\"500px\">
    </iframe>" >> report.html
done;
echo -e '<h1>3nt periodicity</h1>' >> report.html

for i in `ls ../a8-ribocode|grep pdf$`;do
        echo $i;
        name="${i/Aligned.toTranscriptome.out.pdf/}";
        cp ../a8-ribocode/$i report/
        echo -e "<h2>$name 3nt periodicity</h2>" >> report.html
echo -e "<iframe src=\"report/$i\" width=\"100%\" height=\"500px\">
    </iframe>" >> report.html
done;


echo -e '<h1>Read distribution</h1>' >> report.html
for i in `ls b2-region|grep pdf`;do
        echo $i;
        name="${i/.regin.txt/}";
        cp b2-region/$i report/
        echo -e "<h2>$name</h2>" >> report.html
echo -e "<iframe src=\"report/$i\" width=\"100%\" height=\"500px\">
    </iframe>" >> report.html
done;
echo -e "</body></html>" >> report.html
rm *html.txt
}
cutadaptstatic
filterstatic
rRNAf
mapf
statistic
clean
region_staf
report
