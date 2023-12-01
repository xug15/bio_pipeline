library(edgeR)
outname='output/b5-cpm/merge'
x=read.delim('output/b5-cpm/merge.tsv',sep="\t",row.names=c(1),header=T)
x_cpm=cpm(x)
write.csv(x_cpm,paste(outname, ".cpm.csv",sep=''),quote=F);


