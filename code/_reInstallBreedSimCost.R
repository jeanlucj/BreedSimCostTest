ip <- installed.packages()
"BreedSimCost" %in% rownames(ip)
if ("BreedSimCost" %in% rownames(ip)){
  remove.packages("BreedSimCost")
}

local <- TRUE
buildVignettes <- FALSE
if (local){
  setwd("~/Documents/GitRepo/BreedSimCost")
  devtools::document()
  devtools::install_local(getwd(), build_vignettes=buildVignettes)
} else{
  # install.packages("devtools")
  devtools::install_github("jeanlucj/BreedSimCost", 
                           ref="master", build_vignettes=buildVignettes)
}
