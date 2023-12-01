# Nexter, Illumina Prep. PCR kits.
adapter1=CTGTAGGCACCATCAAT
# TruSeq DNA methylation TruSeq Ribo
adapter2=AGATCGGAAGAGCACACGTCTGAAC
# TruSeq Ribo
#adapter3=AGATCGGAAGAGCACACGTCT
#TruSeq DNA and RNA CD indexes
#adapter4=AGATCGGAAGAGCACACGTCT
#TruSeq small RNA
adapter3=TGGAATTCTCGGGTGCCAAGG
#AmpliSeq for Illumina Panels
adapter4=CTGTCTCTTATACACATCT
#other1
adapter5=TCGTATGCCGTCTTCTGCTTG
#other2
adapter6=GTGGGGGGCCCAAGTCCTTCTGATC
#ploy A
adapter7=AAAAAAAA
#Nextera mate pair 
#adapter9=CTGTCTCTTATACACATCT

outdir=output
[[ -d $outdir ]] || mkdir -p $outdir
cutadapterf(){
[[ -d $outdir/a2-cutadapter/ ]] || mkdir $outdir/a2-cutadapter/
for i in {1..7};
do echo $i;
variable=adapter${i};
echo ${variable};
echo ${!variable};
echo -e "cutadapt -m 18 -j 10 --match-read-wildcards -a ${!variable} -o ${outdir}/a2-cutadapter/${name}_trimmed.$i.fastq  ${fastq} > ${outdir}/a2-cutadapter/log.${name}.$i.log"
cutadapt -m 18 -j 10 --match-read-wildcards -a ${!variable} -o ${outdir}/a2-cutadapter/${name}_trimmed.$i.fastq  ${fastq} > ${outdir}/a2-cutadapter/log.${name}.$i.log

done

}

#cutadapterf
start(){
for i in `ls rawdata|head -n 1`;
do
IFS='.' read -ra ADDR <<< "$i"
name=${ADDR[0]}
fastq=`realpath rawdata/$i`;
echo $name;
echo $fastq;
cutadapterf
done
}
start





