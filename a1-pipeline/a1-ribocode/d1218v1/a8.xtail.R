
library(xtail)
data=read.table('output/a10-count/merge.tsv',sep="\t",row.names=c(1),header=T)

outname='output/a11-xtail/acsb1'
# rpf and rna
mrna=data[,c(4,8)]
rpf=data[,c(3,7)]

condition <- c("ac","sb")
test.results <- xtail(mrna,rpf,condition,bins=1000,threads=10)
#
test.tab=resultsTable(test.results);
head(test.tab,5)

write.table(test.tab,paste(outname, "_results.txt",sep=''),quote=F,sep="\t");

# Visualization
# 转录组 和翻译组
pdf(paste(outname, "_FC.pdf",sep=''),width=6,height=4,paper='special')
lbxfc=plotFCs(test.results)
dev.off()
write.table(lbxfc$resultsTable,paste(outname, "_fc.txt",sep=''),quote=F,sep="\t");
# 翻译效率图
pdf(paste(outname, "_RS.pdf",sep=''),width=6,height=4,paper='special')
lbxrs=plotRs(test.results)
dev.off()
write.table(lbxrs$resultsTable,paste(outname, "_rs.txt",sep=''),quote=F,sep="\t");

# 火山图
pdf(paste(outname, "_volcano.pdf",sep=''),width=6,height=4,paper='special')
volcanoPlot(test.results)
dev.off()





