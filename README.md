
Templates with ![](https://img.shields.io/badge/status-stable-green) revision indicates that the components or processes have undergone comprehensive parameterization and testing.

Templates with ![](https://img.shields.io/badge/status-alpha-yellow) revision indicates that the components or processes are currently being tested. There is some test data available, but there are parameters that need to be set up manually within the code.

Templates with ![](https://img.shields.io/badge/status-draft-grey) revision indicates that the components or processes are not fully tested. There is no test data available, parameters need to be set up manually within the code, and specific code changes are required based on the data used.

# Guidelines for RNAseq downstream analysis

- Set the working directory to the directory containing this README. We recommend to use **Projects** in Rstudio.
- Use `install_dependencies.R` to install all packages used in these reports.

## Run data with nf-core rnaseq

These templates assume that the raw data has been processed by [nf-core/rnaseq](https://nf-co.re/rnaseq/3.14.0/docs/usage).
We recommend using the `samplesheet.csv` used with nf-core as a metadata or coldata file when applicable. This CSV can contain additional columns of relevant information even if these columns are not required or used by `nf-core/rnaseq`.

## Downstream analysis

Before using any template:
- **Modify** `information.R` with the right information. You can use this file with any other Rmd to include the project/analysis information.
- **Modify** `00_params/params.R` with the locations of select files/folders from the output of [nf-core/rnaseq](https://nf-co.re/rnaseq/3.14.0/docs/output). These nf-core outputs will become inputs to various templates.

Additional useful info:
- `params*example.R` are parameters pointing to test data to be used as an example to test the report code and see how the fully rendered report looks.
- `run_markdown.R` is an example of code to render a report while specifying parameters at the time of rendering. This can be used multiple times to render the same report using multiple sets of parameters. 

### Quality assessment

![](https://img.shields.io/badge/status-stable-green) `01_quality_assessment/QC.Rmd` is a report template that uses as input the `nf-core/rnaseq` outputs specified in  `00_params/params.R`. This template examines:

- read metrics
- sample similarity analysis (PCA and hierarchical clustering)
- covariates analysis
  
### Differential expression

![](https://img.shields.io/badge/status-stable-green) `02_differential_expression/DEG.Rmd` is a report template for comparison between two groups. It supports multiple contrasts. Like `01_quality_assessment/QC.Rmd`, it uses as input the `nf-core/rnaseq` outputs specified in `00_params/params.R`.

On the `YAML` header file of the `Rmd` you can specify some parameters or just set them up in the first chunk of code of the template. 

This template has examples of:

- sub-setting data
- two groups comparison
- volcano plot
- MA plot
- Pathway analysis: Over-Representation Analysis and Gene-Set-Enrichment Analysis
- Tables

### Comparative analysis

- ![](https://img.shields.io/badge/status-alpha-yellow) `03_comparative/Pair-wise-comparison-analysis.Rmd` shows an example on how to compare two differential expression analyses generated using the `DEG.Rmd` template.
- ![](https://img.shields.io/badge/status-alpha-yellow)  `03_comparative/Intersections.Rmd` shows an example on how to compare and find intersections between multiple differential expression analyses generated using the `DEG.Rmd` template.

### Functional analysis

- ![](https://img.shields.io/badge/status-draft-grey) `03_functional/GSVA.Rmd` shows an example on how to use [GSVA package](https://bioconductor.org/packages/release/bioc/html/GSVA.html) for estimating variation of gene set enrichment through the samples of a expression data set
- ![](https://img.shields.io/badge/status-draft-grey)  `03_functional/Nonmodel_Organism_Pathway_Analysis.Rmd` shows an example of how to run Gene Ontology over-representation, KEGG over-representation, and KEGG gene set enrichment analysis (GSEA) for non-model organisms using data from Uniprot. Modify the paths in `params_nonmodel_org_pathways.R` to load the correct input files.
- ![](https://img.shields.io/badge/status-draft-grey)  `03_functional/Immune-deconvolution.Rmd` shows an example of how to run immune cell type deconvolution. Modify the paths in `params_immune_deconv.R` to load the correct input files.

### Gene pattern analysis

- ![](https://img.shields.io/badge/status-alpha-yellow) `04_gene_patterns/WGCNA.Rmd` shows an example on how to use the [WGCNA](https://cran.r-project.org/web/packages/WGCNA/index.html) package to find gene modules in gene expression data.
- ![](https://img.shields.io/badge/status-alpha-yellow) `04_gene_patterns/DEGpatterns.Rmd` shows an example of how to cluster a set of genes across conditions and time points to identify specific profiles.



