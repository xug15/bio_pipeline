output=output
rawdata=rawdata/fastq/barcode01
name=bar1
[[ -d $output ]] || mkdir $output

mergefq2one(){
[[ -d $output/a1-fq ]] || mkdir $output/a1-fq

cat $rawdata/*fastq |gzip > $output/a1-fq/$name.input.fq.gz

}
longreadQC(){
[[ -d $output/a2-qc ]] || mkdir $output/a2-qc
filtlong --min_length 1000 --keep_percent 95 $output/a1-fq/$name.input.fq.gz | gzip > $output/a2-qc/$name.long.fastq.gz

}
flyassembly(){
[[ -d $output/a3-assembly ]] || mkdir $output/a3-assembly

flye -o $output/a3-assembly/$name --plasmids --threads 16 --nano-raw $output/a2-qc/$name.long.fastq.gz

}

runstepone(){
mergefq2one
longreadQC
flyassembly
}
for i in `ls rawdata/fastq/|grep -v unclassified`;do 
	echo $i;
	name=$i
	rawdata=rawdata/fastq/$i
	echo $name $rawdata
	runstepone
	perl a3.fasplit.pl $output/a3-assembly/$name/assembly.fasta
done;


