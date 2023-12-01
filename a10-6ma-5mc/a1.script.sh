name=bar8
wk=output
rawdata=rawdata
genome=/home/xugang/data/reference/cp00357/GCF_000007045.1_ASM704v1_genomic.fa

prepare(){

[[ -d ${wk}/b1-rawdata ]] || mkdir -p ${wk}/b1-rawdata
mkdir -p ${wk}/b1-rawdata/$name
cp $rawdata/$name ${wk}/b1-rawdata/$name
cd ${wk}/b1-rawdata/$name
python ../../../a3.file2h5.py $name
cd -
for i in `ls $rawdata|grep fast5`;do
	echo $i;

	echo "mkdir -p ${wk}/b1-rawdata/$name"
	echo "cp $rawdata/$name ${wk}/b1-rawdata/$name"
	echo "cd ${wk}/b1-rawdata/$name"
	echo "python ../../../a3.file2h5.py $name"
	echo "cd -"
#	mkdir -p ${wk}/b1-rawdata/$name/$i
#	cp ${rawdata}/$i ${wk}/b1-rawdata/$name/$i/
#	cd ${wk}/b1-rawdata/$name/$i/
#	python ../../../../a3.file2h5.py $i
#	cd -
done
}

megalodonf(){
[ -d ${wk}/b2-meth ] || mkdir -p ${wk}/b2-meth

for i in `ls  ${wk}/b1-rawdata/$name`;do 
	echo ${wk}/b1-rawdata/$name/$i;
	mkdir -p ${wk}/b2-meth/$name/$i

# pip install megaldon==2.2.10
echo megalodon ${wk}/b1-rawdata/$name/$i --outputs mod_basecalls per_read_mods mods mod_mappings --reference ${genome} --processes 8 --overwrite --guppy-server-path /home/app/ont-guppy-cpu/bin/guppy_basecall_server --guppy-timeout 6000 --mod-database-timeout 6000 --output-directory ${wk}/b2-meth/$name/$i
megalodon ${wk}/b1-rawdata/$name/$i --outputs mod_basecalls per_read_mods mods mod_mappings --reference ${genome} --processes 48 --overwrite --guppy-server-path /home/app/ont-guppy-cpu/bin/guppy_basecall_server --guppy-timeout 6000 --mod-database-timeout 6000 --output-directory ${wk}/b2-meth/$name/$i
done
}

statistic(){
[ -d ${wk}/b3-static ] || mkdir -p ${wk}/b3-static

rm ${wk}/b3-static/mod.6mA.bed
rm ${wk}/b3-static/mod.5mC.bed

for i in `ls ${wk}/b2-meth/`;
do echo $i;
	echo "${wk}/b2-meth/$i/splitdir/modified_bases.6mA.bed"
	cat ${wk}/b2-meth/$i/splitdir/modified_bases.6mA.bed >>${wk}/b3-static/mod.6mA.bed
	cat ${wk}/b2-meth/$i/splitdir/modified_bases.5mC.bed >> ${wk}/b3-static/mod.5mC.bed
done

perl a2.filterbed.pl ${wk}/b3-static/mod.6mA.bed

perl a2.filterbed.pl ${wk}/b3-static/mod.5mC.bed
rm ${wk}/b3-static/mod.6mA.bed
rm ${wk}/b3-static/mod.5mC.bed
sort -k1,1 -k2,2n ${wk}/b3-static/mod.6mA.bed.f.bed| uniq > ${wk}/b3-static/mod.6mA.sort.bed
sort -k1,1 -k2,2n ${wk}/b3-static/mod.5mC.bed.f.bed| uniq > ${wk}/b3-static/mod.5mC.sort.bed
echo -e "ref\tstar\tend\tname\tscore\tstrand\tstart\tend\tcolor\tcoverage\tpercentage" > ${wk}/b3-static/head.txt
cat ${wk}/b3-static/head.txt ${wk}/b3-static/mod.6mA.sort.bed > ${wk}/b3-static/${name}.6mA.tsv
cat ${wk}/b3-static/head.txt ${wk}/b3-static/mod.5mC.sort.bed > ${wk}/b3-static/${name}.5mC.tsv
rm ${wk}/b3-static/mod.6mA.bed.f.bed
rm ${wk}/b3-static/mod.5mC.bed.f.bed
rm ${wk}/b3-static/mod.6mA.sort.bed
rm ${wk}/b3-static/mod.5mC.sort.bed
rm ${wk}/b3-static/head.txt
perl a5.meth_recount.pl ${wk}/b3-static/${name}.6mA.tsv
perl a5.meth_recount.pl ${wk}/b3-static/${name}.5mC.tsv
}

mergesam(){
[ -d ${wk}/b4-bam ] || mkdir -p ${wk}/b4-bam
rm ${wk}/b4-bam/mapping.bam
for i in `ls ${wk}/b2-meth/`;
do echo $i;
        samtools view ${wk}/b2-meth/$i/splitdir/mod_mappings.bam >>${wk}/b4-bam/mapping.sam
done
sort -k3,3 -k4,4n ${wk}/b4-bam/mapping.sam > ${wk}/b4-bam/${name}.sort.sam
rm ${wk}/b4-bam/mapping.sam

}
mkclean(){
rm -rf ${wk}/b1-rawdata/*

}
extractfa(){
[[ -d ${wk}/b5-fa ]] || mkdir -p ${wk}/b5-fa
sed 1d ${wk}/b3-static/${name}.6mA.tsv > ${wk}/b5-fa/6mA.bed
perl a6.extendbed.pl ${wk}/b5-fa/6mA.bed
bedtools getfasta -fi ${genome} -bed ${wk}/b5-fa/6mA.bed.f.bed -s > ${wk}/b5-fa/${name}.6mA.fa
rm ${wk}/b5-fa/6mA.bed
sed 1d ${wk}/b3-static/${name}.5mC.tsv > ${wk}/b5-fa/5mC.bed
perl a6.extendbed.pl ${wk}/b5-fa/5mC.bed 
bedtools getfasta -fi ${genome} -bed ${wk}/b5-fa/5mC.bed.f.bed -s > ${wk}/b5-fa/${name}.5mC.fa
rm ${wk}/b5-fa/5mC.bed
}
motifget(){
[[ -d ${wk}/b5-fa/b6-seq-motif/ ]] || mkdir -p ${wk}/b5-fa/b6-seq-motif/
cp a7.reg.pl ${wk}/b5-fa
cd ${wk}/b5-fa/
perl a7.reg.pl ${name}.6mA.fa
cd -
rm -rf ${wk}/b6-$name-seq-motif
mv ${wk}/b5-fa/b6-seq-motif/ ${wk}/b6-$name-seq-motif
mv ${wk}/b5-fa/motif.tsv ${wk}/b6-$name-seq-motif
rm ${wk}/b5-fa/a7.reg.pl

}
runone(){
for i in `ls rawdata|grep fast5`;do
name=$i
rawdata="rawdata"
echo $name
echo $rawdata
#prepare
#megalodonf
mkclean
done
name=bar07
#statistic
#mergesam
#extractfa
motifget
}

runone


