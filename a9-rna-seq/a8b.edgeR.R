
library(edgeR)
data=read.table('output/a10-count/merge.tsv',sep="\t",row.names=c(1),header=T)

outname='output/a11-xtail/c2ctrol_m42meto_merge'
#extract subdata from big matrix
rna=data[c(1,3,5,11)]
#set group
group <- factor(c(1,1,2,2))

y <- DGEList(counts=rna,group=group)
keep <- filterByExpr(y)
y <- y[keep,,keep.lib.sizes=FALSE]
y <- calcNormFactors(y)
design <- model.matrix(~group)
y <- estimateDisp(y,design)
#To perform quasi-likelihood F-tests:
fit <- glmQLFit(y,design)
qlf <- glmQLFTest(fit,coef=2)


write.csv(qlf$table,paste(outname, "_edgeR.csv",sep=''),quote=F);


