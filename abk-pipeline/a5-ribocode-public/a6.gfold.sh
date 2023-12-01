outdir=output
bam_path=$outdir
gtf=/home/xugang/data/reference/mouse/gencode.vM25.annotation.gtf
gtf=/home/xugang/data/reference/hg38/Homo_sapiens.GRCh38.100.chr.gtf

gfold_f(){
[[ -d ${outdir}/a10-count/b1-gfold ]] || mkdir -p ${outdir}/a10-count/b1-gfold
for i in `ls ${bam_path}/a6-map|grep Aligned.sortedByCoord|grep -v bai`;do
	echo $i;
	name="${i/Aligned.sortedByCoord/:}";
	#echo $name;
	IFS=':' read -ra ADDR <<< "$name"
	echo ${ADDR[0]};
	echo "samtools view ${bam_path}/a6-map/${i} | gfold count -ann ${gtf} -tag stdin -o ${outdir}/a10-count/b1-gfold/${ADDR[0]}.read_cnt"
samtools view ${bam_path}/a6-map/${i} | gfold count -ann ${gtf} -tag stdin -o ${outdir}/a10-count/b1-gfold/${ADDR[0]}.read_cnt

done;
}

cut_extract(){
[[ -d ${outdir}/a10-count/b2-count ]] || mkdir -p ${outdir}/a10-count/b2-count
for i in `ls ${outdir}/a10-count/b1-gfold|grep read_cnt$`;do
	echo $i;
	IFS="." read -ra ADDR <<< "$i"
	echo -e "gene\t${ADDR[0]}" > ${outdir}/a10-count/b2-count/${ADDR[0]}.txt
	cut -f 1,3 ${outdir}/a10-count/b1-gfold/$i >> ${outdir}/a10-count/b2-count/${ADDR[0]}.txt
done
}
mergef(){
cd ${outdir}/a10-count/b2-count/
array=($(ls|grep txt|grep -v merge.txt))
head='gene'


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

sed -i 's/ \+/\t/g' merge.tmp
mv merge.tmp ../merge.tsv
cd -
}


gfold_f
cut_extract
mergef
Rscript a16.gfoldcpm.R


