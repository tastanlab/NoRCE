#' Get the biotype of the non-coding genes. It is suitable for the GENCODE gtf files
#'
#' @param gtfFile Path of the input gtf file which contains biotype information. The gtf file must be provided from the Ensembl or Gencode site. For space efficiency, gft files should be in a zip format.
#'
#' @return Tabular form of the gtf file with the required features such as gene id and biotypes
#'
#' @import readr
#'
#' @examples
#' \dontrun{
#'
#' gtfFile="\\pathTotheGTFFile\\Homo_sapiens.GRCh38.93.chr.gtf.zip"
#' gtf <- extractBiotype(gtfFile = gtfFile)
#' }
#'
#' @export
#'
extractBiotype <- function(gtfFile) {
  mydata <- read_table(gtfFile, comment = '#', col_names = FALSE)
  temp <- strsplit(as.character(mydata$X1), "[;\t]+")

  #r<-lapply(temp,function(x) grepl("type|transcript_id|gene_id",x))
  r <- lapply(temp, function(x)
    grepl("type|gene_id", x))
  r <- sapply(r, as.logical)

  a <- list()
  for (i in 1:length(r)) {
    tr <- which(r[[i]] == 'TRUE')
    a[[i]] <- temp[[i]][tr]
  }

  mat <- t(sapply(a,
                  function(x, m)
                    c(x, rep(NA, m - length(
                      x
                    ))),
                  max(rapply(a, length))))
  gtf <- gsub("^.* ", "", mat, perl = TRUE)
  gtf <- gsub("\"", "", gtf)
  return(gtf)
}

#' Extract the genes that have user provided biotypes. This method is useful when input gene list is mixed or when research of the interest is only focused on specific group of genes.
#'
#' @param gtfFile Input gtf file for the genes provided by the extractBiotype function
#' @param biotypes Selected biotypes for the genes
#'
#' @return Table format of genes with a given biotypes
#'
#'
#' @examples
#' \dontrun{
#'
#' biotypes <- c('lincRNA','antisense')
#' lncGenes <-filterBiotype(gtfFile = "filePath//gtf", biotypes = biotypes)
#'
#' a<-geneGOEnrichment(gene = unique(lncGenes), hg = "hg19", genetype = "Ensembl_gene")
#' }
#'
#' @export
filterBiotype <- function(gtfFile, biotypes) {
  gtf <- extractBiotype(gtfFile = gtfFile)
  all <- data.frame(gene = character(), stringsAsFactors = FALSE)
  for (i in 1:length(biotypes)) {
    index <- which(gtf == biotypes[i], arr.ind = TRUE)
    all <- rbind(all, as.data.frame(gtf[index[, 1], 1]))
  }
  all <- as.data.frame(unlist(apply(unique(all), 2, strsplit,'[.]'))[ c(TRUE,FALSE) ])
  colnames(all)<-'gene'
  return(all)
}
