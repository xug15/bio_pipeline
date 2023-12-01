output=output
rawdata=rawdata/
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

flye -o $output/a3-assembly/$name --plasmids --threads 36 --nano-raw $output/a2-qc/$name.long.fastq.gz

}
ref=/home/xugang/data/reference/tair/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
graphmapf(){
[[ -d $output/a2-graphmap ]] || mkdir -p $output/a2-graphmap
        echo -e "graphmap align -r $ref -d $output/a2-qc/FAQ24580_pass_barcode01_82e61bdc_0.fastq.long.fastq.gz -o $output/a2-graphmap/$name.sam  --double-index"

}
graphmapf

runstepone(){
mergefq2one
longreadQC
flyassembly
}

for i in `ls rawdata/`;do 
	echo $i;
	name=$i
	rawdata=rawdata
#	echo $name $rawdata
#	runstepone
done;


