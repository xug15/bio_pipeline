library(edgeR)
outname='output/a10-count/merge'
x=read.delim('output/a10-count/merge.tsv',sep="\t",row.names=c(1),header=T)
x_cpm=cpm(x)
write.csv(x_cpm,paste(outname, ".cpm.csv",sep=''),quote=F);





