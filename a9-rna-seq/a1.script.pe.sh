
adaptor=CTGTCTCTTATACACATCT
#data_path=/home/xugang/data/yangyiyi/b1-data
output=output
rawdata=rawdata

mouseref(){
index=/home/xugang/data/reference/mouse/rRNA-bowtie/rRNA
genomeFile=/home/xugang/data/reference/mouse/ensembl_release-100/star_25a
gtf=/home/xugang/data/reference/mouse/ensembl_release-100/Mus_musculus.GRCm38.100.gtf
species=mouse
}
#mouseref
humanf(){
index=/home/xugang/data/reference/hg38/rRNAbowtie/rRNA
genomeFile=/home/xugang/data/reference/hg38/star_2-5-3a
gtf=/home/xugang/data/reference/hg38/Homo_sapiens.GRCh38.100.chr.gtf
species=human

}
humanf

cutadaptf(){
[[ -d $output/b1-rmadapter ]] || mkdir -p $output/b1-rmadapter

echo "cutadapt -j 18 -m 20 -a ${adaptor} -A ${adaptor} -o ${output}/b1-rmadapter/$name.1.fq -p ${output}/b1-rmadapter/$name.2.fq ${rawdata}/$name1 ${rawdata}/$name2 > ${output}/b1-rmadapter/log.${name}.log"

cutadapt -j 18 -m 20 -a ${adaptor} -A ${adaptor} -o ${output}/b1-rmadapter/$name.1.fq -p ${output}/b1-rmadapter/$name.2.fq ${rawdata}/$name1 ${rawdata}/$name2 > ${output}/b1-rmadapter/log.${name}.log

}


rRNAf(){
cd /home/xugang/data/reference/mouse
grep rRNA Mus_musculus.GRCm38.100.gff3 > rRNA.gff
bedtools getfasta -fi Mus_musculus.GRCm38.dna.primary_assembly.fa -bed rRNA.gff >rRNA.fa
mkdir rRNA
mkdir rRNA-bowtie
#bowtie2-build rRNA.fa rRNA/rRNA
bowtie-build rRNA.fa rRNA-bowtie/rRNA
cd -
}
#rRNAf

rmrRNA()
{
[[ -d $output/b2-rmrRNA/nonrRNA ]] ||  mkdir -p $output/b2-rmrRNA/nonrRNA

echo "bowtie -n 0 -norc --best -l 15 -p 18 ${index} -1 ${output}/b1-rmadapter/$name.1.fq -2 ${output}/b1-rmadapter/$name.2.fq  $output/b2-rmrRNA/${name}.alin --un $output/b2-rmrRNA/${name}  > $output/b2-rmrRNA/${name}.err 2> $output/b2-rmrRNA/${name}.err "

bowtie -n 0 -norc --best -l 15 -p 18 ${index} -1 ${output}/b1-rmadapter/$name.1.fq -2 ${output}/b1-rmadapter/$name.2.fq  $output/b2-rmrRNA/${name}.alin --un $output/b2-rmrRNA/${name}  > $output/b2-rmrRNA/${name}.err 2> $output/b2-rmrRNA/${name}.err

rm $output/b2-rmrRNA/${name}.alin

}

starp(){
[[ -d $output/b3-STAR/ ]] ||  mkdir -p $output/b3-STAR/

echo "STAR --runThreadN 18 --alignEndsType EndToEnd --outFilterMismatchNmax 2 --outFilterMultimapNmax 8 --genomeDir $genomeFile --readFilesIn $output/b2-rmrRNA/${name}_1 $output/b2-rmrRNA/${name}_2  --outFileNamePrefix $output/b3-STAR/${name} --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM GeneCounts"

STAR --runThreadN 18 --alignEndsType EndToEnd \
     --outFilterMismatchNmax 2 \
     --outFilterMultimapNmax 8 \
     --genomeDir $genomeFile --readFilesIn $output/b2-rmrRNA/${name}_1 \
     $output/b2-rmrRNA/${name}_2 \
     --outFileNamePrefix $output/b3-STAR/${name} \
     --outSAMtype BAM SortedByCoordinate --quantMode TranscriptomeSAM GeneCounts


}
#starp

stringtiep(){
[[ -d $output/b6-assebly ]] || mkdir -p $output/b6-assebly
echo "stringtie -p 28 -G $gtf -o $output/b6-assebly/$name.gtf $output/b3-STAR/${name}Aligned.sortedByCoord.out.bam"
#stringtie -p 28 -G $gtf -o $output/b6-assebly/$name.gtf $output/b3-STAR/${name}Aligned.sortedByCoord.out.bam
perl a6.extpm.pl $output/b6-assebly/$name.gtf
}


gfoldf(){

[[ -d $output/b4-gfold/ ]] || mkdir -p $output/b4-gfold/  
echo "samtools view $output/b3-STAR/${name}Aligned.sortedByCoord.out.bam | gfold count -ann ${gtf} -tag stdin -o $output/b4-gfold/${name}.read_cnt  >$output/b4-gfold/${name}.err"
samtools view $output/b3-STAR/${name}Aligned.sortedByCoord.out.bam | gfold count -ann ${gtf} -tag stdin -o $output/b4-gfold/${name}.read_cnt  >$output/b4-gfold/${name}.err
}


mergef(){
for i in `ls $output/b4-gfold/ |grep .read_cnt$`;
do
file=`echo $i| cut -f 1 -d '.'`;
echo -e "gene\t$file">$output/b4-gfold/$i.txt ;
cut -f 1,3 $output/b4-gfold/$i >> $output/b4-gfold/$i.txt;
done
cd $output/b4-gfold/
file=(`ls |grep .read_cnt.txt$`);
begin1=${file[0]};
cp $begin1 tmp;
echo $begin1;
file2=("${file[@]:1}");
echo ${file2[0]};
for i in ${file2[@]};
do echo $i;
join tmp $i > tmp2
mv tmp2 tmp
done
mv tmp merge.tsv
sed -i 's/ \+/\t/g' merge.tsv
cd -
}
#mergef
mergegf(){
for i in `ls $output/b4-gfold/ |grep .read_cnt$`;
do
file=`echo $i| cut -f 1 -d '.'`;
echo -e "gene\t$file">$output/b4-gfold/$i.txt ;
cut -f 2,3 $output/b4-gfold/$i >> $output/b4-gfold/$i.txt;
done
cd $output/b4-gfold/
file=(`ls |grep .read_cnt.txt$`);
begin1=${file[0]};
cp $begin1 tmp;
echo $begin1;
file2=("${file[@]:1}");
echo ${file2[0]};
for i in ${file2[@]};
do echo $i;
join tmp $i > tmp2
mv tmp2 tmp
done
mv tmp merge.gene.tsv
sed -i 's/ \+/\t/g' merge.gene.tsv
cd -
}
#mergegf
cpmf(){
[[ -d $output/b5-cpm ]] || mkdir -p $output/b5-cpm

cp $output/b4-gfold/merge.tsv $output/b5-cpm
/usr/bin/Rscript a2.cpm.R

}
exname(){
perl a3.name.pl b4-gfold/df.up.tsv
perl a3.name.pl b4-gfold/df.down.tsv
perl a3.name.pl b4-gfold/cpm.tsv

}
#exname

get_exp(){
mkdir b5-heatmap
cut -f 1 b4-gfold/df.up.tsv > b5-heatmap/c1.up.name.txt
cut -f 1 b4-gfold/df.down.tsv > b5-heatmap/c2.down.name.txt
cp b4-gfold/log2_total_cpm.tsv b5-heatmap/
cp b4-gfold/log2_fit.tsv b5-heatmap/
head -n 1 b5-heatmap/log2_total_cpm.tsv > b5-heatmap/c3.up.exp.tsv
for i in `cat b5-heatmap/c1.up.name.txt`;
do 
grep $i b5-heatmap/log2_total_cpm.tsv >> b5-heatmap/c3.up.exp.tsv
done
head -n 1 b5-heatmap/log2_total_cpm.tsv > b5-heatmap/c4.down.exp.tsv
for i in `cat b5-heatmap/c2.down.name.txt`;
do
grep $i b5-heatmap/log2_total_cpm.tsv >> b5-heatmap/c4.down.exp.tsv
done

}
#get_exp
mergeff(){
[[ -d $output/b7-tpm ]] || mkdir -p $output/b7-tpm
cp $output/b6-assebly/*gtf.tsv $output/b7-tpm/
for i in `ls $output/b7-tpm |grep .gtf.tsv$`;
do
	echo $i;
file=`echo $i| cut -f 1 -d '.'`;
echo $file;
echo -e "gene\ttranscript\tname\t${file}_cov\t${file}_FPKM\t${file}_TPM">$output/b7-tpm/$i.txt ;

sed 1d $output/b7-tpm/$i >> $output/b7-tpm/$i.txt;
done
cp a7.merge.pl $output/b7-tpm/
cd $output/b7-tpm/
file=(`ls |grep .txt$`);
begin1=${file[0]};
cp $begin1 tmp;
echo $begin1;
file2=("${file[@]:1}");
echo ${file2[0]};
for i in ${file2[@]};
do echo $i;
perl a7.merge.pl tmp $i 
mv tmp2 tmp
done
mv tmp merge.tpm.tsv
cd -
rm $output/b7-tpm/*gtf.tsv $output/b7-tpm/a7.merge.pl $output/b7-tpm/*gtf.tsv.txt
}

mergeff


runonestep(){
cutadaptf
rmrRNA
starp
gfoldf
stringtiep
}
start(){
for i in `ls rawdata|grep _1.`;
do 
reg=clean.fq.gz
rep=_1.${reg}
echo $i
name="${i/$rep/}"
echo $name
name1=$i
name2=${name}_2.${reg}
echo $name $name1 $name2
echo $species
#runonestep
#stringtiep
done
}



#start
#mergegf
#mergef
#cpmf





