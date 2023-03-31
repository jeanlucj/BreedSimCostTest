alpha <- c(0.1, 0.2, 0.2)
vdpCovMat <- calcVDPcovMat(bsd)
vdpCorMat <- cov2cor(vdpCovMat)
truncPts <- multistageTrucPt(alpha=alpha, corr=vdpCorMat)
gain <- multistageGain(corr=vdpCorMat, truncPts=truncPts)
allRes1 <- allRes2 <- allRes3 <- NULL
nSamples <- 1000000
for (i in 1:100){
  t5 <- mvtnorm::rmvnorm(nSamples, sigma=vdpCorMat)
  nSamp <- nSamples

  idx1 <- nSamp*(1-alpha[1])+1
  t5o <- order(t5[,2])
  allRes1 <- rbind(allRes1, t5[t5o[idx1],])
  t6 <- t5[t5o[idx1:nSamp],]
  nSamp <- nSamp * alpha[1]
  
  idx2 <- nSamp*(1-alpha[2])+1
  t6o <- order(t6[,3])
  allRes2 <- rbind(allRes2, t6[t6o[idx2],])
  t7 <- t6[t6o[idx2:nSamp],]
  nSamp <- nSamp * alpha[2]
  
  idx3 <- nSamp*(1-alpha[3])+1
  t7o <- order(t7[,4])
  allRes3 <- rbind(allRes3, t7[t7o[idx3],])
  allSamp3 <- rbind(allRes3, t7[t7o[idx3:nSamp],])
  cat(".")
}
cat("\n")
print(colMeans(allRes1)[2])
print(colMeans(allRes2)[3])
print(colMeans(allRes3)[4])
print(colMeans(allSamp3)[1])

tmvtnorm::mtmvnorm(sigma=vdpCorMat, lower=c(-Inf, truncPts))
