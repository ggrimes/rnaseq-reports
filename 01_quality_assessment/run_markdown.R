library(rmarkdown)

# set directory to this file folder
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# example running with test data
rmarkdown::render("QC.Rmd",
  output_dir = ".",
  clean = TRUE,
  output_format = "html_document",
  params = list(
    params_file = "../00_params/params-example.R",
    project_file = "../information.R"
  )
)
