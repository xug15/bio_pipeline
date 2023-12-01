wk=output
flowcell='FLO-MIN106'
kit='SQK-LSK109'
f5d=rawdata/
genome=/home/xugang/data/reference/cp00357/GCF_000007045.1_ASM704v1_genomic.fa
path=`pwd`
fastq=${wk}/b2-merge/meth.fq.gz
region='NC_003098.1:1-2,038,615'
EPINANO_HOME=/home/app/EpiNano-Epinano1.2.0
basecall_p(){
[ -d ${wk}/b1-basecall ] || mkdir -p ${wk}/b1-basecall
echo guppy_basecaller -i $f5d -s $wk/b1-basecall --flowcell ${flowcell} --kit ${kit} --compress_fastq --recursive  --cpu_threads_per_caller 12
guppy_basecaller -i ${f5d} -s ${wk}/b1-basecall --flowcell ${flowcell} --kit ${kit} --compress_fastq --recursive  --cpu_threads_per_caller 12
}

basecall_meth()
{
[ -d ${wk}/b6-basecall ] || mkdir -p ${wk}/b6-basecall
echo -e "guppy_basecaller -i ${f5d} -s ${wk}/b6-basecall --config dna_r9.4.1_450bps_modbases_dam-dcm-cpg_hac_prom.cfg --compress_fastq --recursive  --cpu_threads_per_caller 12"
guppy_basecaller -i ${f5d} -s ${wk}/b6-basecall --config dna_r9.4.1_450bps_modbases_dam-dcm-cpg_hac_prom.cfg --compress_fastq --recursive  --cpu_threads_per_caller 12

}
basecall_meth


mergef(){
[ -d ${wk}/b2-merge ] || mkdir -p ${wk}/b2-merge

cat ${wk}/b1-basecall/*fastq.gz > ${wk}/b2-merge/meth.fq.gz
}

nanopindex(){
nanopolish index -d ${f5d} ${fastq}
}
mapf(){
[ -d ${wk}/b3-map ] || mkdir -p ${wk}/b3-map
minimap2 -a -x map-ont ${genome} ${fastq} | samtools sort -T tmp -o ${wk}/b3-map/output.sorted.bam
samtools index ${wk}/b3-map/output.sorted.bam
}
callmeth(){
[ -d ${wk}/b4-meth ] || mkdir -p ${wk}/b4-meth
echo -e " nanopolish call-methylation -t 8 -r ${fastq} -b ${wk}/b3-map/output.sorted.bam -g ${genome} -w ${region} > ${wk}/b4-meth/methylation_calls.tsv "
nanopolish call-methylation -t 8 -r ${fastq} -b ${wk}/b3-map/output.sorted.bam -g ${genome} -w ${region} > ${wk}/b4-meth/methylation_calls.tsv

}
statistic(){
/home/app/nanopolish/scripts/calculate_methylation_frequency.py ${wk}/b4-meth/methylation_calls.tsv > ${wk}/b4-meth/methylation_frequency.tsv
}



#basecall_p
#mergef
#nanopindex
#mapf
#callmeth
#statistic

meth(){
config=/home/app/ont-guppy-cpu/data/dna_r9.4.1_450bps_modbases_dam-dcm-cpg_hac.cfg

[ -d ${wk}/b5-meth ] || mkdir -p ${wk}/b5-meth

echo -e "guppy_basecaller -config ${config} -i ${f5d} -s ${wk}/b5-meth --compress_fastq --recursive  --num_callers 12 --cpu_threads_per_caller 1"

guppy_basecaller -config ${config} -i ${f5d} -s ${wk}/b5-meth --compress_fastq --recursive  --num_callers 12 --cpu_threads_per_caller 1

}
#meth

megalodonf(){

[ -d ${wk}/b6-mega-meth ] || mkdir -p ${wk}/b6-mega-meth
echo -e "megalodon ${f5d}  --outputs basecalls mappings mod_mappings mods  --reference ${genome} --mod-motif Z CG 0 --devices 0 1 --processes 10 --overwrite --guppy-server-path /home/app/ont-guppy-cpu/bin/guppy_basecall_server --output-directory ${wk}/b6-mega-meth"

megalodon ${f5d}  --outputs basecalls mappings mod_mappings mods  --reference ${genome} --mod-motif Z CG 0 --devices 0 1 --processes 10 --overwrite --guppy-server-path /home/app/ont-guppy-cpu/bin/guppy_basecall_server --output-directory ${wk}/b6-mega-meth

}

#megalodonf



tombo_resquiggle(){
echo -e "tombo preprocess annotate_raw_with_fastqs --fast5-basedir ${f5d} --fastq-filenames ${wk}/b2-merge/meth.fq.gz --overwrite"
#tombo preprocess annotate_raw_with_fastqs --overwrite  --fast5-basedir ${f5d} --fastq-filenames ${wk}/b2-merge/meth.fq.gz --overwrite
echo -e "tombo resquiggle ${f5d} ${genome} --processes 10 --num-most-common-errors 5 --basecall-group ${wk}/b1-basecall"
tombo resquiggle ${f5d} ${genome} --processes 10 --num-most-common-errors 5 --basecall-group ${wk}/b1-basecall 

}
#tombo_resquiggle

tombo_resf(){

echo tombo resquiggle ${f5d} ${genome} --basecall-group ${wk}/b1-basecall --processes 4 --num-most-common-errors 5

}
#tombo_resf

epinano_var(){

echo -e python $EPINANO_HOME/Epinano_Variants.py -n 6 -R ${genome} -b ${wk}/b3-map/output.sorted.bam -s /home/app/EpiNano-Epinano1.2.0/misc/sam2tsv.jar --type g 
python $EPINANO_HOME/Epinano_Variants.py -t 6 -R ${genome} -b ${wk}/b3-map/output.sorted.bam -s /home/app/EpiNano-Epinano1.2.0/misc/sam2tsv.jar --type g
}

#epinano_var



deepmodf(){

deepmod=/home/app/DeepMod
source activate mdeepmod
[ -d ${wk}/b5-deepmod ] || mkdir -p ${wk}/b5-deepmod
echo -e "python ${deepmod}/bin/DeepMod.py detect --wrkBase ${f5d} --Ref ${genome} --outFolder ${wk}/b5-deepmod --Base A --modfile ${deepmod}/train_mod/rnn_conmodA_P100wd21_f7ne1u0_4/mod_train_conmodA_P100wd21_f3ne1u0 --FileID bar7_m6A --threads 14 "

python ${deepmod}/bin/DeepMod.py detect --wrkBase ${f5d} --Ref ${genome} --outFolder ${wk}/b5-deepmod --Base A --modfile ${deepmod}/train_deepmod/rnn_conmodA_P100wd21_f7ne1u0_4/mod_train_conmodA_P100wd21_f3ne1u0 --FileID bar7_m6A --threads 14

}
#deepmodf


