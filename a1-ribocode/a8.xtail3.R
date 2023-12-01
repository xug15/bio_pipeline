
library(xtail)
data=read.table('output/a10-count/merge.tsv',sep="\t",row.names=c(1),header=T)

outname='output/a11-xtail/t3-t2'
# rpf and rna
mrna=data[,c(15,16,17,18)]
rpf=data[,c(4,5,7,8)]

condition <- c("t2","t2","t3","t3")
test.results <- xtail(mrna,rpf,condition,bins=1000,threads=10)
#
test.tab=resultsTable(test.results);
#head(test.tab,5)

write.csv(test.tab,paste(outname, "_results.csv",sep=''),quote=F,row.names=T);

# Visualization
# 转录组 和翻译组
pdf(paste(outname, "_FC.pdf",sep=''),width=6,height=4,paper='special')
lbxfc=plotFCs(test.results)
dev.off()
write.csv(lbxfc$resultsTable,paste(outname, "_fc.csv",sep=''),quote=F);
# 翻译效率图
pdf(paste(outname, "_RS.pdf",sep=''),width=6,height=4,paper='special')
lbxrs=plotRs(test.results)
dev.off()
write.csv(lbxrs$resultsTable,paste(outname, "_rs.csv",sep=''),quote=F);

# 火山图
pdf(paste(outname, "_volcano.pdf",sep=''),width=6,height=4,paper='special')
volcanoPlot(test.results)
dev.off()





