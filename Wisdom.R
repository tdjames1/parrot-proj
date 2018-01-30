# Wisdom et al. 2000 
# life stage simulation analysis: estimating vital-rate effects on population growth for conservation 
library(dplyr)
library(ggplot2) 
library(knitr)
library(primer)
library(Rmisc)
library(agricolae) 
chicken <- read.csv("chicken means sd .csv")
View(chicken)
tortoise <- read.csv("desert tortoise means sd .csv")
View(tortoise)

################################################################ Steps 1-2 (as labelled in original paper)
#Creating a stage-based projection matrix for desert tortoise 
lifetable <- tortoise
tortoiseFunc <- function (lifetable) 
{
  sx <- select(lifetable, s)
  gx <- select(lifetable, g)
  diags <- (sx*(1-gx))
  offdiags <- (sx*gx)
  matrix1 <- matrix(0, nrow = 8, ncol = 8)
  #add Fs
  matrix1[1,] <- lifetable$m 
  #add Ps (diagonals)
  matrix1[2,2] <- diags$s[2] 
  matrix1[3,3] <- diags$s[3]
  matrix1[4,4] <- diags$s[4]
  matrix1[5,5] <- diags$s[5]
  matrix1[6,6] <- diags$s[6]
  matrix1[7,7] <- diags$s[7]
  matrix1[8,8] <- diags$s[8]
  matrix1
  #add Gs (off-diagonals)
  matrix1[2,1] <- sx$s[1]
  matrix1[3,2] <- offdiags$s[2]
  matrix1[4,3] <- offdiags$s[3]
  matrix1[5,4] <- offdiags$s[4]
  matrix1[6,5] <- offdiags$s[5]
  matrix1[7,6] <- offdiags$s[6] 
  matrix1[8,7] <- offdiags$s[7] 
  #remove NAs
  #shows location of NAs
  is.na(matrix1)
  #replaces NAs with 0s
  matrix1[is.na(matrix1)] <- 0
  matrix1#almost there 
  return(matrix1)
}

tort_matrix <- tortoiseFunc(tortoise) 
tort_matrix #matrix with mean valyes 

#Creating a stage-based projection matrix for prairie chicken 
lifetable <- chicken 
chickenFunc <- function (lifetable) 
{
  sxc <- select(lifetable, s) #c in sxc and mxc stands for chicken 
  mxc <- select(lifetable, m)
  matrix2 <- matrix(0, nrow = 4, ncol = 4)
  #add sxmx
  matrix2[1,1] <- ((sxc$s[1])*(mxc$m[5])) #numbers look weird because data is in 8 age classes, this matrix is 4x4 (see appendix pg 641)
  matrix2[1,2] <- ((sxc$s[5])*(mxc$m[6])) 
  matrix2[1,3] <- ((sxc$s[6])*(mxc$m[7]))
  matrix2[1,4] <- ((sxc$s[7])*(mxc$m[7]))
  #add s
  matrix2[2,1] <- sxc$s[1]
  matrix2[3,2] <- sxc$s[5] #numbers look weird because data is in 8 age classes, this matrix is 4x4 (see appendix pg 641)
  matrix2[4,3] <- sxc$s[6]
  matrix2[4,4] <- sxc$s[7]
  matrix2
  return(matrix2)
}

chickenFunc(chicken) 

############ Application 1: simulated elasticity and regression metrics 
#1 random selection of vital rates 
#tortoise 
#s
s1 <- rnorm(100, mean = (tortoise$s[1]), sd = (tortoise$ssd[1])) # presumably an r-norm distribution 
s2 <- rnorm(100, mean = (tortoise$s[2]), sd = (tortoise$ssd[2])) # needs to be a Beta distrubtion for all rates other than reproductive
s3 <- rnorm(100, mean = (tortoise$s[3]), sd = (tortoise$ssd[3])) # rates which need to be sampled from a log-normal distribution 
s4 <- rnorm(100, mean = (tortoise$s[4]), sd = (tortoise$ssd[4])) # presumably can keep most of code and just change function
s5 <- rnorm(100, mean = (tortoise$s[5]), sd = (tortoise$ssd[5])) # outside of the brackets? 
s6 <- rnorm(100, mean = (tortoise$s[6]), sd = (tortoise$ssd[6])) #have googled a beta function but confused by the shape parameter bit 
s7 <- rnorm(100, mean = (tortoise$s[7]), sd = (tortoise$ssd[7]))
s8 <- rnorm(100, mean = (tortoise$s[8]), sd = (tortoise$ssd[8]))
rbeta(100, shape1 = (tortoise$s[1]), shape2 = (tortoise$ssd[1]))#use rbeta function? maybe shape 1 = minimum shape 2 = maxmimum 
#g 
g1 <- rnorm(100, mean = (tortoise$g[1]), sd = (tortoise$gsd[1])) 
g2 <- rnorm(100, mean = (tortoise$g[2]), sd = (tortoise$gsd[2]))
g3 <- rnorm(100, mean = (tortoise$g[3]), sd = (tortoise$gsd[3]))
g4 <- rnorm(100, mean = (tortoise$g[4]), sd = (tortoise$gsd[4]))
g5 <- rnorm(100, mean = (tortoise$g[5]), sd = (tortoise$gsd[5]))
g6 <- rnorm(100, mean = (tortoise$g[6]), sd = (tortoise$gsd[6]))
g7 <- rnorm(100, mean = (tortoise$g[7]), sd = (tortoise$gsd[7]))
g8 <- rnorm(100, mean = (tortoise$g[8]), sd = (tortoise$gsd[8]))
#m
m6 <- rnorm(100, mean = (tortoise$m[6]), sd = (tortoise$msd[6]))
m7 <- rnorm(100, mean = (tortoise$m[7]), sd = (tortoise$msd[7]))
m8 <- rnorm(100, mean = (tortoise$m[8]), sd = (tortoise$msd[8]))

#chicken 
#s
sc1 <- rnorm(100, mean = (chicken$s[1]), sd = 0.129) #0.129 is mean standard deviation for stage 1, didn't know how to correctly calculate ssd for 
sc2 <- rnorm(100, mean = (chicken$s[5]), sd = (chicken$ssd[5])) # this stage as the survival is from the multiplication of  s1a, s1b and s1c
sc3<- rnorm(100, mean = (chicken$s[6]), sd = (chicken$ssd[6]))
sc4 <- rnorm(100, mean = (chicken$s[7]), sd = (chicken$ssd[7]))
#m 
mc2 <- rnorm(100, mean = (chicken$m[5]), sd = (chicken$msd[5]))
mc3 <- rnorm(100, mean = (chicken$m[6]), sd = (chicken$msd[6]))
mc4 <- rnorm(100, mean = (chicken$m[7]), sd = (chicken$msd[7]))
mc5 <- rnorm(100, mean = (chicken$m[7]), sd = (chicken$msd[7]))

############ making a function which produces a matrix based on randomly selected vital rates 
chickFunc <- function (chicken) 
{ sc1 <- rnorm(1, mean = (chicken$s[1]), sd = 0.0129)  
sc2 <- rnorm(1, mean = (chicken$s[5]), sd = (chicken$ssd[5])) 
sc3 <- rnorm(1, mean = (chicken$s[6]), sd = (chicken$ssd[6]))
sc4 <- rnorm(1, mean = (chicken$s[7]), sd = (chicken$ssd[7]))
#m 
mc2 <- rnorm(1, mean = (chicken$m[5]), sd = (chicken$msd[5]))
mc3 <- rnorm(1, mean = (chicken$m[6]), sd = (chicken$msd[6]))
mc4 <- rnorm(1, mean = (chicken$m[7]), sd = (chicken$msd[7]))
mc5 <- rnorm(1, mean = (chicken$m[7]), sd = (chicken$msd[7]))
matrix2 <- matrix(0, nrow = 4, ncol = 4)
#add sxmx
matrix2[1,1] <- (sc1*mc2) 
matrix2[1,2] <- (sc2*mc3)
matrix2[1,3] <- (sc3*mc4)
matrix2[1,4] <- (sc4*mc5)
#add s(mxc$m[7]))
matrix2[2,1] <- sc1
matrix2[3,2] <- sc2
matrix2[4,3] <- sc3
matrix2[4,4] <- sc4
return(matrix2)
}

chickFunc(chicken) #chickFunc returns a different matrix each time 

tortFunc <- function(tortoise)
{ #s
  s1 <- rnorm(1, mean = (tortoise$s[1]), sd = (tortoise$ssd[1])) # presumably an r-norm distribution 
  s2 <- rnorm(1, mean = (tortoise$s[2]), sd = (tortoise$ssd[2])) # needs to be a Beta distrubtion for all rates other than reproductive
  s3 <- rnorm(1, mean = (tortoise$s[3]), sd = (tortoise$ssd[3])) # rates which need to be sampled from a log-normal distribution 
  s4 <- rnorm(1, mean = (tortoise$s[4]), sd = (tortoise$ssd[4])) # presumably can keep most of code and just change function
  s5 <- rnorm(1, mean = (tortoise$s[5]), sd = (tortoise$ssd[5])) # outside of the brackets? 
  s6 <- rnorm(1, mean = (tortoise$s[6]), sd = (tortoise$ssd[6])) #have googled a beta function but confused by the shape parameter bit 
  s7 <- rnorm(1, mean = (tortoise$s[7]), sd = (tortoise$ssd[7]))
  s8 <- rnorm(1, mean = (tortoise$s[8]), sd = (tortoise$ssd[8]))
  #g 
  g2 <- rnorm(1, mean = (tortoise$g[2]), sd = (tortoise$gsd[2]))
  g3 <- rnorm(1, mean = (tortoise$g[3]), sd = (tortoise$gsd[3]))
  g4 <- rnorm(1, mean = (tortoise$g[4]), sd = (tortoise$gsd[4]))
  g5 <- rnorm(1, mean = (tortoise$g[5]), sd = (tortoise$gsd[5]))
  g6 <- rnorm(1, mean = (tortoise$g[6]), sd = (tortoise$gsd[6]))
  g7 <- rnorm(1, mean = (tortoise$g[7]), sd = (tortoise$gsd[7]))
  #m
  m6 <- rnorm(1, mean = (tortoise$m[6]), sd = (tortoise$msd[6]))
  m7 <- rnorm(1, mean = (tortoise$m[7]), sd = (tortoise$msd[7]))
  m8 <- rnorm(1, mean = (tortoise$m[8]), sd = (tortoise$msd[8]))
  #make matrix
  matrix1 <- matrix(0, nrow = 8, ncol = 8)
  #add Fs
  matrix1[1,6] <- m6
  matrix1[1,7] <- m7
  matrix1[1,8] <- m8
  #add Ps (diagonals)
  matrix1[2,2] <- (s2*(1-g2)) 
  matrix1[3,3] <- (s3*(1-g3)) 
  matrix1[4,4] <- (s4*(1-g4)) 
  matrix1[5,5] <- (s5*(1-g5)) 
  matrix1[6,6] <- (s6*(1-g6)) 
  matrix1[7,7] <- (s7*(1-g7)) 
  matrix1[8,8] <- s8 
  matrix1
  #add Gs (off-diagonals)
  matrix1[2,1] <- s1
  matrix1[3,2] <- s2*g2
  matrix1[4,3] <- s3*g3
  matrix1[5,4] <- s4*g4
  matrix1[6,5] <- s5*g5
  matrix1[7,6] <- s6*g6
  matrix1[8,7] <- s7*g7
  #remove NAs
  #shows location of NAs
  is.na(matrix1)
  #replaces NAs with 0s
  matrix1[is.na(matrix1)] <- 0
  matrix1#almost there 
  return(matrix1)}

tortFunc(tortoise) #tortFunc returns a different matrix each time 

############################################################################ Step 3
#the process is excecuted 1000 times, resulting in 1000 matrix replicates
# of vital rates and matrix elements for a given species 

############################################################################ Step 4 
#lambda and lower level elasticities associated with each vital rate 
# calculated at a stable stage ditribution

############################################################################ Step 5
#Data across replicates were analyzed to estimate effects of each 
# vtial rate on lambda 
