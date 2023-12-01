library(edgeR)

outname='output/a10-count/merge'

data=read.table('output/a10-count/merge.tsv',sep="\t",row.names=c(1),header=T)
datacpm=cpm(data)


write.csv(datacpm,paste(outname, "_cpm.csv",sep=''),quote=F);



