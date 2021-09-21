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
                           ref="main", build_vignettes=buildVignettes)
}

# If you have a list put all its contents in .GlobalEnv
for (n in names(bts)) assign(n, bts[[n]], envir=.GlobalEnv)
for (n in names(fff)) assign(n, fff[[n]], envir=.GlobalEnv)
for (n in names(obl)) assign(n, obl[[n]], envir=.GlobalEnv)
for (n in names(frb)) assign(n, frb[[n]], envir=.GlobalEnv)
for (n in names(rwb)) assign(n, rwb[[n]], envir=.GlobalEnv)
for (n in names(rb)) assign(n, rb[[n]], envir=.GlobalEnv)
for (n in names(cte)) assign(n, cte[[n]], envir=.GlobalEnv)

# Make an R script out of the .Rmd
knitr::purl("~/Documents/GitRepo/BreedSimCostTest/analysis/BreedSimCostTest.Rmd",
            output="~/Documents/GitRepo/BreedSimCostTest/analysis/RunBreedSimCost.R",
            documentation=1)
