#rsync -avt xugang@166.111.156.51:/workdata2/Projects/lifj/Project/05.Ribo_seq_human/GSE21992/07.STAR/SRR057511_12_STAR/*  hela/
#rsync -avt xugang@166.111.156.51:/workdata2/Projects/lifj/Project/05.Ribo_seq_human/GSE21992/07.STAR/SRR057526_STAR/* hela/


hela_f(){
for i in SRR057511 SRR057526;do
    fastq-dump $i
done
}

d293t_f(){
[[ -d 293t/rawdata ]] || mkdir -p 293t/rawdata 
cd 293t/rawdata
for i in SRR648667 SRR648669 SRR1173909 SRR1551165 SRR1795425 SRR1795427 SRR2075925 SRR2075926 SRR2075936 SRR2075937 SRR5413155 SRR6814039 SRR6814040 SRR618771 SRR619083;
do echo $i;
fastq-dump $i
done
cd -
}
#d293t_f
pc3_f(){
[[ -d $cellname/rawdata ]] || mkdir -p $cellname/rawdata
cd $cellname/rawdata
for i in ${sraarray[@]};
do echo $i;
fastq-dump $i
done
cd -
}

cellname=pc3
sraarray=(SRR403883 SRR403889)
sraarray=(SRR2873530 SRR2873534)
pc3_f
cellname=thp1
sraarray=(SRR525273 SRR525274 SRR525275)
#pc3_f
cellname=bj
sraarray=(SRR627620 SRR627621 SRR627625 SRR810100)
#pc3_f
cellname=u2os
sraarray=(SRR1598971 SRR1551155 SRR1916542 SRR1916544)
#pc3_f

cellname=mcf10a
sraarray=(SRR1528632 SRR1528650 SRR1528654 SRR1528660 SRR1528672 SRR1802132 SRR1802140  SRR1802141 SRR1802142)
#pc3_f

cellname=hek293
sraarray=(SRR2075925 SRR2075926 SRR2075936 SRR2075937)
#pc3_f

cellname=hub7
sraarray=(SRR5227294SRR5227295 SRR5227296 SRR5227303 SRR5227304 SRR5227305 SRR5227307 SRR5227309)
#pc3_f

cellname=hela
sraarray=(SRR3680966 SRR3680967 SRR3680968 SRR3680969)
#pc3_f



