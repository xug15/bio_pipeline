output=output

gtf=/home/xugang/data/reference/hg38/Homo_sapiens.GRCh38.100.chr.gtf
gtf=/home/xugang/data/reference/mouse/ensembl_release-100/Mus_musculus.GRCm38.100.gtf
#gtf=/home/xugang/data/reference/mouse/gencode.vM25.annotation.clean.gtf


[ -d ${output}/a11-xtail/csv ] || mkdir -p ${output}/a11-xtail/csv

for i in `ls ${output}/a11-xtail |grep .csv$ |grep -v '.2.csv'`;
do echo $i;
perl a15.xtail.rename.pl ${gtf} ${output}/a11-xtail/${i}
mv ${output}/a11-xtail/${i} ${output}/a11-xtail/csv
done






