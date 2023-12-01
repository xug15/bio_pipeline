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
star_index=/home/xugang/data/reference/hg38/star_2-5-3a
echo $gtf
echo $genome
echo $rRNA_bowtie
echo $star_index
}
humanf
#mouse
mousef(){
#gtf=/home/xugang/data/reference/mouse/gencode.vM25.annotation.clean.gtf
gtf=/home/xugang/data/reference/mouse/ensembl_release-100/Mus_musculus.GRCm38.100.gtf
#genome=/home/xugang/data/reference/mouse/gencode.fa
genome=/home/xugang/data/reference/mouse/ensembl_release-100/Mus_musculus.GRCm38.dna.primary_assembly.fa
rRNA_bowtie=/home/xugang/data/reference/mouse/rRNA-bowtie/rRNA
star_index=/home/xugang/data/reference/mouse/ensembl_release-100/star_25a
echo $gtf
echo $genome
echo $rRNA_bowtie
echo $star_index
}
#mousef

[ -d $outdir ] || mkdir -p $outdir
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
         --outFilterMismatchNmax 2 --outFilterMultimapNmax 3 \
         --genomeDir ${star_index} \
         --readFilesIn ${outdir}/a5-rmrRNA/nonrRNA/nocontam_${name} \
         --outFileNamePrefix ${outdir}/a6-map/${name} \
         --outSAMtype BAM SortedByCoordinate \
         --quantMode TranscriptomeSAM GeneCounts \
	 --outFilterMatchNmin 16

[[ -d $outdir/a9-summary/b2-region ]] || mkdir -p $outdir/a9-summary/b2-region
[[ -d $outdir/a9-summary/b1-length ]] || mkdir -p $outdir/a9-summary/b1-length
LengthDistribution -i $outdir/a6-map/${name}Aligned.sortedByCoord.out.bam -o $outdir/a9-summary/b1-length/$name.length.txt  -f bam
StatisticReadsOnDNAsContam -i $outdir/a6-map/${name}Aligned.sortedByCoord.out.bam -g $gtf  -o $outdir/a9-summary/b2-region/$name.regin.txt
#gzip ${outdir}/a5-rmrRNA/nonrRNA/nocontam_${name}
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
rm ${outdir}/a5-rmrRNA/nonrRNA/*${name}

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
for i in `ls rawdata|grep fq.gz$`;
do
IFS='.' read -ra ADDR <<< "${i}"; 
name=${ADDR[0]}
fastq=`realpath rawdata/$i`;
echo $name;
echo $fastq;
run_one_step
done
}
start

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
cd -
}
statistic
bash a3.summary.sh
ribominer_prepare(){
[[ -d $outdir/b1-ribominer ]] || mkdir -p $outdir/b1-ribominer
echo "Prepare the longest transcript annotation files"

OutputTranscriptInfo -c $outdir/a7-ribocode_annotation/transcripts_cds.txt -g ${gtf} -f $outdir/a7-ribocode_annotation/transcripts_sequence.fa -o $outdir/b1-ribominer/longest.transcripts.info.txt -O $outdir/b1-ribominer/all.transcripts.info.txt

GetProteinCodingSequence -i $outdir/a7-ribocode_annotation/transcripts_sequence.fa  -c $outdir/b1-ribominer/longest.transcripts.info.txt -o $outdir/b1-ribominer/longest --mode whole --table 1

echo "Checking 3-nt periodicity "

[[ -d $outdir/b2-periodicity ]] || mkdir -p $outdir/b2-periodicity

for i in `ls $outdir/a6-map/|grep Aligned.toTranscriptome.out.bam$`;do
	echo $i;
	
        if [ -f $outdir/a6-map/$i.sort.bam ]; then
echo "exits"	
Periodicity -i $outdir/a6-map/$i.sort.bam -a $outdir/a7-ribocode_annotation/ -o $outdir/b2-periodicity/$i -c $outdir/b1-ribominer/longest.transcripts.info.txt -L 25 -R 35
	else
		samtools sort --threads 18 -o $outdir/a6-map/$i.sort.bam $outdir/a6-map/$i
		samtools index $outdir/a6-map/$i.sort.bam
	Periodicity -i $outdir/a6-map/$i.sort.bam -a $outdir/a7-ribocode_annotation/ -o $outdir/b2-periodicity/$i -c $outdir/b1-ribominer/longest.transcripts.info.txt -L 25 -R 35
	echo ""
	fi
done
echo "Generate attributes.txt"

[[ -d $outdir/b3-attributes ]] || mkdir -p $outdir/b3-attributes
echo -e "bamLegends\tbamFiles\tStranded\treadLengths\tOffsets" > $outdir/b3-attributes/attributes.txt
for i in `ls $outdir/a8-ribocode |grep txt$`;
do echo $i;
grep -v '#' $outdir/a8-ribocode/$i >> $outdir/b3-attributes/attributes.txt
done
perl a21.attri.pl $outdir/b3-attributes/attributes.txt

mv $outdir/b3-attributes/attributes.txt.txt $outdir/b3-attributes/attributes.txt
}

attributes=$outdir/b3-attributes/attributes.txt
longest=$outdir/b1-ribominer/longest.transcripts.info.txt
longest_cds=$outdir/b1-ribominer/longest_cds_sequences.fa
gname='ctrl,meto,nt'
rname='d24-ctrl-rpf__d24-meto-rpf__d24-nt-rpf'
[[ -d $outdir/b11-select ]] || mkdir -p $outdir/b11-select
echo -e "CoverageOfEachTrans -f $attributes -c $longest -o $outdir/b11-select/select --mode density -S $outdir/b12-select/il6.txt --id-type transcript_id"
#CoverageOfEachTrans -f $attributes -c $longest -o $outdir/b11-select/select --mode density -S $outdir/b12-select/il6.txt --id-type transcript_id

#PlotTransCoverage -i $outdir/b11-select/select_d24-ctrl-rpf_raw_density.txt -o $outdir/b11-select/il6-ctrl -c $longest -t IL6  --mode density --id-type gene_name --color lightskyblue --type single-gene
#PlotTransCoverage -i $outdir/b11-select/select_d24-meto-rpf_raw_density.txt -o $outdir/b11-select/il6-meto -c $longest -t IL6  --mode density --id-type gene_name --color lightskyblue --type single-gene
#PlotTransCoverage -i $outdir/b11-select/select_d24-nt-rpf_raw_density.txt -o $outdir/b11-select/il6-nt -c $longest -t IL6  --mode density --id-type gene_name --color lightskyblue --type single-gene

#CoverageOfEachTrans -f $attributes -c $longest -o $outdir/b11-select/select --mode coverage -S $outdir/b12-select/il6.txt --id-type transcript_id


PlotTransCoverage -i $outdir/b11-select/select_d24-ctrl-rpf_RPM_depth.txt -o $outdir/b11-select/il6-ctrl -c $longest -t IL6  --mode coverage --id-type gene_name --color lightskyblue --type single-gene --ymax=0.3
PlotTransCoverage -i $outdir/b11-select/select_d24-meto-rpf_RPM_depth.txt -o $outdir/b11-select/il6-meto -c $longest -t IL6  --mode coverage --id-type gene_name --color lightskyblue --type single-gene --ymax=0.3
PlotTransCoverage -i $outdir/b11-select/select_d24-nt-rpf_RPM_depth.txt -o $outdir/b11-select/il6-nt -c $longest -t IL6  --mode coverage --id-type gene_name --color lightskyblue --type single-gene --ymax=0.3

PlotTransCoverage -i $outdir/b11-select/select_d24-ctrl-rpf_raw_depth.txt -o $outdir/b11-select/il6-ctrl-raw -c $longest -t IL6  --mode coverage --id-type gene_name --color lightskyblue --type single-gene --ymax=0.3
PlotTransCoverage -i $outdir/b11-select/select_d24-meto-rpf_raw_depth.txt -o $outdir/b11-select/il6-meto-raw -c $longest -t IL6  --mode coverage --id-type gene_name --color lightskyblue --type single-gene --ymax=0.3
PlotTransCoverage -i $outdir/b11-select/select_d24-nt-rpf_raw_depth.txt -o $outdir/b11-select/il6-nt-raw -c $longest -t IL6  --mode coverage --id-type gene_name --color lightskyblue --type single-gene --ymax=0.3


ribominer(){

echo "Metagene Analysis"

[[ -d $outdir/b4-Metagene_trans ]] || mkdir -p $outdir/b4-Metagene_trans
rm $outdir/b4-Metagene_trans/*.pdf
MetageneAnalysisForTheWholeRegions -f $outdir/b3-attributes/attributes.txt -c $outdir/b1-ribominer/longest.transcripts.info.txt -o $outdir/b4-Metagene_trans/ -b 15,90,15 -l 100 -n 10 -m 1 -e 5
echo -e "PlotMetageneAnalysisForTheWholeRegions -i $outdir/b4-Metagene_trans/_scaled_density_dataframe.txt -o $outdir/b4-Metagene_trans/output_prefix -g $gname -r $rname -b 15,90,15 --mode all --xlabel-loc -0.4"
PlotMetageneAnalysisForTheWholeRegions -i $outdir/b4-Metagene_trans/_scaled_density_dataframe.txt -o $outdir/b4-Metagene_trans/wholeregion -g $gname -r $rname -b 15,90,15 --mode all --xlabel-loc -0.4

echo "Metagene analysis on CDS regions"
[[ -d $outdir/b5-Metagene_cds_utr ]] || mkdir -p $outdir/b5-Metagene_cds_utr
rm $outdir/b5-Metagene_cds_utr/*.pdf
echo -e "MetageneAnalysis -f $attributes -c $longest -o $outdir/b5-Metagene_cds_utr/cds -U codon -M RPKM -u 0 -d 500 -l 100 -n 10 -m 1 -e 5 --norm yes -y 100 --CI 0.95 --type CDS"
MetageneAnalysis -f $attributes -c $longest -o $outdir/b5-Metagene_cds_utr/cds -U codon -M RPKM -u 0 -d 500 -l 100 -n 10 -m 1 -e 5 --norm yes -y 100 --CI 0.95 --type CDS
echo -e "PlotMetageneAnalysis -i $outdir/b5-Metagene_cds_utr/cds_dataframe.txt  -o $outdir/b5-Metagene_cds_utr/cds_plot -u 0 -d 500 -g $gname -r $rname -U codon --CI 0.95"
PlotMetageneAnalysis -i $outdir/b5-Metagene_cds_utr/cds_dataframe.txt  -o $outdir/b5-Metagene_cds_utr/cds -u 0 -d 500 -g $gname -r $rname -U codon --CI 0.95 --mode mean
##  metagene analysis for UTR
MetageneAnalysis -f $attributes -c $longest -o $outdir/b5-Metagene_cds_utr/utr -U nt -M RPKM -u 50 -d 50 -l 100 -n 10 -m 1 -e 5 --norm yes -y 50 --CI 0.95 --type UTR
## plot
echo -e "PlotMetageneAnalysis -i $outdir/b5-Metagene_cds_utr/utr_dataframe.txt  -o $outdir/b5-Metagene_cds_utr/utr_plot  -u 50 -d 50 -g $gname -r $rname  -U nt --CI 0.95"
PlotMetageneAnalysis -i $outdir/b5-Metagene_cds_utr/utr_dataframe.txt  -o $outdir/b5-Metagene_cds_utr/utr  -u 50 -d 50 -g $gname -r $rname  -U nt --CI 0.95 --mode mean

echo "Polarity calculation"

[[ -d $outdir/b6-polarity ]] || mkdir -p $outdir/b6-polarity
rm $outdir/b6-polarity/*pdf
## polarity calculation
PolarityCalculation -f $attributes -c $longest -o $outdir/b6-polarity/polarity -n 64

## plot
echo -e "PlotPolarity -i $outdir/b6-polarity/polarity_polarity_dataframe.txt -o $outdir/b6-polarity/polarity_plot -g $gname -r $rname  -y 5"
PlotPolarity -i $outdir/b6-polarity/polarity_polarity_dataframe.txt -o $outdir/b6-polarity/polarity -g $gname -r $rname  -y 5

echo -e  "Feature Analysis(FA)\n Pick out transcripts enriched ribosomes on specific region"
[[ -d $outdir/b7-specific-100 ]] || mkdir -p $outdir/b7-specific-100
rm $outdir/b7-specific-100/*pdf

RiboDensityForSpecificRegion -f $attributes -c $longest -o $outdir/b7-specific-100/specific-region -U codon -M RPKM -L 1 -R 100
cut -f 2 $longest | sed 1d > $outdir/b7-specific-100/select_all_long.txt
select_trans=$outdir/b7-specific-100/select_all_long.txt
RiboDensityAtEachKindAAOrCodon -f $attributes -c $longest -o $outdir/b7-specific-100/all_long -M RPKM -S $select_trans -l 100 -n 10 --table 1 -F $longest_cds
echo -e "PlotRiboDensityAtEachKindAAOrCodon -i $outdir/b7-specific-100/all_long_all_codon_density.txt -o $outdir/b7-specific-100/plot_all_longest  -g $gname -r $rname --level AA"
PlotRiboDensityAtEachKindAAOrCodon -i $outdir/b7-specific-100/all_long_all_codon_density.txt -o $outdir/b7-specific-100/RiboDensity_all_longest  -g $gname -r $rname --level AA

echo -e "Ribosome density around the triplete amino acid (tri-AA) motifs."
[[ -d $outdir/b8-tri-AA ]] || mkdir -p $outdir/b8-tri-AA
rm $outdir/b8-tri-AA/*pdf

## ribosome density at each tri-AA motif
RiboDensityAroundTripleteAAMotifs -f $attributes -c $longest -o $outdir/b8-tri-AA/PPP -M RPKM -S $select_trans -l 100 -n 10 --table 1 -F $longest_cds --type2 PPP --type1 PP
## plot
echo -e "PlotRiboDensityAroundTriAAMotifs -i $outdir/b8-tri-AA/PPP_motifDensity_dataframe.txt -o $outdir/b8-tri-AA/PPP_plot -g $gname -r $rname --mode mean --ymax 0.2"
PlotRiboDensityAroundTriAAMotifs -i $outdir/b8-tri-AA/PPP_motifDensity_dataframe.txt -o $outdir/b8-tri-AA/PPP -g $gname -r $rname --mode mean --ymax 0.2

echo -e "Pausing score of each triplete amino acid."

[[ -d $outdir/b9-pausing ]] || mkdir -p $outdir/b9-pausing
rm $outdir/b9-pausing/*pdf

## pausing score calculation
PausingScore -f $attributes -c $longest -o $outdir/b9-pausing/pause -M RPKM -S $select_trans  -l 100 -n 10 --table 1 -F  $longest_cds

## process pausing score
pause="$outdir/b9-pausing/pause_s1add_pausing_score.txt,$outdir/b9-pausing/pause_s1_pausing_score.txt,$outdir/b9-pausing/pause_s2add_pausing_score.txt,$outdir/b9-pausing/pause_s2_pausing_score.txt,$outdir/b9-pausing/pause_s3add_pausing_score.txt,$outdir/b9-pausing/pause_s3_pausing_score.txt,$outdir/b9-pausing/pause_s4add_pausing_score.txt,$outdir/b9-pausing/pause_s4_pausing_score.txt"
echo -e "ProcessPausingScore -i $pause  -o $outdir/b9-pausing/plot -g $gname -r $rname --mode raw --ratio_filter 2 --pausing_score_filter 1"
ProcessPausingScore -i $pause  -o $outdir/b9-pausing/pause -g $gname -r $rname --mode raw --ratio_filter 2 --pausing_score_filter 1
echo "conda activate python2.7"

}
#ribominer_prepare
#ribominer

copyb(){
[[ -d $outdir/b10-pdf ]] || mkdir -p $outdir/b10-pdf
for i in `ls $outdir|grep b |grep -v b10-pdf`;
do echo $i;
cp $outdir/$i/*pdf $outdir/b10-pdf
done


}
#copyb
seqlogop(){
#/home/app/seq2logo-2.0/Seq2Logo.py -f $outdir/b9-pausing/plot_motifs_used_for_pwm.txt -u probability -I 5 -o $outdir/b9-pausing/plot_motif_pwd --format PDF
conda run -n python2.7 /home/app/seq2logo-2.0/Seq2Logo.py -f $outdir/b9-pausing/plot_pwm.txt -u probability -I 5 -o $outdir/b9-pausing/plot_pwm_all --format PDF
}

#seqlogop


