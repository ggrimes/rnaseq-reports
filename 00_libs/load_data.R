library(tidyverse)
library(GenomeInfoDbData)
library(SummarizedExperiment)
library(janitor)
load_metrics <- function(se = se_object, multiqc = multiqc_data_dir,
                         gtf = gtf_fn,
                         counts = counts,
                         single_end = FALSE) {
  # Get metrics from nf-core into bcbio like table
  # many metrics are already in the General Table of MultiQC, this reads the file
  metrics <- read_tsv(file.path(multiqc_data_dir, "multiqc_general_stats.txt"))

  # we use the names in the multiqc general stats file to determine which version of the pipeline was used.
  # this affects other metrics processing throughout this function.
  if (any(grepl("mqc-generalstats", names(metrics)))) {
    version <- "3.14"
  } else {
    version <- "3.18"
  }

  # we get some more metrics from Qualimap and rename columns
  if (version == 3.14) {
    metrics_qualimap <- read_tsv(file.path(multiqc_data_dir, "mqc_qualimap_genomic_origin_1.txt"))
  } else {
    metrics_qualimap <- read_tsv(file.path(multiqc_data_dir, "qualimap_genomic_origin.txt"))
  }

  metrics <- metrics %>% full_join(metrics_qualimap)
  metrics <- metrics %>%
    clean_names()

  if (version == "3.14") {
    metrics <- metrics %>% dplyr::rename_with(~ gsub(".*mqc_generalstats_", "", .))
  }

  # This uses the fastqc metrics to get total reads
  total_reads <- metrics %>%
    dplyr::filter(!is.na(fastqc_raw_total_sequences)) %>%
    remove_empty(which = "cols") %>%
    dplyr::rename(single_sample = sample) %>%
    mutate(sample = gsub("_[12]+$", "", single_sample)) %>%
    group_by(sample) %>%
    summarize(total_reads = sum(fastqc_raw_total_sequences))

  # This renames to user-friendly names the metrics columns
  if (single_end) {
    metrics <- metrics %>%
      dplyr::filter(!is.na(fastqc_raw_total_sequences))
  } else {
    metrics <- metrics %>%
      dplyr::filter(is.na(fastqc_raw_total_sequences))
  }

  metrics <- metrics %>%
    remove_empty(which = "cols") %>%
    full_join(total_reads)

  if (version == "3.14") {
    metrics <- metrics %>% mutate(mapped_reads = samtools_reads_mapped)
  } else {
    metrics <- metrics %>% mutate(mapped_reads = samtools_stats_reads_mapped)
  }

  metrics <- metrics %>%
    rowwise() %>%
    mutate(exonic_rate = exonic / (exonic + intronic + intergenic)) %>%
    mutate(intronic_rate = intronic / (exonic + intronic + intergenic)) %>%
    mutate(intergenic_rate = intergenic / (exonic + intronic + intergenic))

  if (version == "3.14") {
    metrics <- metrics %>% mutate(x5_3_bias = qualimap_5_3_bias)
  } else {
    metrics <- metrics %>% mutate(x5_3_bias = qualimap_rnaseq_5_3_bias)
  }

  # Sometimes we don't have rRNA due to mismatch annotation, We skip this if is the case
  gtf <- NULL
  biotype <- NULL

  if (genome == "other") {
    gtf <- gtf_fn
  } else {
    if (genome == "hg38") {
      gtf <- "hg38.rna.gtf.gz"
    } else if (genome == "mm10") {
      gtf <- "mm10.rna.gtf.gz"
    } else if (genome == "mm39") {
      gtf <- "mm39.rna.gtf.gz"
    }
    gtf <- file.path("https://github.com/bcbio/bcbioR/raw/refs/heads/main/inst/extdata/annotation", gtf)
  }
  if (is.null(gtf)) {
    warning("No genome provided! Please add it at the top of this Rmd")
  } else {
    gtf <- rtracklayer::import(gtf)
    one <- grep("gene_type", colnames(as.data.frame(gtf)), value = TRUE)
    another <- grep("gene_biotype", colnames(as.data.frame(gtf)), value = TRUE)
    if (length(one) == 1) {
      biotype <- one
    } else if (length(another) == 1) {
      biotype <- another
    } else {
      warning("No gene biotype founded")
    }
  }

  metrics$sample <- make.names(metrics$sample)
  if (!is.null(biotype)) {
    annotation <- as.data.frame(gtf) %>% .[, c("gene_id", biotype)]
    annotation$gene_id <- stringr::str_remove(annotation$gene_id, "\\..*$") # remove .1 from end of gene
    rRNA <- grepl("rRNA|tRNA", annotation[[biotype]])
    genes <- intersect(annotation[rRNA, "gene_id"], row.names(counts))
    ratio <- data.frame(
      sample = colnames(counts),
      r_and_t_rna_rate = colSums(counts[genes, ]) / colSums(counts)
    )
    metrics <- left_join(metrics, ratio, by = "sample")
  } else {
    metrics[["r_and_t_rna_rate"]] <- NA
  }

  # if ("custom_content_biotype_counts_percent_r_rna" %in% colnames(metrics)){
  #   metrics <- mutate(metrics, r_rna_rate = custom_content_biotype_counts_percent_r_rna)
  # }else{
  #  metrics[["r_rna_rate"]] <- NA
  # }
  metrics <- metrics[, c(
    "sample", "mapped_reads", "exonic_rate", "intronic_rate",
    "total_reads",
    "x5_3_bias", "r_and_t_rna_rate", "intergenic_rate"
  )]

  rownames(metrics) <- metrics$sample
  return(metrics)
}

load_coldata <- function(coldata_fn, column = NULL, subset_column = NULL, subset_value = NULL) {
  coldata <- read.csv(coldata_fn) %>%
    dplyr::distinct(sample, .keep_all = T) %>%
    dplyr::select(!matches("fastq"), !matches("strandness")) %>%
    distinct()
  if ("description" %in% names(coldata)) {
    coldata$sample <- tolower(coldata$description)
  }
  coldata <- coldata %>% distinct(sample, .keep_all = T)
  if (!is.null(column)) {
    stopifnot(column %in% names(coldata))
  }

  # use only some samples, by default use all
  if (!is.null(subset_column)) {
    coldata <- coldata[coldata[[paste(subset_column)]] == subset_value, ]
  }
  # coldata <- coldata[coldata[[paste(column)]] %in% c(numerator, denominator), ]
  # browser()
  coldata$sample <- make.names(coldata$sample)
  rownames(coldata) <- coldata$sample
  coldata$description <- coldata$sample

  # if (!is.null(denominator))
  #   coldata[[column]] = relevel(as.factor(coldata[[column]]), denominator)

  return(coldata)
}

load_counts <- function(counts_fn) {
  # bcbio input
  if (grepl("csv", counts_fn)) {
    counts <- read_csv(counts_fn) %>%
      mutate(gene = str_replace(gene, pattern = "\\.[0-9]+$", "")) %>%
      column_to_rownames("gene")
    colnames(counts) <- tolower(colnames(counts))
    return(counts)
  } else { # nf-core input
    counts <- read_tsv(counts_fn) %>%
      dplyr::select(-gene_name) %>%
      mutate(gene_id = str_replace(gene_id, pattern = "\\.[0-9]+$", "")) %>%
      column_to_rownames("gene_id") %>%
      round() %>%
      as.matrix()
    counts <- counts[rowSums(counts) != 0, ]
    return(counts)
  }
}
