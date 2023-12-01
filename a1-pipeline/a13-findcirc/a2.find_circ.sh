export PATH=/home/app/anaconda2/bin:$PATH
bowtie2index=/home/xugang/data/reference/tair/bowtie2/tair
genomefa=/home/xugang/data/reference/tair/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
output=out_findcirc
findcirpath=/home/app/find_circ-master
[[ -d ${output} ]] || mkdir -p ${output}
bowtie2indexbuild(){
bowtie2-build CDR1as_locus.fa bt2_cdr1as_locus > bt2_build.log 2>&1;
}

mapf(){
[[ -d ${output}/a1-map ]] || mkdir -p ${output}/a1-map
echo "mapping to genome"
echo -e "bowtie2 -p8 --very-sensitive --score-min=C,-15,0 --reorder --mm -1 $fq1 -2 $fq2 -x ${bowtie2index} 2> bt2_firstpass.log  | samtools view -hbuS - | samtools sort - > ${output}/${name}.bam "
	bowtie2 -p8 --very-sensitive --score-min=C,-15,0 --reorder --mm \
                 -1 $fq1 -2 $fq2 -x ${bowtie2index} \
                2> bt2_firstpass.log  | samtools view -hbuS - | samtools sort - > ${output}/a1-map/${name}.bam

}

unmapf(){
[[ -d ${output}/a2-unmap ]] || mkdir -p ${output}/a2-unmap
echo "samtools to unmap"
echo -e "samtools view -hf 4 ${output}/${name}.bam | samtools view -Sb - > ${output}/unmapped_${name}.bam"
samtools view -hf 4 ${output}/a1-map/${name}.bam | samtools view -Sb - > ${output}/a2-unmap/unmapped_${name}.bam
echo -e "${findcirpath}/unmapped2anchors.py ${output}/unmapped_${name}.bam > ${output}/anchors_${name}.fastq"
${findcirpath}/unmapped2anchors.py ${output}/a2-unmap/unmapped_${name}.bam > ${output}/a2-unmap/anchors_${name}.fastq

}
splice(){
[[ -d ${output}/a3-circRNA ]] || mkdir -p ${output}/a3-circRNA
echo "unmap read to map"
        #mkdir -p $output/${name}_out
	echo -e "bowtie2 -q -U ${output}/anchors_${name}.fastq -x ${bowtie2index} --reorder --mm --very-sensitive --score-min=C,-15,0 2> $output/${name}_out/$name.bt2_secondpass.log | ${findcirpath}/find_circ.py -G ${genomefa} -n test -p ${name}_ --stats $output/${name}_out/$name.sites.log --reads $output/${name}_out/$name.spliced_reads.fa > $output/${name}_out/$name.splice_sites.bed"
        bowtie2 -q -U ${output}/a2-unmap/anchors_${name}.fastq -x ${bowtie2index} --reorder --mm --very-sensitive --score-min=C,-15,0 2> $output/a3-circRNA/$name.bt2_secondpass.log | \
                ${findcirpath}/find_circ.py -G ${genomefa} -n test -p ${name}_ \
                --stats $output/a3-circRNA/$name.sites.log \
                --reads $output/a3-circRNA/$name.spliced_reads.fa \
                > $output/a3-circRNA/$name.splice_sites.bed
	}
filterf(){
echo "candidates"
echo -e "grep CIRCULAR $output/${name}_out/$name.splice_sites.bed | awk '$5>=2' | grep UNAMBIGUOUS_BP|grep ANCHOR_UNIQUE | ${findcirpath}/maxlength.py 100000 > $output/${name}_out/$name.circ_candidates.bed"
grep CIRCULAR $output/a3-circRNA/$name.splice_sites.bed | awk '$5>=2' | grep UNAMBIGUOUS_BP|grep ANCHOR_UNIQUE | ${findcirpath}/maxlength.py 100000 > $output/a3-circRNA/$name.circ_candidates.bed

}

fq1=/home/xugang/data/zhujinhen2/sl-G1-G12-12circRNA-seq/G1-D701/output/a3-rRNA/G1-D701.1
fq2=/home/xugang/data/zhujinhen2/sl-G1-G12-12circRNA-seq/G1-D701/output/a3-rRNA/G1-D701.2
name=g1

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



mapf
unmapf
splice
filterf



