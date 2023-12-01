gtf=/home/xugang/data/reference/tair/Arabidopsis_thaliana.TAIR10.48.gff3
fa=/home/xugang/data/reference/tair/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
bowtie2_index=/home/xugang/data/reference/tair/bowite2/tair
path=/home/xugang/data/zhujinheng/xianxing/zhujinheng/data

bowtie2f()
{
name1=$1
name2=$2
outname=$3
[[ -d $path/b2-bowtie2  ]] || mkdir -p $path/b2-bowtie2
[[ -d $path/b3-bowtie2-un  ]] || mkdir -p $path/b3-bowtie2-un
echo bowtie2 -p 6 -x $bowtie2_index -1 $path/rawdata/$name1 -2 $path/rawdata/$name2 --seed 0 --very-sensitive -S $path/b2-bowtie2/$outname.sam

bowtie2 -p 16 -x $bowtie2_index -1 $path/rawdata/$name1 -2 $path/rawdata/$name2 --seed 0 --very-sensitive -S $path/b2-bowtie2/$outname.sam --un-conc $path/b3-bowtie2-un/$outname 2> $path/b3-bowtie2-un/$outname.log 1>$path/b3-bowtie2-un/$outname.txt


}

bowtie2f 1W-LCK0051_combined_R1.fastq.gz 1W-LCK0051_combined_R2.fastq.gz 1W
bowtie2f 1Y-LCK0052_combined_R1.fastq.gz 1Y-LCK0052_combined_R2.fastq.gz 1Y
bowtie2f 2W-LCK0053_combined_R1.fastq.gz 2W-LCK0053_combined_R2.fastq.gz 2W
bowtie2f 2Y-LCK0054_combined_R1.fastq.gz 2Y-LCK0054_combined_R2.fastq.gz 2Y
bowtie2f 3W-LCK0055_combined_R1.fastq.gz 3W-LCK0055_combined_R2.fastq.gz 3W
bowtie2f 3Y-LCK0056_combined_R1.fastq.gz 3Y-LCK0056_combined_R2.fastq.gz 3Y

samtoolsf(){
name=$1
samtools view -b -S $path/b2-bowtie2/$name.sam > $path/b2-bowtie2/$name.bam
samtools sort $path/b2-bowtie2/$name.bam > $path/b2-bowtie2/$name.sort.bam
samtools mpileup -E -gu -t DP -f $fa $path/b2-bowtie2/$name.sort.bam > $path/b2-bowtie2/$name.bcf
bcftools view $path/b2-bowtie2/$name.bcf > $path/b2-bowtie2/$name.vcf
bcftools call -m $path/b2-bowtie2/$name.vcf > $path/b2-bowtie2/$name.all.vcf
}

#samtoolsf 1W
#samtoolsf 1Y
#samtoolsf 2W  
#samtoolsf 2Y
#samtoolsf 3W
#samtoolsf 3Y


shoremap()
{
name=$1
[[ -d $path/b3-shoremap/$name ]] ||  mkdir -p $path/b3-shoremap/$name
echo docker exec -it sharemap SHOREmap convert --marker $path/b2-bowtie2/$name.all.vcf --folder $path/b3-shoremap/$name -runid 1
docker exec -it sharemap SHOREmap convert --marker $path/b2-bowtie2/$name.all.vcf --folder $path/b3-shoremap/$name -runid 1
}

#shoremap 1W
#shoremap 1Y
#shoremap 2W
#shoremap 2Y
#shoremap 3W
#shoremap 3Y

chsize=/home/xugang/data/reference/tair/chrsizes.txt
shoremap_bc(){
bk=$1
pk=$2
[[ -d $path/b3-shoremap/bk_$pk.$bk/ ]] ||  sudo mkdir -p $path/b3-shoremap/bk_$pk.$bk/

echo docker exec -it sharemap SHOREmap backcross --chrsizes ${chsize} --marker $path/b3-shoremap/$pk/1_converted_variant.txt --consen $path/b3-shoremap/$pk/1_converted_consen.txt --folder $path/b3-shoremap/bk_$pk.$bk/ -plot-bc --marker-score 20 --marker-freq 0.1 --min-coverage 5 --max-coverage 200 --bg $path/b3-shoremap/$bk/1_converted_variant.txt --bg-cov 1 --bg-freq 0.1 --bg-score 1 -non-EMS  --cluster 1 --marker-hit 1 -verbose

#docker exec -it sharemap SHOREmap backcross --chrsizes ${chsize} --marker $path/b3-shoremap/$pk/1_converted_variant.txt --consen $path/b3-shoremap/$pk/1_converted_consen.txt --folder $path/b3-shoremap/bk_$pk.$bk/ -plot-bc --marker-score 20 --marker-freq 0.1 --min-coverage 5 --max-coverage 200 --bg $path/b3-shoremap/$bk/1_converted_variant.txt --bg-cov 1 --bg-freq 0.1 --bg-score 1 -non-EMS  --cluster 1 --marker-hit 1 -verbose
#docker exec -it sharemap SHOREmap backcross --chrsizes ${chsize} --marker $path/b3-shoremap/$pk/1_converted_variant.txt --consen $path/b3-shoremap/$pk/1_converted_consen.txt --folder $path/b3-shoremap/bk_$pk.$bk/ -plot-bc
docker exec -it sharemap SHOREmap backcross --chrsizes ${chsize} --marker $path/b3-shoremap/$pk/1_converted_variant.txt --consen $path/b3-shoremap/$pk/1_converted_consen.txt --folder $path/b3-shoremap/bk_$pk.$bk.3/ -plot-bc --marker-score 20 --marker-freq 0.1 --min-coverage 2 --max-coverage 2000 --bg $path/b3-shoremap/$bk/1_converted_variant.txt --bg-cov 1 --bg-freq 0.1 --bg-score 1 -non-EMS --cluster 1 --marker-hit 1 -verbose 
}

#shoremap_bc 2W 2Y
#shoremap_bc 3W 3Y
#shoremap_bc 1W 1Y

shoremap_bc1(){
bk=$1
docker exec -it sharemap SHOREmap backcross --chrsizes ${chsize} --marker $path/b3-shoremap/$bk/1_converted_variant.txt --consen $path/b3-shoremap/$bk/1_converted_consen.txt --folder $path/b3-shoremap/$bk/ -plot-bc
}

#shoremap_bc1 1W 
#shoremap_bc1 1Y
#shoremap_bc1 2W
#shoremap_bc1 2Y
#shoremap_bc1 3W
#shoremap_bc1 3Y
#gtf=/home/xugang/data/reference/tair/tair.gff
shoremap_an(){
gtf=/home/xugang/data/reference/tair/TAIR10_GFF3_genes.gff
name=$1

[[ -d $path/b3-shoremap/anno-$name/chrom1 ]] || sudo mkdir -p $path/b3-shoremap/anno-$name/chrom1
 
echo docker exec -it sharemap SHOREmap annotate --chrsizes ${chsize} --chrom 1 --start 1 --end 30427671 --snp $path/b3-shoremap/$name/1_converted_variant.txt --folder $path/b3-shoremap/anno-$name/chrom1 --genome $fa --gff $gtf -verbose

docker exec -it sharemap SHOREmap annotate --chrsizes ${chsize} --chrom 1 --start 1 --end 30427671 --snp $path/b3-shoremap/$name/1_converted_variant.txt --folder $path/b3-shoremap/anno-$name/chrom1 --genome $fa --gff $gtf -verbose
docker exec -it sharemap SHOREmap annotate --chrsizes ${chsize} --chrom 2 --start 1 --end 19698289 --snp $path/b3-shoremap/$name/1_converted_variant.txt --folder $path/b3-shoremap/anno-$name/chrom2 --genome $fa --gff $gtf -verbose

docker exec -it sharemap SHOREmap annotate --chrsizes ${chsize} --chrom 3 --start 1 --end 23459830 --snp $path/b3-shoremap/$name/1_converted_variant.txt --folder $path/b3-shoremap/anno-$name/chrom3 --genome $fa --gff $gtf -verbose

docker exec -it sharemap SHOREmap annotate --chrsizes ${chsize} --chrom 4 --start 1 --end 18585056 --snp $path/b3-shoremap/$name/1_converted_variant.txt --folder $path/b3-shoremap/anno-$name/chrom4 --genome $fa --gff $gtf -verbose

docker exec -it sharemap SHOREmap annotate --chrsizes ${chsize} --chrom 5 --start 1 --end 26975502 --snp $path/b3-shoremap/$name/1_converted_variant.txt --folder $path/b3-shoremap/anno-$name/chrom5 --genome $fa --gff $gtf -verbose




}
#shoremap_an 1Y
#shoremap_an 2Y
#shoremap_an 3Y
#shoremap_an 1W
#shoremap_an 2W
#shoremap_an 3W


mergef(){
name=$1
outdir=b3-shoremap

[[ -d $outdir/snp ]]  || mkdir -p $outdir/snp

rm $outdir/$name/$name.snp.cds.tsv;
rm $outdir/$name/$name.snp.tsv;
echo -e  "chr\tposition\tref\talt\tnum\tAF\tquality\ttype\tregion\tgene\tdistance\torder\tsite_mutaion\tsyn_non\taa_ref\taa_alt" > $outdir/$name/$name.snp.cds.tsv;
echo -e  "chr\tposition\tref\talt\tnum\tAF\tquality\ttype\tregion\tgene\tdistance\torder\tsite_mutaion\tsyn_non\taa_ref\taa_alt" > $outdir/$name/$name.snp.tsv;

for i in `ls $outdir/$name`;do 
	for j in `ls $outdir/$name/$i|grep prioritized_snp`;do
		#echo "grep 'CDS' $outdir/$name/$i/$j >> $outdir/$name/snp.txt;"
		grep 'CDS' $outdir/$name/$i/$j >> $outdir/$name/$name.snp.cds.tsv
		cat $outdir/$name/$i/$j >> $outdir/$name/$name.snp.tsv
	done
		
done
cp $outdir/$name/$name.snp.cds.tsv $outdir/snp

cp $outdir/$name/$name.snp.tsv $outdir/snp

perl a2.filter.pl $outdir/snp/$name.snp.cds.tsv
perl a2.filter.pl $outdir/snp/$name.snp.tsv

}

#mergef anno-1W
#mergef anno-1Y
#mergef anno-2W
#mergef anno-2Y
#mergef anno-3W
#mergef anno-3Y

indef(){

perl a3.all.vcf.indel.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/1Y.all.vcf
perl a3.all.vcf.indel.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/1W.all.vcf
perl a3.all.vcf.indel.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/2W.all.vcf
perl a3.all.vcf.indel.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/2Y.all.vcf
perl a3.all.vcf.indel.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/3W.all.vcf
perl a3.all.vcf.indel.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/3Y.all.vcf

}
#indef

indef2(){

nohup perl a7.all.vcf.indel.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/1W.all.vcf >1w 2>&1&
nohup perl a7.all.vcf.indel.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/2W.all.vcf>2w 2>&1&
nohup perl a7.all.vcf.indel.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/3W.all.vcf>3w 2>&1&

}
#indef2
indef3(){

nohup perl a8.all.vcf.indel.0.5.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/1Y.all.vcf >1w 2>&1&
nohup perl a8.all.vcf.indel.0.5.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/2Y.all.vcf >1w 2>&1&
nohup perl a8.all.vcf.indel.0.5.pl /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/3Y.all.vcf >1w 2>&1&


}
#indef3

extract(){
name=$1
cut -f 1,2 /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/${name}.all.vcf.indel.tsv > /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/${name}.indel.ps.tsv
sed -i 's/\t/_/g' /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/${name}.indel.ps.tsv

}

#extract 1W 
#extract 1Y
#extract 2Y
#extract 2W
#extract 3Y
#extract 3W

sam_index_bam()
{

name=$1

samtools index /home/xugang/data/zhujinheng/xianxing/zhujinheng/data/b2-bowtie2/${name}.sort.bam 

}

#sam_index_bam 1W
#sam_index_bam 1Y
#sam_index_bam 2W
#sam_index_bam 2Y
#sam_index_bam 3W
#sam_index_bam 3Y

get_plotf(){
perl a5.all.vcf.index.pl b2-bowtie2/1W.all.vcf
perl a5.all.vcf.index.pl b2-bowtie2/2W.all.vcf
perl a5.all.vcf.index.pl b2-bowtie2/3W.all.vcf
perl a5.all.vcf.index.pl b2-bowtie2/1Y.all.vcf
perl a5.all.vcf.index.pl b2-bowtie2/2Y.all.vcf
perl a5.all.vcf.index.pl b2-bowtie2/3Y.all.vcf
}

#get_plotf

overlap(){


perl a6_overlap_w_y.pl b2-bowtie2/1W.all.vcf.indel.plotdata.tsv b2-bowtie2/1Y.all.vcf.indel.plotdata.tsv
perl a6_overlap_w_y.pl b2-bowtie2/2W.all.vcf.indel.plotdata.tsv b2-bowtie2/2Y.all.vcf.indel.plotdata.tsv
perl a6_overlap_w_y.pl b2-bowtie2/3W.all.vcf.indel.plotdata.tsv b2-bowtie2/3Y.all.vcf.indel.plotdata.tsv

}
#overlap



snp(){
outp=b4-vcf
[ -d ${outp}/ ] || mkdir -p ${outp}/
genome=/home/xugang/data/reference/tair/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
name=$1
wkdir=b2-bowtie2/
#freebayes -f ${genome} ${wkdir}/${name}.sort.bam >${outp}/${name}.vcf

bam-readcount -f ${genome} ${wkdir}/${name}.sort.bam > ${outp}/${name}.txt

}
#snp 1W
testf(){
samtools view -b -S b4-vcf/test.sam > b4-vcf/test.bam
samtools sort b4-vcf/test.bam > b4-vcf/test.sort.bam
samtools index b4-vcf/test.sort.bam



}
#testf
getindelf(){
name=$1
nohup perl a9.sam.indel.pl  b2-bowtie2/${name}.sam > b2-bowtie2/$name.log 2>&1 &

}
#getindelf 1W
#getindelf 2W
#getindelf 3W
#getindelf 1Y
#getindelf 2Y
#getindelf 3Y

mvindel(){
mv b2-bowtie2/*sam.d* b4-vcf
rm b4-vcf/*sam.dep.tsv
rm b4-vcf/*sam.del.tsv
}
#mvindel

getratio(){
nohup perl a10.indel.vcf.pl b4-vcf/1W.sam.del.sort.tsv b2-bowtie2/1W.all.vcf> b4-vcf/1W.log 2>&1 &
nohup perl a10.indel.vcf.pl b4-vcf/2W.sam.del.sort.tsv b2-bowtie2/2W.all.vcf> b4-vcf/2W.log 2>&1 &
nohup perl a10.indel.vcf.pl b4-vcf/3W.sam.del.sort.tsv b2-bowtie2/3W.all.vcf> b4-vcf/3W.log 2>&1 &
nohup perl a10.indel.vcf.pl b4-vcf/1Y.sam.del.sort.tsv b2-bowtie2/1Y.all.vcf> b4-vcf/1Y.log 2>&1 &
nohup perl a10.indel.vcf.pl b4-vcf/2Y.sam.del.sort.tsv b2-bowtie2/2Y.all.vcf> b4-vcf/2Y.log 2>&1 &
nohup perl a10.indel.vcf.pl b4-vcf/3Y.sam.del.sort.tsv b2-bowtie2/3Y.all.vcf> b4-vcf/3Y.log 2>&1 &


}

#getratio 
filterp(){

perl a11.filter.pl b4-vcf/1Y.sam.del.sort.tsv.ratio.tsv
perl a11.filter.pl b4-vcf/2Y.sam.del.sort.tsv.ratio.tsv
perl a11.filter.pl b4-vcf/3Y.sam.del.sort.tsv.ratio.tsv


perl a12.filter.pl b4-vcf/1W.sam.del.sort.tsv.ratio.tsv
perl a12.filter.pl b4-vcf/2W.sam.del.sort.tsv.ratio.tsv
perl a12.filter.pl b4-vcf/3W.sam.del.sort.tsv.ratio.tsv

perl a13.filter.pl b4-vcf/1W.sam.del.sort.tsv.ratio.tsv
perl a13.filter.pl b4-vcf/2W.sam.del.sort.tsv.ratio.tsv
perl a13.filter.pl b4-vcf/3W.sam.del.sort.tsv.ratio.tsv
}

filterp

criperf(){

bowtie /home/xugang/data/reference/tair/bowtie/tair -f /home/xugang/data/reference/tair/blast/c2.crisper.fa --best -n 3 -s crip.sam
bowtie2 -x /home/xugang/data/reference/tair/bowite2/tair -f /home/xugang/data/reference/tair/blast/c2.crisper.fa -N 1 -S crip2.sam
}


#criperf


filter(){
perl a14.filter.dep3.0.8.pl b4-vcf/1Y.sam.del.sort.tsv.ratio.tsv
perl a14.filter.dep3.0.8.pl b4-vcf/3Y.sam.del.sort.tsv.ratio.tsv
perl a14.filter.dep3.0.8.pl b4-vcf/2Y.sam.del.sort.tsv.ratio.tsv

perl a12.filter.pl b3-shoremap/anno/anno-1W.snp.tsv
perl a12.filter.pl b3-shoremap/anno/anno-2W.snp.tsv
perl a12.filter.pl b3-shoremap/anno/anno-3W.snp.tsv

perl a15.filter.3.7.pl  b3-shoremap/anno/anno-1Y.snp.tsv
perl a15.filter.3.7.pl  b3-shoremap/anno/anno-2Y.snp.tsv
perl a15.filter.3.7.pl  b3-shoremap/anno/anno-3Y.snp.tsv
}

bamcount(){

[[ -d b5-snp ]]  || mkdir -p b5-snp
name=$1
datap=b5-snp 

nohup bam-readcount -f ${fa} b2-bowtie2/${name}.sort.bam > ${datap}/${name}.txt 2>${datap}/${name}.log 1>&1 &

}

#bamcount 1W
#bamcount 2W
#bamcount 3W
#bamcount 1Y
#bamcount 2Y
#bamcount 3Y
snp_recalu(){
nohup perl a16.snp.pl b5-snp/test.txt 2>b5-snp/test.log 1>&2 &
nohup perl a16.snp.pl b5-snp/1W.txt 2>b5-snp/test.log 1>&2 &
nohup perl a16.snp.pl b5-snp/1Y.txt 2>b5-snp/test.log 1>&2 &
nohup perl a16.snp.pl b5-snp/2W.txt 2>b5-snp/test.log 1>&2 &
nohup perl a16.snp.pl b5-snp/2Y.txt 2>b5-snp/test.log 1>&2 &
nohup perl a16.snp.pl b5-snp/3W.txt 2>b5-snp/test.log 1>&2 &
nohup perl a16.snp.pl b5-snp/3Y.txt 2>b5-snp/test.log 1>&2 &

}
#snp_recalu
snp_refilter(){
perl a17.filter.pl b5-snp/1Y.txt.snp.tsv
perl a17.filter.pl b5-snp/2Y.txt.snp.tsv
perl a17.filter.pl b5-snp/3Y.txt.snp.tsv
}

#snp_refilter









