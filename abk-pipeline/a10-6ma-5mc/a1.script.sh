name=bar8
wk=output
rawdata=rawdata/
genome=/home/xugang/data/reference/cp00357/GCF_000007045.1_ASM704v1_genomic.fa

prepare(){

[ -d ${wk}/b1-rawdata ] || mkdir -p ${wk}/b1-rawdata
rm -rf ${wk}/b1-rawdata/*
for i in `ls $rawdata`;do
	echo $i;
	mkdir -p ${wk}/b1-rawdata/$i
	cp ${rawdata}/$i ${wk}/b1-rawdata/$i/

done
}

megalodonf(){
[ -d ${wk}/b2-meth ] || mkdir -p ${wk}/b2-meth

for i in `ls  ${wk}/b1-rawdata`;do 
	echo ${wk}/b1-rawdata/$i/$i;
	mkdir -p ${wk}/b2-meth/$i


echo megalodon ${wk}/b1-rawdata/$i/ --outputs mod_basecalls per_read_mods mods mod_mappings --reference ${genome} --processes 16 --overwrite --guppy-server-path /home/app/ont-guppy-cpu/bin/guppy_basecall_server --guppy-timeout 6000 --mod-database-timeout 6000 --output-directory ${wk}/b2-meth/$i
megalodon ${wk}/b1-rawdata/$i/ --outputs mod_basecalls per_read_mods mods mod_mappings --reference ${genome} --processes 16 --overwrite --guppy-server-path /home/app/ont-guppy-cpu/bin/guppy_basecall_server --guppy-timeout 6000 --mod-database-timeout 6000 --output-directory ${wk}/b2-meth/$i
done
}

statistic(){
[ -d ${wk}/b3-static ] || mkdir -p ${wk}/b3-static

rm ${wk}/b3-static/mod.6mA.bed
rm ${wk}/b3-static/mod.5mC.bed

for i in `ls ${wk}/b2-meth/`;
do echo $i;
	echo "${wk}/b2-meth/$i/modified_bases.6mA.bed"
	cat ${wk}/b2-meth/$i/modified_bases.6mA.bed >>${wk}/b3-static/mod.6mA.bed
	cat ${wk}/b2-meth/$i/modified_bases.5mC.bed >> ${wk}/b3-static/mod.5mC.bed
done

perl a2.filterbed.pl ${wk}/b3-static/mod.6mA.bed

perl a2.filterbed.pl ${wk}/b3-static/mod.5mC.bed
rm ${wk}/b3-static/mod.6mA.bed
rm ${wk}/b3-static/mod.5mC.bed
sort -k1,1 -k2,2n ${wk}/b3-static/mod.6mA.bed.f.bed > ${wk}/b3-static/mod.6mA.sort.bed
sort -k1,1 -k2,2n ${wk}/b3-static/mod.5mC.bed.f.bed > ${wk}/b3-static/mod.5mC.sort.bed
echo -e "ref\tstar\tend\tname\tscore\tstrand\tstart\tend\tcolor\tcoverage\tpercentage" > ${wk}/b3-static/head.txt
cat ${wk}/b3-static/head.txt ${wk}/b3-static/mod.6mA.sort.bed > ${wk}/b3-static/${name}.6mA.tsv
cat ${wk}/b3-static/head.txt ${wk}/b3-static/mod.5mC.sort.bed > ${wk}/b3-static/${name}.5mC.tsv
rm ${wk}/b3-static/mod.6mA.bed.f.bed
rm ${wk}/b3-static/mod.5mC.bed.f.bed
rm ${wk}/b3-static/mod.6mA.sort.bed
rm ${wk}/b3-static/mod.5mC.sort.bed
rm ${wk}/b3-static/head.txt

}

mergesam(){
[ -d ${wk}/b4-bam ] || mkdir -p ${wk}/b4-bam
rm ${wk}/b4-bam/mapping.bam
for i in `ls ${wk}/b2-meth/`;
do echo $i;
        samtools view ${wk}/b2-meth/$i/mappings.bam >>${wk}/b4-bam/mapping.sam
done
sort -k3,3 -k4,4n ${wk}/b4-bam/mapping.sam > ${wk}/b4-bam/${name}.sort.sam
rm ${wk}/b4-bam/mapping.sam
}
mkclean(){
rm -rf ${wk}/b1-rawdata/*

}

prepare
megalodonf
statistic
mergesam
mkclean
