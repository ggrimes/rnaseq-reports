install.packages("BiocManager")
BiocManager::install("renv")
BiocManager::install(renv::dependencies(path = ".")[["Package"]])

renv::snapshot(lockfile = "01_quality_assessment/renv.lock",
               packages = renv::dependencies(path = "01_quality_assessment")[["Package"]])
