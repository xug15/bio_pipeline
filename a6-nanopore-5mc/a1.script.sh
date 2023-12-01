wk=output
flowcell='FLO-MIN106'
kit='SQK-LSK109'
f5d=rawdata
genome=/home/xugang/data/reference/cp00357/GCF_000007045.1_ASM704v1_genomic.fa
path=`pwd`
fastq=${wk}/b2-merge/meth.fq.gz
region='NC_003098.1:1-2,038,615'
blastdb=/home/xugang/data/reference/pneumoniae/initiation
basecall_p(){
[ -d ${wk}/b1-basecall ] || mkdir -p ${wk}/b1-basecall
echo guppy_basecaller -i $f5d -s $wk/b1-basecall --flowcell ${flowcell} --kit ${kit} --compress_fastq --recursive  --cpu_threads_per_caller 38
guppy_basecaller -i ${f5d} -s ${wk}/b1-basecall --flowcell ${flowcell} --kit ${kit} --compress_fastq --recursive --cpu_threads_per_caller 38
}
mergef(){
[ -d ${wk}/b2-merge ] || mkdir -p ${wk}/b2-merge

cat ${wk}/b1-basecall/*fastq.gz > ${wk}/b2-merge/meth.fq.gz
}

nanopindex(){
nanopolish index -d ${f5d} ${fastq}
}
mapf(){
[ -d ${wk}/b3-map ] || mkdir -p ${wk}/b3-map
minimap2 -a -x map-ont ${genome} ${fastq} | samtools sort -T tmp -o ${wk}/b3-map/output.sorted.bam
samtools index ${wk}/b3-map/output.sorted.bam
}
callmeth(){
[ -d ${wk}/b4-meth ] || mkdir -p ${wk}/b4-meth
echo -e " nanopolish call-methylation -t 8 -r ${fastq} -b ${wk}/b3-map/output.sorted.bam -g ${genome} -w ${region} > ${wk}/b4-meth/methylation_calls.tsv "
nanopolish call-methylation -t 8 -r ${fastq} -b ${wk}/b3-map/output.sorted.bam -g ${genome} -w ${region} > ${wk}/b4-meth/methylation_calls.tsv

}
statistic(){
/home/app/nanopolish/scripts/calculate_methylation_frequency.py ${wk}/b4-meth/methylation_calls.tsv > ${wk}/b4-meth/methylation_frequency.tsv
}

assemble(){
[ -d ${wk}/b5-assembl  ] || mkdir -p ${wk}/b5-assembl
canu \
  -p genome -d ${wk}/b5-assembl \
  genomeSize=5.8m \
  correctedErrorRate=0.075 \
  -trimmed -corrected -pacbio ${wk}/b2-merge/meth.fq.gz

}

blastnf(){
echo -e "blastn -query ${wk}/b5-assembl/genome.contigs.fasta -db ${blastdb} -outfmt 7 -out ${wk}/b5-assembl/hit.txt"
blastn -query ${wk}/b5-assembl/genome.contigs.fasta -db ${blastdb} -outfmt 7 -out ${wk}/b5-assembl/hit.txt
grep -B 4 -v '#' ${wk}/b5-assembl/hit.txt > ${wk}/b5-assembl/target.txt
#rm ${wk}/b5-assembl/hit.txt
[ -d ${wk}/b6-genome ] || mkdir -p ${wk}/b6-genome

cp ${wk}/b5-assembl/target.txt ${wk}/b6-genome
cp ${wk}/b5-assembl/genome.contigs.fasta ${wk}/b6-genome
#echo -e "perl a3.fa.pl ${wk}/b5-assembl/genome.contigs.fasta ${wk}/b5-assembl/target.txt"
perl a3.fa.pl ${wk}/b6-genome/genome.contigs.fasta ${wk}/b6-genome/target.txt


}


basecall_p
mergef
#nanopindex
#mapf
#callmeth
#statistic
#assemble
#blastnf




