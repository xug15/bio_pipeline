
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
#cd /home/app/PORE-cupine-master/for_single_gene/
cp /home/app/PORE-cupine-master/for_single_gene/* $output/a3-nanopolish/
cd $output/a3-nanopolish/
echo "/usr/bin/Rscript /home/app/PORE-cupine-master/for_single_gene/Read_events_tsv.R -f $localpth/$output/a3-nanopolish/$name.gene.event -o $localpth/$output/a4-readevent/$name.combined.RData"

/usr/bin/Rscript Read_events_tsv.R -f $name.gene.event -o $name.combined.RData
cd ../../
}
mvRdata(){
mv $output/a3-nanopolish/dat.f.combined.$name.combined.RData.RData $output/a4-readevent/$name.combined.RData
[[ -d $output/a6-time/a1-readevent ]] || mkdir -p $output/a6-time/a1-readevent
mv $output/a3-nanopolish/*combined.RData.tsv $output/a6-time/a1-readevent
mv $output/a3-nanopolish/*combined.RData.sum.tsv $output/a6-time/a1-readevent
}
extracttime(){
[[ -d $output/a6-time-sum ]] || mkdir -p $output/a6-time-sum
perl a3.current.combined.pl $output/a6-time/a1-readevent/$name.combined.RData.tsv
perl a3.current.combined.pl $output/a6-time/a1-readevent/$name.combined.RData.sum.tsv
mv $output/a6-time/a1-readevent/$name.combined.RData.tsv.sta.tsv $output/a6-time/$name.time.tsv
mv $output/a6-time/a1-readevent/$name.combined.RData.sum.tsv.sta.tsv $output/a6-time-sum/$name.sum.time.tsv
}
reactivity(){
modified=$1
unmodified=$2
length=$3
[[ -d $output/a5-reactivity ]] || mkdir -p $output/a5-reactivity
[[ -d $output/a7-mod ]] || mkdir -p $output/a7-mod
cp /home/app/PORE-cupine-master/for_single_gene/* $output/a4-readevent
cd $output/a4-readevent
echo "/usr/bin/Rscript ./SVM_plus.R -m $modified -u $unmodified -o $modified.csv -l $length"
/usr/bin/Rscript ./SVM_plus.R -m $modified -u $unmodified -o $modified -l $length
#ls
echo "mv *.csv ../a5-reactivity/$modified.csv"

mv *csv ../a5-reactivity/
mv *mod_mat.tsv ../a7-mod
cd ../..

}
split_time(){

[[ -d $output/a7-mod-sum ]] || mkdir -p $output/a7-mod-sum	
cp $output/a6-time/a1-readevent/*combined.RData.tsv $output/a7-mod
cp $output/a6-time/a1-readevent/*combined.RData.sum.tsv $output/a7-mod-sum
cp $output/a7-mod/*RDatamod_mat.tsv $output/a7-mod-sum

for i in `ls $output/a7-mod/|grep RDatamod_mat.tsv$`;
do echo $i;
readinfo="${i/RDatamod_mat.tsv/RData.tsv}";
echo $readinfo
echo -e "perl a4.unmod.event.pl $output/a7-mod/$i $output/a7-mod/$readinfo 440"
#perl a4.unmod.event.pl $output/a7-mod/$i $output/a7-mod/$readinfo 440
echo -e "perl a5.mod.event.pl $output/a7-mod/$i $output/a7-mod/$readinfo 440"
#perl a5.mod.event.pl $output/a7-mod/$i $output/a7-mod/$readinfo 440
done

for i in `ls $output/a7-mod-sum/|grep RDatamod_mat.tsv$`;
do 
readinfo="${i/RDatamod_mat.tsv/RData.sum.tsv}";
echo $readinfo
echo $i
echo -e "perl a4.unmod.event.pl $output/a7-mod-sum/$i $output/a7-mod-sum/$readinfo 440"
perl a4.unmod.event.pl $output/a7-mod-sum/$i $output/a7-mod-sum/$readinfo 440
echo -e "perl a5.mod.event.pl $output/a7-mod-sum/$i $output/a7-mod-sum/$readinfo 440"
perl a5.mod.event.pl $output/a7-mod-sum/$i $output/a7-mod-sum/$readinfo 440
done



[[ -d $output/a8-pos-time ]] || mkdir -p $output/a8-pos-time
for i in `ls $output/a7-mod/|grep RDatamod_mat.tsv$`;
do
readinfo="${i/.combined.RDatamod_mat.tsv/}";
echo $readinfo
echo -e "perl a6.forposition.pl $output/a7-mod/$readinfo.mod.tsv"
#perl a6.forposition.pl $output/a7-mod/$readinfo.mod.tsv
echo -e "perl a6.forposition.pl $output/a7-mod/$readinfo.unmod.tsv"
#perl a6.forposition.pl $output/a7-mod/$readinfo.unmod.tsv

mv $output/a7-mod/$readinfo.mod.pos.tsv $output/a8-pos-time
mv $output/a7-mod/$readinfo.unmod.pos.tsv $output/a8-pos-time

done

[[ -d $output/a8-pos-time-sum ]] || mkdir -p $output/a8-pos-time-sum
for i in `ls $output/a7-mod-sum/|grep RDatamod_mat.tsv$`;
do
readinfo="${i/.combined.RDatamod_mat.tsv/}";
echo $readinfo
echo -e "perl a6.forposition.pl $output/a7-mod-sum/$readinfo.mod.tsv"
perl a6.forposition.pl $output/a7-mod-sum/$readinfo.mod.tsv

echo -e "perl a6.forposition.pl $output/a7-mod-sum/$readinfo.unmod.tsv"
perl a6.forposition.pl $output/a7-mod-sum/$readinfo.unmod.tsv

mv $output/a7-mod-sum/$readinfo.mod.pos.tsv $output/a8-pos-time-sum
mv $output/a7-mod-sum/$readinfo.unmod.pos.tsv $output/a8-pos-time-sum
done




}




run_loop(){
for i in `ls rawdata|grep fast5$`;
do 
	#echo $i;
	name="${i/_fast5/}"
	echo $name
	f5=rawdata/$i
	echo $f5
#basecaller
#graphmapf
#samf
#nanopolishindex
#nanopolishalign
#statisevent
#readevent
#mvRdata
extracttime
done
}

#run_loop


#reactivity Tetra_NAI_N3_1.combined.RData Tetra_unmod.combined.RData 421
#reactivity Tetra_NAI_N3_25min.combined.RData Tetra_unmod.combined.RData 421
#reactivity Tetra_NAI_N3_2.combined.RData Tetra_unmod.combined.RData 421
#reactivity Tetra_NAI_N3_denatured.combined.RData Tetra_unmod.combined.RData 421
#reactivity Tetra_unmod2.combined.RData Tetra_unmod.combined.RData 421

#split_time

predict(){
val=$1
echo -e "perl a7.ks.fa.pos.pl output/a10-ks/nai_n3_ks.tsv tetra_ribozyme.fa $val"
perl a7.ks.fa.pos.pl output/a10-ks/nai_n3_ks.tsv tetra_ribozyme.fa $val
[[ -d $output/a12-predict ]] || mkdir -p $output/a12-predict
for i in `ls output/a10-ks/|grep range.tsv`;do echo $i;
RME -d SHAPE -p 38 $output/a10-ks/$i $output/a12-predict/$i

done
[[ -d $output/a13-jpg ]] || mkdir -p $output/a13-jpg
for i in `ls output/a12-predict/|grep range.tsv`;do echo $i;
for j in `ls output/a12-predict/$i`;do
echo $i/$j;	
cut -f 3 output/a10-ks/$i |sed s/NA/0/ > tmp ;
sed 1d tmp |tr '\n' ';' > tmp2
color=`cat tmp2`;
rm tmp tmp2;
echo -e "java -cp /Users/xugang/Desktop/sequencing_center_desktop/2020/rna_structure/VARNAv3-93-src.jar fr.orsay.lri.varna.applications.VARNAcmd -i a12-predict/$i/$j -colorMapStyle \"0:#FFFFFF;0.65:#d0c9c9;1:#d6341e\" -colorMap \"$color\" "> $output/a13-jpg/code_${i}_${j}.sh
java -cp /home/app/varna/VARNAv3-93-src.jar fr.orsay.lri.varna.applications.VARNAcmd -i $output/a12-predict/$i/$j -o $output/a13-jpg/${i}_${j}.svg -colorMapStyle "0:#FFFFFF;0.65:#d0c9c9;1:#d6341e" -colorMap \"${color}\"

#java -cp /home/app/varna/VARNAv3-93-src.jar fr.orsay.lri.varna.applications.VARNAcmd -i $output/a12-predict/$i/$j -o $output/a13-jpg/${i}_${j}.svg -colorMapStyle heat
# -colorMapStyle "-0.38:#FFFFFF;3.13:#d6341e" -colorMap "0.05;3.7;0.4"
done
done
}



#split dot parent file into ct file.
#perl a10.dp2ct.pl pdb_00805.dp

#assest the ct

assestf(){
echo -e "\n$1" >> list.txt

for i in `ls $output/a12-predict|grep tsv`;
do 

for j in `ls $output/a12-predict/$i`;do 

	echo $i;
	echo $i >> list.txt;

perl a9.assuse.pl $output/a12-predict/$i/$j PDB_00805_part_1.ct 103 241 1 139 >> list.txt
perl a9.assuse.pl $output/a12-predict/$i/$j PDB_00805_part_2.ct 103 241 1 139 >> list.txt
perl a9.assuse.pl $output/a12-predict/$i/$j PDB_00805_part_3.ct 103 241 1 139 >> list.txt
perl a9.assuse.pl $output/a12-predict/$i/$j PDB_00805_part_4.ct 103 241 1 139 >> list.txt
done

done
}

loop_test(){
rm list.txt
for k in 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 ;
#for k in 0.4 ;
do
echo $k
predict $k
assestf $k
done;
}


loop_test
