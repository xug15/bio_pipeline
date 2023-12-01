
adaptor1=AGATCGGAAGAGCACACGTC
adaptor2=AGATCGGAAGAGCGTCGT
data_path=rawdata
output=output
adaptor1=AGATCGGAAGAGCACACGTCTGA
adaptor2=AGATCGGAAGAGCGTCGTGTAGGGAAA

rRNAindex=/home/xugang/data/reference/tair/tailrRNAbowtie/rRNA
rRNAindex2=/home/xugang/data/reference/tair/tailrRNAbowtie2/rRNA
starindex=/home/xugang/data/reference/tair/star
fas=/home/xugang/data/reference/tair/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
bowtieindex=/home/xugang/data/reference/tair/bowtie/tair


gtf_txt=/home/xugang/data/reference/tair/Arabidopsis_thaliana.TAIR10.48.clean.gff3.circ.sort.txt
[ -d rawdata ] || mkdir -p rawdata
mv *gz rawdata
cutadaptf(){

[[ -d $output/a1-cutadapt  ]] ||  mkdir -p $output/a1-cutadapt

echo cutadapt -m 20 -Z -a ${adaptor1} -A ${adaptor2} -o $output/a1-cutadapt/${name}${exten1} -p $output/a1-cutadapt/${name}${exten2} ${data_path}/$name${exten1} ${data_path}/${name}${exten2} --pair-filter any -j 8

cutadapt -m 50 -Z -a ${adaptor1} -A ${adaptor2} -o $output/a1-cutadapt/${name}${exten1} -p $output/a1-cutadapt/${name}${exten2} ${data_path}/$name${exten1} ${data_path}/${name}${exten2} --pair-filter any -j 8 >  $output/a1-cutadapt/${name}.log
}


fastqcf(){
[[ -d $output/a2-fqc  ]] ||  mkdir -p $output/a2-fqc

fastqc -t 8 $output/a1-cutadapt/${name}${exten1} $output/a1-cutadapt/${name}${exten2} -o $output/a2-fqc/ 

}
rmrRNA()
{

[[ -d $output/a3-rRNA  ]] ||  mkdir -p $output/a3-rRNA

echo -e "bowtie2 -p 12 -x ${rRNAindex2} -1 $output/a1-cutadapt/${name}${exten1} -2 $output/a1-cutadapt/${name}${exten2} -S $output/a3-rRNA/${name}.alin --un-conc $output/a3-rRNA/${name}"
bowtie2 -p 12 -x ${rRNAindex2} -1 $output/a1-cutadapt/${name}${exten1} -2 $output/a1-cutadapt/${name}${exten2} -S $output/a3-rRNA/${name}.sam --un-conc $output/a3-rRNA/${name}
rm $output/a3-rRNA/${name}.sam > $output/a3-rRNA/${name}.log


}


starp(){
[[ -d $output/a4-map ]] ||  mkdir -p $output/a4-map

echo STAR --runThreadN 18 --genomeDir ${starindex} --readFilesIn $output/a3-rRNA/${name}.1 $output/a3-rRNA/${name}.2 --chimSegmentMin 10 --chimOutType Junctions --outFileNamePrefix $output/a4-map/$name --outSAMtype BAM SortedByCoordinate
STAR --runThreadN 18 --genomeDir ${starindex} --readFilesIn $output/a3-rRNA/${name}.1 $output/a3-rRNA/${name}.2 --chimSegmentMin 10 --chimOutType Junctions --outFileNamePrefix $output/a4-map/$name --outSAMtype BAM SortedByCoordinate

}

parsef(){
[[ -d $output/a5-parse ]] ||  mkdir -p $output/a5-parse

echo "CIRCexplorer2 parse -t STAR $output/a4-map/${name}Chimeric.out.junction >$output/a5-parse/CIRCexplorer2_parse.log"
CIRCexplorer2 parse -t STAR $output/a4-map/${name}Chimeric.out.junction >$output/a5-parse/CIRCexplorer2_parse.log
mv back_spliced_junction.bed $output/a5-parse
}

annotef(){
[[ -d $output/a6-annote ]] ||  mkdir -p $output/a6-annote

echo "CIRCexplorer2 annotate -r $gtf_txt -g ${fas} -b $output/a5-parse/back_spliced_junction.bed -o $output/a6-annote/circularRNA_known.txt > $output/a6-annote/CIRCexplorer2_annotate.log"
CIRCexplorer2 annotate -r $gtf_txt -g ${fas} -b $output/a5-parse/back_spliced_junction.bed -o $output/a6-annote/circularRNA_known.txt > $output/a6-annote/CIRCexplorer2_annotate.log
}

assemblyf(){
[[ -d $output/a7-assemble ]] ||  mkdir -p $output/a7-assemble

echo "CIRCexplorer2 assemble -r $gtf_txt -m tophat -o$output/a7-assemble/assemble > $output/a7-assemble/CIRCexplorer2_assemble.log"
CIRCexplorer2 assemble -r $gtf_txt -m tophat -o$output/a7-assemble/assemble > $output/a7-assemble/CIRCexplorer2_assemble.log
}



tophat2f(){
[[ -d $output/a8-tophat2 ]] ||  mkdir -p $output/a8-tophat2
path=`pwd`
echo "docker run -v /home:/home genomicpariscentre/tophat2:latest tophat2 -o $path/$output/a8-tophat2 -p 8 --fusion-search --keep-fasta-order --bowtie1 --no-coverage-search ${bowtieindex} $path/$output/a3-rRNA/${name}.1 $path/$output/a3-rRNA/${name}.2"
docker run -v /home:/home genomicpariscentre/tophat2:latest tophat2 -o $path/$output/a8-tophat2 -p 8 --fusion-search --keep-fasta-order --bowtie1 --no-coverage-search ${bowtieindex} $path/$output/a3-rRNA/${name}.1 $path/$output/a3-rRNA/${name}.2


}

exten1='_1.fq.gz'
exten2='_2.fq.gz'

onestep(){
cutadaptf
fastqcf
rmrRNA
starp
parsef
annotef
#assemblyf
#tophat2f
}

for i in `ls rawdata|grep _1`;
do echo $i;
name="${i/_1.fq.gz/}";
echo $name
onestep
done

