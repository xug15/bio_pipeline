library(edgeR)

outname='output/a13-ORFcount/merge'

data=read.table('output/a13-ORFcount/merge.tsv',sep="\t",row.names=c(1),header=T)
datacpm=cpm(data)


write.csv(datacpm,paste(outname, "_cpm.csv",sep=''),quote=F);



