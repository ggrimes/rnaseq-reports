library(tidyverse)
library(SummarizedExperiment)
library(janitor)
library(msigdbr)
library(clusterProfiler)
library(knitr)
library(rtracklayer)
library(DESeq2)
library(DEGreport)
library(ggrepel)
# library(RColorBrewer)
library(DT)
library(pheatmap)
library(RColorBrewer)
library(ggprism)
library(grafify)

factor_of_interest <- "sample_type"
genome <- "hg38"
single_end <- FALSE

sanitize_datatable <- function(df, ...) {
  # remove dashes which cause wrapping
  DT::datatable(df, ...,
                rownames = gsub("-", "_", rownames(df)),
                colnames = gsub("-", "_", colnames(df))
  )
}

# 2. Set input files in this file
source("../00_params/params-example.R")
# 3. If you set up this file, project information will be printed below and
# .   it can be reused for other Rmd files.
source("../information.R")
# 4. Load custom functions to load data from coldata/metrics/counts
source("../00_libs/load_data.R")

ggplot2::theme_set(theme_prism(base_size = 12))
# https://grafify-vignettes.netlify.app/colour_palettes.html
# NOTE change colors here if you wish
scale_colour_discrete <- function(...) {
  scale_colour_manual(...,
                      values = as.vector(grafify:::graf_palettes[["kelly"]])
  )
}
scale_fill_discrete <- function(...) {
  scale_fill_manual(...,
                    values = as.vector(grafify:::graf_palettes[["kelly"]])
  )
}


# This code will load from bcbio or nf-core folder
# TODO:  make sure to set numerator and denominator
coldata <- load_coldata(coldata_fn)
# Change this line to change the levels to the desired order.
# It will affect downstream colors in plots.
coldata[[factor_of_interest]] <- as.factor(coldata[[factor_of_interest]])
coldata$sample <- row.names(coldata)

counts <- load_counts(counts_fn)
counts <- counts[, colnames(counts) %in% coldata$sample]

metrics <- load_metrics(
  se_object, multiqc_data_dir,
  gtf_fn, counts, single_end
) %>%
  left_join(coldata, by = c("sample")) %>%
  as.data.frame()
metrics <- subset(metrics, metrics$sample %in% coldata$sample)
# TODO: change order as needed
order <- unique(metrics[["sample"]])
rownames(metrics) <- metrics$sample
# if the names don't match in order or string check files names and coldata information
counts <- counts[, rownames(metrics)]
coldata <- coldata[rownames(metrics), ]
stopifnot(all(names(counts) == rownames(metrics)))

meta_df <- coldata
ggplot(meta_df, aes(.data[[factor_of_interest]],
                    fill = .data[[factor_of_interest]]
)) +
  geom_bar() +
  ylab("") +
  xlab("") +
  ylab("# of samples") +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5),
    legend.position = "none"
  )


meta_sm <- meta_df %>%
  as.data.frame()

meta_sm %>% sanitize_datatable()

# get min percent mapped reads for reference
min_pct_mapped <- round(min(metrics$mapped_reads / metrics$total_reads) * 100, 1)
max_pct_mapped <- round(max(metrics$mapped_reads / metrics$total_reads) * 100, 1)
