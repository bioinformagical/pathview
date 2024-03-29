#' this is a function to run different diff expression analysis tools
#' @export
rundifftool <- function(diff.tool, gene.data, ref, samp){
    grp.idx = NULL
    grp.idx[ref] <- "reference"
    grp.idx[samp] <- "sample"
    if (diff.tool %in% c("deseq2", "limma", "edgeR"))
    {
   if (diff.tool == "deseq2")
    {
        library(DESeq2)
        coldat=DataFrame(grp=factor(grp.idx))
        dds <- DESeqDataSetFromMatrix(gene.data, colData=coldat, design = ~ grp)
        dds <- DESeq(dds)
        deseq2.res <- results(dds)
        #direction of fc, depends on levels(coldat$grp), the first level
        #taken as reference (or control) and the second one as experiment.
        deseq2.fc=deseq2.res$log2FoldChange
        names(deseq2.fc)=rownames(deseq2.res)
        exp.fc=deseq2.fc
   }
    if (diff.tool == "edgeR"){
    library(edgeR)
    dgel <- DGEList(counts=gene.data, group=factor(grp.idx))
    dgel <- calcNormFactors(dgel)
    dgel <- estimateCommonDisp(dgel)
    dgel <- estimateTagwiseDisp(dgel)
    et <- exactTest(dgel)
    edger.fc=et$table$logFC
    names(edger.fc)=rownames(et$table)
    exp.fc=edger.fc
    
    }
    if(diff.tool == "limma")
        {
        library(edgeR)
       
       dgel2 <- DGEList(counts=gene.data, group=factor(grp.idx))
       dgel2 <- calcNormFactors(dgel2)
       library(limma)
       design <- model.matrix(~grp.idx)
       log2.cpm <- voom(dgel2,design)
       fit <- lmFit(log2.cpm,design)
       fit <- eBayes(fit)
       limma.res=topTable(fit,coef=2,n=Inf,sort="p")
       limma.fc=limma.res$logFC
 
       names(limma.fc)=limma.res$ID
       exp.fc=limma.fc
    }
    }
    else
    {
        print("The diff tool is not avaliable")
    }
    return(exp.fc)
   
}