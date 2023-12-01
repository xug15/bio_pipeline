adapter=CTGTAGGCACCATCAAT
adapter1=CTGTAGGCACCATCAAT
adapter2=AGATCGGAAGAGCACACGTCT
adapter3=TCGTATGCCGTCTTCTGCTTG
adapter4=GTGGGGGGCCCAAGTCCTTCTGATC

outdir=output
#human
humanf(){
gtf=/home/xugang/data/reference/hg38/Homo_sapiens.GRCh38.100.chr.gtf
genome=/home/xugang/data/reference/hg38/Homo_sapiens.GRCh38.dna.primary_assembly.fa.clean.fa
rRNA_bowtie=/home/xugang/data/reference/hg38/rRNAbowtie/rRNA
star_index=/home/xugang/data/reference/hg38/star2
echo $gtf
echo $genome
echo $rRNA_bowtie
echo $star_index
}
humanf
#mouse
mousef(){
gtf=/home/xugang/data/reference/mouse/gencode.vM25.annotation.clean.gtf
gtf=/home/xugang/data/reference/mouse/ensembl_release-100/Mus_musculus.GRCm38.100.gtf
genome=/home/xugang/data/reference/mouse/gencode.fa
genome=/home/xugang/data/reference/mouse/ensembl_release-100/Mus_musculus.GRCm38.dna.primary_assembly.fa
rRNA_bowtie=/home/xugang/data/reference/mouse/rRNA-bowtie/rRNA
star_index=/home/xugang/data/reference/mouse/star2
star_index=/home/xugang/data/reference/mouse/ensembl_release-100/star
echo $gtf
echo $genome
echo $rRNA_bowtie
echo $star_index
}
#mousef

[[ -d $outdir ]] || mkdir -p $outdir
cutadapterf(){
[[ -d $outdir/a2-cutadapter/ ]] || mkdir $outdir/a2-cutadapter/
cutadapt -m 18 -j 8 --match-read-wildcards -a ${adapter1} -o ${outdir}/a2-cutadapter/${name}_trimmed.fastq  ${fastq} > ${outdir}/a2-cutadapter/log.${name}.log

}
#cutadapterf
fastq_filterf(){
[[ -d $outdir/a3-filter/ ]] || mkdir $outdir/a3-filter/
fastq_quality_filter \
        -Q33 -v -q 25 -p 75 \
        -i ${outdir}/a2-cutadapter/${name}_trimmed.fastq \
        -o ${outdir}/a3-filter/${name}_trimmedQfilter.fastq > ${outdir}/a3-filter/log.${name}.log
}

#fastq_filterf

fastqcf(){
[[ -d $outdir/a4-qc/ ]] || mkdir -p $outdir/a4-qc/
	fastqc -t 8 \
        ${outdir}/a3-filter/${name}_trimmedQfilter.fastq \
        -o ${outdir}/a4-qc/ > ${outdir}/a4-qc/log.${name}.log
[[ -d $outdir/a9-summary/b1-length/ ]] || mkdir -p $outdir/a9-summary/b1-length/
echo LengthDistribution -i ${outdir}/a3-filter/${name}_trimmedQfilter.fastq -o $outdir/a9-summary/b1-length/$name.length.txt  -f fastq
LengthDistribution -i ${outdir}/a3-filter/${name}_trimmedQfilter.fastq -o $outdir/a9-summary/b1-length/$name.length.txt  -f fastq
rm $outdir/a9-summary/b1-length/$name.length.txt_reads_length.txt
}
#fastqcf
rmrRNA(){
[[ -d $outdir/a5-rmrRNA/nonrRNA ]] || mkdir -p $outdir/a5-rmrRNA/nonrRNA
homedir=`pwd`
bowtie \
        -n 0 -norc --best -l 15 -p 8 \
         --un=${homedir}/${outdir}/a5-rmrRNA/nonrRNA/nocontam_${name} ${rRNA_bowtie} \
         -q ${outdir}/a3-filter/${name}_trimmedQfilter.fastq \
         ${outdir}/a5-rmrRNA/${name}.alin > \
         ${outdir}/a5-rmrRNA/${name}.err 2>${outdir}/a5-rmrRNA/${name}.err && \
         rm -rf ${outdir}/a5-rmrRNA/${name}.alin
}
#rmrRNA
starf(){
[[ -d $outdir/a6-map ]] || mkdir -p $outdir/a6-map

STAR --runThreadN 8 --alignEndsType EndToEnd \
         --outFilterMismatchNmax 3 --outFilterMultimapNmax 30000 \
         --genomeDir ${star_index} \
         --readFilesIn ${outdir}/a5-rmrRNA/nonrRNA/nocontam_${name} \
         --outFileNamePrefix ${outdir}/a6-map/${name} \
         --outSAMtype BAM SortedByCoordinate \
         --quantMode TranscriptomeSAM GeneCounts \
	 --outFilterMatchNmin 16
[[ -d $outdir/a9-summary/b2-region ]] || mkdir -p $outdir/a9-summary/b2-region
StatisticReadsOnDNAsContam -i $outdir/a6-map/${name}Aligned.sortedByCoord.out.bam -g $gtf  -o $outdir/a9-summary/b2-region/$name.regin.txt
gzip ${outdir}/a5-rmrRNA/nonrRNA/nocontam_${name}
}
#starf

ribocodeannf(){
[[ -d $outdir/a7-ribocode_annotation ]] || mkdir -p $outdir/a7-ribocode_annotation


prepare_transcripts -g ${gtf} -f ${genome} -o ${outdir}/a7-ribocode_annotation

}
#ribocodeannf
metaplotf(){
ribocodeannf

[[ -d ${outdir}/a8-ribocode  ]] || mkdir -p ${outdir}/a8-ribocode
metaplots -a ${outdir}/a7-ribocode_annotation \
        -r ${outdir}/a6-map/${name}Aligned.toTranscriptome.out.bam -o ${outdir}/a8-ribocode/${name}
       
}
#metaplotf
ribocodef(){

mkdir -p /home/sfs/${JobName}/a9-ribocode-result && /root/miniconda3/bin/RiboCode -a /home/sfs/${JobName}/a7-ribocode_annotation -c /home/sfs/${JobName}/a8-ribocode/a_pre_config.txt -l no -g -o
}

mkclean(){

rm ${outdir}/a2-cutadapter/${name}*fastq
rm ${outdir}/a3-filter/${name}*.fastq
#rm ${outdir}/a5-rmrRNA/nonrRNA/*${name}

}

run_one_step(){
cutadapterf
fastq_filterf
fastqcf
rmrRNA
starf
metaplotf
mkclean
}
start(){
for i in `ls rawdata`;
do
IFS='.' read -ra ADDR <<< "$i"
name=${ADDR[0]}
fastq=`realpath rawdata/$i`;
echo $name;
echo $fastq;
run_one_step
done
}
start




