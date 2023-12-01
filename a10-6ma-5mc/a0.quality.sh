wk=quality_out
flowcell='FLO-MIN106'
kit='SQK-LSK109'
f5d=/home/xugang/data/ZJR-Nanopore/rawdata/fast5/barcode01
genome=/home/xugang/data/reference/cp00357/GCF_000007045.1_ASM704v1_genomic.fa
path=`pwd`
fastq=${wk}/b2-merge/meth.fq.gz
basecall_p(){
[ -d ${wk}/b1-basecall ] || mkdir -p ${wk}/b1-basecall
echo guppy_basecaller -i $f5d -s $wk/b1-basecall --flowcell ${flowcell} --kit ${kit} --compress_fastq --recursive  --cpu_threads_per_caller 8
guppy_basecaller -i ${f5d} -s ${wk}/b1-basecall --flowcell ${flowcell} --kit ${kit} --compress_fastq --recursive --cpu_threads_per_caller 8
}
mergef(){
[ -d ${wk}/b2-merge ] || mkdir -p ${wk}/b2-merge

cat ${wk}/b1-basecall/*fastq.gz > ${wk}/b2-merge/meth.fq.gz
}

calculatebp(){
cp ${wk}/b2-merge/meth.fq.gz ${wk}/b2-merge/meth.fq2.gz
gunzip ${wk}/b2-merge/meth.fq.gz
mv ${wk}/b2-merge/meth.fq2.gz ${wk}/b2-merge/meth.fq.gz
perl a4.rawsize.pl ${wk}/b2-merge/meth.fq

}

fastqcf(){
out=b10-fastqc
[ -d ${wk}/${out} ] || mkdir -p ${wk}/${out}
fastqc -t 8 ${wk}/b2-merge/meth.fq -o ${wk}/${out}

}

nanofilt()
{
out=b7-NanoFilt
[ -d ${wk}/${out} ] || mkdir -p ${wk}/${out}
echo -e "NanoFilt -q 7 ${wk}/b2-merge/meth.fq > ${wk}/$out/$name.fq"

NanoFilt -q 7 ${wk}/b2-merge/meth.fq > ${wk}/$out/$name.fq
wc -l ${wk}/b2-merge/meth.fq | awk '{print "raw\t"$1/4}' > $wk/b7-NanoFilt/report.txt
wc -l ${wk}/$out/$name.fq | awk '{print "filter\t"$1/4}' >>$wk/b7-NanoFilt/report.txt

}
nanoplot(){
out=b8-NanoPlot
[ -d ${wk}/${out} ] || mkdir -p ${wk}/${out}
echo -e "NanoPlot --summary ${wk}/b1-basecall/sequencing_summary.txt -o ${wk}/${out}/$name"
NanoPlot --summary ${wk}/b1-basecall/sequencing_summary.txt -o ${wk}/${out}/$name
}
mapf2(){
out=b9-map
[ -d ${wk}/$out ] || mkdir -p ${wk}/$out
minimap2 -a -x map-ont ${genome} $wk/b7-NanoFilt/${name}.fq -o ${wk}/$out/$name.sam 2>${wk}/$out/$name.log
grep mapped ${wk}/$out/$name.log| cut -f 2-3 -d ' '>${wk}/$out/$name.txt
samtools sort -T tmp ${wk}/$out/$name.sam  -o ${wk}/$out/$name.sorted.bam
samtools index ${wk}/b9-map/$name.sorted.bam
}
summary(){
out=b11-report
[ -d ${wk}/$out ] || mkdir -p ${wk}/$out
cat ${wk}/b2-merge/meth.fq.txt > ${wk}/$out/summary.txt
cat ${wk}/b7-NanoFilt/report.txt >> ${wk}/$out/summary.txt
cat ${wk}/b9-map/$name.txt >> ${wk}/$out/summary.txt
rm ${wk}/b2-merge/meth.fq
}

basecall_p
mergef
calculatebp
fastqcf
nanofilt
nanoplot
mapf2
summary



