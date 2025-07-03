install.packages("BiocManager")
BiocManager::install("renv")
BiocManager::install("omnideconv/immunedeconv")
BiocManager::install(renv::dependencies(path = ".")[["Package"]])

pkgs <- c(renv::dependencies(path = "01_quality_assessment")[["Package"]],
          renv::dependencies(path = "00_libs")[["Package"]])
renv::snapshot(lockfile = "01_quality_assessment/renv.lock",
               packages = pkgs)

pkgs <- c(renv::dependencies(path = "02_differential_expression")[["Package"]],
          renv::dependencies(path = "00_libs")[["Package"]])
renv::snapshot(lockfile = "02_differential_expression/renv.lock",
               packages = pkgs)

renv::snapshot(lockfile = "03_comparative/renv.lock",
               packages = renv::dependencies(path = "03_comparative")[["Package"]])

renv::snapshot(lockfile = "03_functional/renv.lock",
               packages = renv::dependencies(path = "03_functional")[["Package"]])

renv::snapshot(lockfile = "04_gene_patterns/renv.lock",
               packages = renv::dependencies(path = "04_gene_patterns")[["Package"]])
