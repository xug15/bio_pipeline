# Nexter, Illumina Prep. PCR kits.
adapter1=CTGTAGGCACCATCAAT
# TruSeq DNA methylation TruSeq Ribo
adapter2=AGATCGGAAGAGCACACGTCTGAAC
# TruSeq Ribo
#adapter2=AGATCGGAAGAGCACACGTCT
#TruSeq DNA and RNA CD indexes
#adapter2=AGATCGGAAGAGCACACGTCT
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
#adapter7=CTGTCTCTTATACACATCT

outdir=output
[[ -d $outdir ]] || mkdir -p $outdir
cutadapterf(){
[[ -d $outdir/a2-cutadapter/ ]] || mkdir $outdir/a2-cutadapter/
rm $outdir/a2-cutadapter/${name}*
rm $outdir/a2-cutadapter/log.${name}*
for i in {1..7};
do echo $i;
variable=adapter${i};
echo ${variable};
echo ${!variable};
echo -e "cutadapt -m 18 -j 10 --match-read-wildcards -a ${!variable} -o ${outdir}/a2-cutadapter/${name}_trimmed.$i.fastq  ${fastq} > ${outdir}/a2-cutadapter/log.${name}.$i.log"
cutadapt -m 18 -j 10 --match-read-wildcards -a ${!variable} -o ${outdir}/a2-cutadapter/${name}_trimmed.$i.fastq  ${fastq} > ${outdir}/a2-cutadapter/log.${name}.$i.log

done

}

pick_adapter(){

grep 'Reads with adapters:'  $outdir/a2-cutadapter/log.${name}* > $outdir/a2-cutadapter/pick.${name}.total
perl a16.detectadapter.pl  $outdir/a2-cutadapter/pick.${name}.total 
for i in `cat $outdir/a2-cutadapter/pick.${name}.total.kp`;do
	echo ke $i ${name}_trimmed.fastq;
	mv $outdir/a2-cutadapter/$i $outdir/a2-cutadapter/${name}_trimmed.fastq;
done

for i in `cat  $outdir/a2-cutadapter/pick.${name}.total.rm`;do
	echo rm $i;
	rm $outdir/a2-cutadapter/$i
done

# $outdir/a2-cutadapter/pick.${name}.total.rm
# $outdir/a2-cutadapter/pick.${name}.total.kp

}

#cutadapterf
start2(){
for i in `ls rawdata`;
do
IFS='.' read -ra ADDR <<< "$i"
name=${ADDR[0]}
fastq=`realpath rawdata/$i`;
echo $name;
echo $fastq;
cutadapterf
pick_adapter
done
}
start2





