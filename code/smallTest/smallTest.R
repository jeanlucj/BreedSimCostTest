library(BreedSimCost)
## ----Initialize program
bsd <- initializeProgram("stFounderCtrlFile.txt",
                         "stSchemeCtrlFile.txt",
                         "stCostsCtrlFile.txt",
                         "stOptimizationCtrlFile.txt")

## ----Fill variety development pipeline
## # Year 1
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

bsd <- runWithBudget(c(0.1, 0.2, 0.3, 0.4), bsd, returnBSD=T)
pdf(file="smallTest.pdf")
  plot(AlphaSimR::gv(bsd$varietyCandidates))
dev.off()

