# info params
date <- "YYYYMMDD"
basedir <- "./" # where to write down output files

# Your data
# This is the file used to run nf-core or compatible to that
coldata_fn <- "/Path/to/metadata/meta.csv"
# This file is inside star_salmon/ folder
# Use gene_counts_length_scaled.tsv to use the transcript-level abundance estimates to calculate a gene-level offset that corrects for changes to the average transcript length across samples
#   See more here: https://bioconductor.org/packages/devel/bioc/vignettes/tximport/inst/doc/tximport.html#Downstream_DGE_in_Bioconductor
#   This is correct because in nf-core/rnaseq this files is created with tximport argument countsFromAbundance="lengthScaledTPM" 
#   https://github.com/nf-core/rnaseq/blob/0bb032c1e3b1e1ff0b0a72192b9118fdb5062489/modules/nf-core/tximeta/tximport/templates/tximport.r#L152
counts_fn <- "/path/to/nf-core/output/star_salmon/salmon.merged.gene_counts.tsv"
# This folder called "multiqc_report_data" is inside the output directory star_salmon inside multiqc folder
multiqc_data_dir <- "/path/to/nf-core/output/multiqc/star_salmon/multiqc_report_data"
# This file is inside the genome folder in the output directory, use this only for non-model organism
# gtf_fn='/path/to/nf-core/output/genome/hg38.filtered.gtf'
gtf_fn <- NULL
