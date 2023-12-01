
fq=rawdata/Tetra_unmod.fq.gz
f5=rawdata/Tetra_unmod_fast5
output=output
name=tetra_unmod
ref=tetra_ribozyme.fa
localpth=`pwd`
[[ -d $output ]] || mkdir -p $output
basecaller(){

[[ -d $output/a1-basecaller ]] || mkdir -p $output/a1-basecaller
#conda activate albacore
echo read_fast5_basecaller.py -i $f5 -s $output/a1-basecaller/$name -r -k SQK-RNA001 -f FLO-MIN106 -o fast5,fastq --disable_filtering
 read_fast5_basecaller.py -i $f5 -s $output/a1-basecaller/$name -t 20 -r -k SQK-RNA001 -f FLO-MIN106 -o fast5,fastq --disable_filtering
#conda deactivate
cat $output/a1-basecaller/$name/workspace/*.fastq | sed 's/U/T/g' > $output/a1-basecaller/$name/$name.fq
}



graphmapf(){
[[ -d $output/a2-graphmap ]] || mkdir -p $output/a2-graphmap
	graphmap align -r $ref -d $output/a1-basecaller/$name/$name.fq -o $output/a2-graphmap/$name.sam  --double-index

}
samf(){

samtools view -bT $ref -F 16 $output/a2-graphmap/$name.sam > $output/a2-graphmap/$name.gene.bam
samtools sort $output/a2-graphmap/$name.gene.bam > $output/a2-graphmap/$name.gene.s.bam
samtools index $output/a2-graphmap/$name.gene.s.bam

}

nanopolishindex(){
nanopolish index -d $f5 $output/a1-basecaller/$name/$name.fq
}
nanopolishalign(){
[[ -d $output/a3-nanopolish ]] || mkdir $output/a3-nanopolish 
echo "nanopolish eventalign -t 20  --reads $output/a1-basecaller/$name/$name.fq --bam $output/a2-graphmap/$name.gene.s.bam --genome $ref --print-read-names --scale-events > $output/a3-nanopolish/$name.gene.event"
nanopolish eventalign -t 20  --reads $output/a1-basecaller/$name/$name.fq --bam $output/a2-graphmap/$name.gene.s.bam --genome $ref --print-read-names --scale-events > $output/a3-nanopolish/$name.gene.event
}
statisevent(){
echo "perl a2.current.pl $output/a3-nanopolish/$name.gene.event"
perl a2.current.pl $output/a3-nanopolish/$name.gene.event 
}
readevent(){
[[ -d $output/a4-readevent ]] || mkdir -p $output/a4-readevent
cd /home/app/PORE-cupine-master/for_single_gene/
echo "/usr/bin/Rscript /home/app/PORE-cupine-master/for_single_gene/Read_events.R -f $localpth/$output/a3-nanopolish/$name.gene.event -o $localpth/$output/a4-readevent/$name.combined.RData"
/usr/bin/Rscript /home/app/PORE-cupine-master/for_single_gene/Read_events.R -f $localpth/$output/a3-nanopolish/$name.gene.event -o $localpth/$output/a4-readevent/$name.combined.RData
}


#basecaller
#graphmapf
#samf
#nanopolishindex
#nanopolishalign
#statisevent
#readevent
run_loop(){
for i in `ls rawdata|grep fast5$`;
do 
	#echo $i;
	name="${i/_fast5/}"
	echo $name
	f5=rawdata/$i
	echo $f5
basecaller
graphmapf
samf
nanopolishindex
nanopolishalign
statisevent
done
}

run_loop


