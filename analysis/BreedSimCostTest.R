## ----setup, include=FALSE-----------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ----load packages, message=FALSE---------------------------------------------------------------
ip <- installed.packages()
packages_used <- c("AlphaSimR", "dplyr",
                   "workflowr", "here", "devtools")
for (package in packages_used){
  if (!(package %in% ip[,"Package"])) install.packages(package)
}
library(dplyr)

packages_devel <- c("BreedSimCost")
for (package in packages_devel){
  if (!(package %in% ip[,"Package"])){
    devtools::install_github(paste0("jeanlucj/", package), ref="main",
                             build_vignettes=F)
  }
}
library(BreedSimCost)

here::i_am("analysis/BreedSimCostTest.R")

random_seed <- 56789
set.seed(random_seed)


## ----Initialize program-------------------------------------------------------------------------
bsd <- initializeProgram(
         here::here("data", "FounderCtrlFile.txt"),
         here::here("data", "SchemeCtrlFile.txt"),
         here::here("data", "CostsCtrlFile.txt"),
         here::here("data", "OptimizationCtrlFile.txt")
                         )


## ----Fill variety development pipeline----------------------------------------------------------
# Year 1
bsd$year <- bsd$year+1
bsd <- makeVarietyCandidates(bsd)

bsd$entries <- bsd$varietyCandidates@id
bsd <- runVDPtrial(bsd, "SDN")

parents <- selectParentsBurnIn(bsd)
bsd <- makeCrossesBurnIn(bsd, parents)

# Year 2
bsd$year <- bsd$year+1
bsd <- makeVarietyCandidates(bsd)

bsd <- chooseTrialEntries(bsd, toTrial="SDN")
bsd <- runVDPtrial(bsd, "SDN")
bsd <- chooseTrialEntries(bsd, fromTrial="SDN", toTrial="CET")
bsd <- runVDPtrial(bsd, "CET")

parents <- selectParentsBurnIn(bsd)
bsd <- makeCrossesBurnIn(bsd, parents)

# Year 3 and onward
for (burnIn in 1:bsd$nBurnInCycles){
  bsd$year <- bsd$year+1
  bsd <- makeVarietyCandidates(bsd)

  bsd <- chooseTrialEntries(bsd, toTrial="SDN")
  bsd <- runVDPtrial(bsd, "SDN")
  bsd <- chooseTrialEntries(bsd, fromTrial="SDN", toTrial="CET")
  bsd <- runVDPtrial(bsd, "CET")
  bsd <- chooseTrialEntries(bsd, fromTrial="CET", toTrial="PYT")
  bsd <- runVDPtrial(bsd, "PYT")

  parents <- selectParentsBurnIn(bsd)
  bsd <- makeCrossesBurnIn(bsd, parents)
}
plot(AlphaSimR::gv(bsd$varietyCandidates))

burnedInBSD <- bsd

nRepeats <- 2
burnedInBSD$nCores <- 10
perc1 <- c(0.1, 0.2, 0.3, 0.4)
perc2 <- c(0.4, 0.3, 0.2, 0.1)
batch1 <- batch2 <- list()
for (i in 1:nRepeats){
  batch1 <- c(batch1, list(perc1))
  batch2 <- c(batch2, list(perc2))
}

burnedInBSD$nCyclesToRun <- 5
gains1 <- runBatch(batch1, burnedInBSD)
print(colMeans(gains1[,5:10]))

gains2 <- runBatch(batch2, burnedInBSD)
print(colMeans(gains2[,5:10]))

burnedInBSD$nCyclesToRun <- 12
gains3 <- runBatch(batch1, burnedInBSD)
print(colMeans(gains3[,5:10]))

gains4 <- runBatch(batch2, burnedInBSD)
print(colMeans(gains4[,5:10]))

saveRDS(list(gains1, gains2, gains3, gains4),
        here::here("output", "gain1to4.rds"))

tst <- readRDS(here::here("output", "gain1to4AM.rds"))
summarizeGain <- function(gainTab){
  gsd <- apply(gainTab[,5:10], 2, sd)
  gmn <- apply(gainTab[,5:10], 2, mean)
  return(list(gmn, gsd))
}
print(lapply(tst, summarizeGain))

stop("Stop four gains test")
## ----runWithBudget, eval=FALSE------------------------------------------------------------------
## # This is code from the package that you can run
## # In the package, it's in the function runWithBudget
##   startValues <- calcCurrentStatus(bsd)
##
##   for (twoPart in 1:bsd$nCyclesToRun){
##     bsd$year <- bsd$year+1
##     bsd <- makeVarietyCandidates(bsd)
##
##     # Within the year, sequentially run the VDP...
##     for (stage in 1:bsd$nStages){
##       bsd <- chooseTrialEntries(bsd, toTrial=bsd$stageNames[stage],
##                    fromTrial=ifelse(stage == 1, NULL, bsd$stageNames[stage-1]))
##       bsd <- runVDPtrial(bsd, bsd$stageNames[stage])
##     }
##
##     # ... And then run the PIC. Sequencing could be made more complicated
##     for (genSel in 1:bsd$nPopImpCycPerYear){
##       optCont <- selectParents(bsd)
##       bsd <- makeCrosses(bsd, optCont)
##     }
##   }
##
##   endValues <- calcCurrentStatus(bsd)
##
##   print(startValues)
##   print(endValues)


## ----Cost optimization, message=FALSE-----------------------------------------------------------
bsd <- burnedInBSD
optimizationResults <- optimizeByLOESS(bsd)
saveRDS(optimizationResults, here::here("data", "_optRes.rds"))


## ----Plot results, results='hold'---------------------------------------------------------------
plp <- plotLoessPred(resultMat=optimizationResults$results)
bestPerc <- plp$percMean
cat(" Budget allocations with highest gain\n", round(unlist(bestPerc), 3), "\n")
bsd <- burnedInBSD
nBurnInInd <- AlphaSimR::nInd(bsd$varietyCandidates)
bsd <- runWithBudget(bestPerc, bsd, returnBSD=T)
rangeGV <- range(AlphaSimR::gv(bsd$varietyCandidates))
plot(AlphaSimR::gv(bsd$varietyCandidates))
lines(c(nBurnInInd, nBurnInInd), rangeGV, lwd=3, col="red")

