args=commandArgs(trailingOnly=T)
namearray=strsplit(args[1],'\\.')[[1]]
ntail=length(namearray)

print(namearray[ntail])
filet=namearray[ntail]

if(filet %in% 'csv')
{
print("file is csv");
data=read.table(args[1],header=T,row.name=1,sep=',')
}else if(filet %in%  'tsv'){
print ("file is tsv")
data=read.table(args[1],header=T,row.name=1)
}
dim(data)
rnaup=data[data$mRNA_log2FC>1,]
rnado=data[data$mRNA_log2FC< -1,]
rpfup=data[data$RPF_log2FC>1,]
rpfdo=data[data$RPF_log2FC< -1,]
teup=data[data$log2FC_TE_final>1  & data$pvalue_final<0.05,]
tedo=data[data$log2FC_TE_final< -1 & data$pvalue_final<0.05,]

#head(teup)
#head(tedo)
write.csv(rnaup,paste(args[1],"rnaup.csv",sep='.'),quote=F);
write.csv(rnado,paste(args[1],"rnado.csv",sep='.'),quote=F);
write.csv(rpfup,paste(args[1],"rpfup.csv",sep='.'),quote=F);
write.csv(rpfdo,paste(args[1],"rpfdo.csv",sep='.'),quote=F);
write.csv(teup,paste(args[1],"teup.csv",sep='.'),quote=F);
write.csv(tedo,paste(args[1],"tedo.csv",sep='.'),quote=F);




