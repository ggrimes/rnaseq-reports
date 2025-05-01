library(rmarkdown)

# set directory to this file folder
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# example running with test data
quarto::quarto_render(
  input = "QC.qmd",
  output_dir = ".",
  execute_params = list(
    params_file = "../00_params/params-example.R",
    project_file = "../information.R"
  )
)
