outdir=outdir

[[ -d ${outdir}/b1-sam ]] || mkdir -p ${outdir}/b1-sam


b1sam(){
for i in `ls|grep Aligned.toTranscriptome.out.bam`;
do echo $i;
	samtools view $i > ${outdir}/b1-sam/$i.sam
done
}
b1sam


b2rename()
{
#cd ${outdir}/b1-sam
for i in `ls ${outdir}/b1-sam|grep sam`;do 
	echo $i;
echo "perl a8.rename.pl ${outdir}/b1-sam/$i "
perl a8.rename.pl ${outdir}/b1-sam/$i
done
#cd -
}
b2rename

b3extract(){
name=$1
[[ -d ${outdir}/b2-trans ]] || mkdir -p ${outdir}/b2-trans
for i in `ls ${outdir}/b1-sam|grep sam$`;do 
grep ${name}  ${outdir}/b1-sam/$i > ${outdir}/b2-trans/${name}.${i}.sam
echo $i;
done

}

#b3extract ENST00000619449

b4psite(){
name=$1
psite=$2
[[ -d ${outdir}/b3-psite/b1-clean ]] || mkdir -p ${outdir}/b3-psite/b1-clean
#ls ${outdir}/b2-trans|grep sam|grep $name
echo $name
for i in `ls ${outdir}/b2-trans | grep sam$| grep ${name}`;do
	echo " $i";
echo -e "perl a5.psite.up.pl ${outdir}/b2-trans/$i $psite"
perl a5.psite.up.pl ${outdir}/b2-trans/$i $psite
mv ${outdir}/b2-trans/${i}.clean.tsv ${outdir}/b3-psite/b1-clean
mv ${outdir}/b2-trans/${i}.sort.tsv ${outdir}/b3-psite
done
}
#b4psite ENST00000619449 total.txt

b5rplot(){
name=$1
begin=$2
end=$3
[[ -d ${outdir}/b4-pdf/$name ]] || mkdir -p ${outdir}/b4-pdf/$name
for i in `ls ${outdir}/b3-psite |grep tsv$|grep $name`;do 
	echo ${i};
	echo Rscript a3.rplot.R ${outdir}/b3-psite/${i} ${begin} ${end}
	Rscript a3.rplot.R ${outdir}/b3-psite/${i} ${begin} ${end} ${name} 
	mv ${outdir}/b3-psite/${i}*.pdf ${outdir}/b4-pdf/$name
done

}

#b5rplot ENST00000619449 1908 2030

b5merge()
{
name=$1
[[ -d ${outdir}/b4-merge/$name ]] || mkdir -p ${outdir}/b4-merge/$name

array=($(ls ${outdir}/b3-psite | grep tsv$ |grep $name))
# extract the first and second elements.
begin1=${array[0]};
begin2=${array[1]};
# array remove the first and second element.
array2=("${array[@]:2}");

echo -e "perl a7.merge.pl ${outdir}/b3-psite/$begin1 ${outdir}/b3-psite/$begin2 "
perl a7.merge.pl ${outdir}/b3-psite/$begin1 ${outdir}/b3-psite/$begin2
mv ${outdir}/b3-psite/${begin1}.sort.tsv ${outdir}/b3-psite/${name}.tmp
for i in ${array2[@]};
do echo $i;
perl a7.merge.pl ${outdir}/b3-psite/${name}.tmp ${outdir}/b3-psite/${i}
mv ${outdir}/b3-psite/${name}.tmp.sort.tsv ${outdir}/b3-psite/${name}.tmp

done
mv ${outdir}/b3-psite/${name}.tmp ${outdir}/b3-psite/${name}.merge.tsv
}

#b5merge ENST00000652112

b6rplot(){
name=$1
begin=$2
end=$3
[[ -d ${outdir}/b5-pdf/$name ]] || mkdir -p ${outdir}/b5-pdf/$name
[[ -d ${outdir}/b5-pdf/$name/trans/log ]] || mkdir -p ${outdir}/b5-pdf/$name/trans/log
[[ -d ${outdir}/b5-pdf/$name/trans/axis ]] || mkdir -p ${outdir}/b5-pdf/$name/trans/axis
[[ -d ${outdir}/b5-pdf/$name/orf/log ]] || mkdir -p ${outdir}/b5-pdf/$name/orf/log
[[ -d ${outdir}/b5-pdf/$name/orf/axis ]] || mkdir -p ${outdir}/b5-pdf/$name/orf/axis


for i in `ls ${outdir}/b3-psite |grep tsv$|grep $name`;do
        echo ${i};
        echo Rscript a4.rplot.R ${outdir}/b3-psite/${i} ${begin} ${end}
        Rscript a4.rplot.R ${outdir}/b3-psite/${i} ${begin} ${end} ${name}
	echo -e "mv ${outdir}/b3-psite/${i}.tran.pdf ${outdir}/b5-pdf/$name"
mv ${outdir}/b3-psite/${i}.tran.pdf ${outdir}/b5-pdf/$name/trans/log
mv ${outdir}/b3-psite/${i}.tran.axis.pdf ${outdir}/b5-pdf/$name/trans/axis
mv ${outdir}/b3-psite/${i}.orf.pdf ${outdir}/b5-pdf/$name/orf/log
mv ${outdir}/b3-psite/${i}.axis.orf.pdf ${outdir}/b5-pdf/$name/orf/axis


done

}

plot_onestep(){
name=$1
start=$2
end=$3
psite=$4
b3extract ${name}
b4psite ${name} ${psite}
b5merge ${name}
b6rplot ${name} ${start} ${end}
}

data_seprate(){
name=$1
key=$2
begin=$3
end=$4
[[ -d $outdir/b4-merge/$name/$key ]] || mkdir -p $outdir/b4-merge/$name/$key
for i in `ls $outdir/b3-psite |grep $name|grep $key`;
do echo $i;
cp $outdir/b3-psite/$i $outdir/b4-merge/$name/$key
done

#begin merge
wkdir=$outdir/b4-merge/$name/$key
array=($(ls ${wkdir} | grep tsv$ |grep $name))
# extract the first and second elements.
begin1=${array[0]};
begin2=${array[1]};
# array remove the first and second element.
array2=("${array[@]:2}");

echo -e "perl a7.merge.pl ${wkdir}/$begin1 ${wkdir}/$begin2 "
perl a7.merge.pl ${wkdir}/$begin1 ${wkdir}/$begin2
mv ${wkdir}/${begin1}.sort.tsv ${wkdir}/${name}.tmp
for i in ${array2[@]};
do echo $i;
perl a7.merge.pl ${wkdir}/${name}.tmp ${wkdir}/${i}
mv ${wkdir}/${name}.tmp.sort.tsv ${wkdir}/${name}.tmp

done
mv ${wkdir}/${name}.tmp ${wkdir}/${name}.merge.tsv
rm ${wkdir}/${name}*${key}*
mv ${wkdir}/${name}.merge.tsv ${wkdir}/${name}.${key}.merge.tsv
Rscript a4.rplot.R ${wkdir}/${name}.${key}.merge.tsv ${begin} ${end} ${name}
#
mv ${wkdir}/${name}*.tran.pdf ${outdir}/b5-pdf/$name/trans/log
mv ${wkdir}/${name}*.tran.axis.pdf ${outdir}/b5-pdf/$name/trans/axis
mv ${wkdir}/${name}*.axis.orf.pdf ${outdir}/b5-pdf/$name/orf/axis
mv ${wkdir}/${name}*.orf.pdf ${outdir}/b5-pdf/$name/orf/log
}

plot_total(){
name=$1
begin=$2
end=$3
config=$4
normal=$5
tomor=$6
plot_onestep ${name} $begin $end $config
data_seprate ${name} $normal $begin $end
data_seprate ${name} $tomor $begin $end

}
plot_total ENST00000254801 19 498 total.txt J-R T-R 
plot_total ENST00000621781 240 494 total.txt J-R T-R
plot_total ENST00000196551 73 687 total.txt J-R T-R
plot_total ENST00000652112 1917 2603 total.txt J-R T-R
plot_total ENST00000619449 1908 2030 total.txt J-R T-R
plot_total ENST00000499732 867 1055 total.txt J-R T-R
plot_total ENST00000418747 717 1112 total.txt J-R T-R
plot_total ENST00000501122 1086 1274 total.txt J-R T-R
plot_total ENST00000578497 119 289 total.txt J-R T-R
plot_total ENST00000398881 34 258 total.txt J-R T-R
plot_total ENST00000196551 73 687 total.txt J-R T-R

