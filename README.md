Templates with ![](https://img.shields.io/badge/status-stable-green) revision indicates that the components or processes have undergone comprehensive parameterization and testing.

Templates with ![](https://img.shields.io/badge/status-alpha-yellow) revision indicates that the components or processes are currently being tested. There is some test data available, but there are parameters that need to be set up manually within the code.

Templates with ![](https://img.shields.io/badge/status-draft-grey) revision indicates that the components or processes are not fully tested. There is no test data available, parameters need to be set up manually within the code, and specific code changes are required based on the data used.

# Guidelines for RNAseq downstream analysis

- Set the working directory to the directory containing this README. We recommend using a [Project](https://support.posit.co/hc/en-us/articles/200526207-Using-RStudio-Projects) in Rstudio.
- Use [install_dependencies.R](install_dependencies.R) to install all packages used in these reports.

## Run data with nf-core rnaseq

These templates assume that the raw data has been processed by [nf-core/rnaseq](https://nf-co.re/rnaseq/3.14.0/docs/usage).

The `nf-core/rnaseq` documentation describes a `samplesheet.csv`. We recommend using this `samplesheet.csv` as a metadata or coldata file when applicable. This CSV can contain additional columns of relevant information even if these columns are not required or used by `nf-core/rnaseq`.

## Quick Start

### With Rstudio

```
source(install_depedencies.R)
quarto("quality_assessment.md", quiet = TRUE)
```

## Downstream analysis

Before using any template:
1. **Modify** [information.R](information.R) with the right information. You can use this file with any template to include the project/analysis information.
2. **Modify** [00_params/params.R](00_params/params.R) with the locations of select files/folders from the output of [nf-core/rnaseq](https://nf-co.re/rnaseq/3.14.0/docs/output). These nf-core outputs will become inputs to various templates.
3. **Modify** the `YAML` header of the `Rmd` files to choose the right parameters for that report.

Additional useful info:
- `params*example.R` are files containing parameters pointing to a small, simple dataset that can be used to test the report code and see how the fully rendered report looks.
- `render.R` is an example of code to render a report while specifying parameters at the time of rendering. This can be used to render a report multiple times using multiple sets of parameters without duplicating the report code. 

### 1. ![](https://img.shields.io/badge/status-stable-green) [quality_assessment](01_quality_assessment/QC.qmd) 👀 [example](https://bcbio.github.io/rnaseq-reports/01_quality_assessment/quality_assessment.html)

This is a report template that uses as input the `nf-core/rnaseq` outputs specified in  [00_params/params.R](00_params/params.R). It also uses helper functions defined in [00_libs/load_data.R](00_libs/load_data.R). This template examines:

On the `YAML` header file of the `qmd` you can specify some parameters or just set them up in the second chunk of code of the template. 

- read metrics
- sample similarity analysis (PCA and hierarchical clustering)
- covariates analysis
  

### 2. ![](https://img.shields.io/badge/status-stable-green) [differential_expression](02_differential_expression/differential_expression.qmd) 👀 [example](https://bcbio.github.io/rnaseq-reports/02_differential_expression/differential_expression.html)

This is a report template for comparison between two groups. It supports multiple contrasts. Like above, it uses as input the `nf-core/rnaseq` outputs specified in [00_params/params.R](00_params/params.R). It also uses helper functions defined in [00_libs/load_data.R](00_libs/load_data.R) and [00_libs/FA.R](00_libs/FA.R).

On the `YAML` header file of the `Rmd` you can specify some parameters or just set them up in the second chunk of code of the template. 

This template has examples of:

- subsetting data
- two groups comparison
- volcano plot
- MA plot
- Pathway analysis: Over-Representation Analysis and Gene-Set-Enrichment Analysis
- Tables

### 3. Comparative analysis

- ![](https://img.shields.io/badge/status-alpha-yellow) [Pair-wise-comparison-analysis](03_comparative/Pair-wise-comparison-analysis.qmd) shows an example on how to compare two differential expression analyses generated using the [DEG](02_differential_expression/differential_expression.qmd) template.
- ![](https://img.shields.io/badge/status-alpha-yellow)  [Intersections](03_comparative/Intersections.qmd) shows an example on how to compare and find intersections between multiple differential expression analyses generated using the [DEG](02_differential_expression/differential_expression.qmd) template.

### 4. Functional analysis

- ![](https://img.shields.io/badge/status-draft-grey) [GSVA](03_functional/GSVA.qmd) shows an example on how to use [GSVA package](https://bioconductor.org/packages/release/bioc/html/GSVA.html) for estimating variation of gene set enrichment through the samples of a expression data set
- ![](https://img.shields.io/badge/status-draft-grey)  [Nonmodel_Organism_Pathway_Analysis](03_functional/Nonmodel_Organism_Pathway_Analysis.qmd) shows an example of how to run Gene Ontology over-representation, KEGG over-representation, and KEGG gene set enrichment analysis (GSEA) for non-model organisms using data from Uniprot. Modify the paths in [params_nonmodel_org_pathways.R](03_functional/params_nonmodel_org_pathways.R) to load the correct input files.
- ![](https://img.shields.io/badge/status-draft-grey)  [Immune-deconvolution](03_functional/Immune-deconvolution.qmd) shows an example of how to run immune cell type deconvolution. Modify the paths in [params_immune_deconv.R](03_functional/params_immune_deconv.R) to load the correct input files.

### 5. Gene pattern analysis 👀[DEGpattern](https://bcbio.github.io/rnaseq-reports/04_gene_patterns/DEGpattern.html) 👀[WGCNA](https://bcbio.github.io/rnaseq-reports/04_gene_patterns/WGCNA.html)

- ![](https://img.shields.io/badge/status-alpha-yellow) [WGCNA](04_gene_patterns/WGCNA.qmd) shows an example on how to use the [WGCNA](https://cran.r-project.org/web/packages/WGCNA/index.html) package to find gene modules in gene expression data.
- ![](https://img.shields.io/badge/status-alpha-yellow) [DEGpattern](04_gene_patterns/DEGpattern.qmd) shows an example of how to cluster a set of genes across conditions and time points to identify specific profiles.



