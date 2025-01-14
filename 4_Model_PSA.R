# Both epi and econ sensitivity

source("0_Inputs_Base.R")

betaParam <- function(mean, se) {
  alpha <- ((1 - mean) / se ^ 2 - 1 / mean) * mean ^ 2
  beta  <- alpha * (1 / mean - 1)
  params <- list(alpha = alpha, beta = beta)
  return(params)
}

gammaParam <- function(mean, se) {
  shape <- (mean ^ 2) / (se ^ 2)
  scale <- (se ^ 2) / mean
  params <- list(shape = shape, scale = scale)
  return(params)
}



### Clean Epi Data ########################################################################################

# Combine all epi data files into one
high_coverage_all <- read.csv("data/high_coverage_scenarios_1_2_7_8_9_10_ALL_clinical_outcomes_totals_1.5-3years.csv")
high_coverage_all$ageScenario <- "No"
low_coverage_all <- read.csv("data/low_coverage_scenarios_5_6_13_14_15_16_ALL_clinical_outcomes_totals_1.5-3years.csv")
low_coverage_all$ageScenario <- "No"
many_boosters_all <- read.csv("data/many_boosters_scenarios_3_4_11_12_high_coverage_ALL_clinical_outcomes_totals_1.5-3years.csv")
many_boosters_all$ageScenario <- "No"

covidData   <- add_row(add_row(high_coverage_all, low_coverage_all), many_boosters_all)
rm(high_coverage_all, low_coverage_all, many_boosters_all)


# More sensible contents
covidData[covidData == "TP_low"]                                <- "low TP"
covidData[covidData == "TP_high"]                               <- "high TP"
covidData[covidData == "80.0%"]                                 <- "80%"
covidData[covidData == "older"]                                 <- "Older"
covidData[covidData == "younger"]                               <- "Younger"
covidData[covidData == "never"]                                 <- "Never"
covidData[covidData == "1.5 (year)"]                            <- "1.50 yr"
covidData[covidData == "1.75 (year)"]                           <- "1.75 yr"
covidData[covidData == "2.0 (year)"]                            <- "2.00 yr"
covidData[covidData == "2.25 (year)"]                           <- "2.25 yr"
covidData[covidData == "2.5 (year)"]                            <- "2.50 yr"
covidData[covidData == "further boosting pediatric"]            <- "Pediatric boosting"
covidData[covidData == "further boosting random"]               <- "Random boosting"
covidData[covidData == "further boosting high risk"]            <- "High-risk boosting"
covidData[covidData == "no further boosting"]                   <- "No further boosting"
covidData[covidData == "high risk boosting"]                    <- "6-monthly boosting"
covidData[covidData == "further primary vaccination pediatric"] <- "Pediatric vaccination"
covidData[covidData == "further primary vaccination random"]    <- "Random vaccination"
covidData[covidData == "no further vaccination"]                <- "No further vaccination"

names(covidData) <- sub('total_deaths_ages_', 'deaths', names(covidData))
names(covidData) <- sub('total_', '', names(covidData))


# Create new column for number of vaccine doses by scenarios
covidData$nVaxDoses <- 0
covidData <- covidData %>%
  mutate(nVaxDoses = replace(nVaxDoses, scenario == "Pediatric boosting",    11000),
         nVaxDoses = replace(nVaxDoses, scenario == "High-risk boosting",    11000),
         nVaxDoses = replace(nVaxDoses, scenario == "Random boosting",       11000),
         nVaxDoses = replace(nVaxDoses, scenario == "Pediatric vaccination", 11000),
         nVaxDoses = replace(nVaxDoses, scenario == "Random vaccination",    11000),
         nVaxDoses = replace(nVaxDoses, scenario == "6-monthly boosting",    33000),
         nVaxDoses = replace(nVaxDoses, population.type  == "Older"   & scenario == "boosting 65+", 11821),
         nVaxDoses = replace(nVaxDoses, population.type  == "Older"   & scenario == "boosting 55+", 21721),
         nVaxDoses = replace(nVaxDoses, population.type  == "Older"   & scenario == "boosting 45+", 32372),
         nVaxDoses = replace(nVaxDoses, population.type  == "Older"   & scenario == "boosting 35+", 42754),
         nVaxDoses = replace(nVaxDoses, population.type  == "Older"   & scenario == "boosting 25+", 53213),
         nVaxDoses = replace(nVaxDoses, population.type  == "Older"   & scenario == "boosting 16+", 61185),
         nVaxDoses = replace(nVaxDoses, population.type  == "Older"   & scenario == "boosting 5+",  70388),
         nVaxDoses = replace(nVaxDoses, population.type  == "Younger" & scenario == "boosting 65+", 3804),
         nVaxDoses = replace(nVaxDoses, population.type  == "Younger" & scenario == "boosting 55+", 9237),
         nVaxDoses = replace(nVaxDoses, population.type  == "Younger" & scenario == "boosting 45+", 16861),
         nVaxDoses = replace(nVaxDoses, population.type  == "Younger" & scenario == "boosting 35+", 26826),
         nVaxDoses = replace(nVaxDoses, population.type  == "Younger" & scenario == "boosting 25+", 39232),
         nVaxDoses = replace(nVaxDoses, population.type  == "Younger" & scenario == "boosting 16+", 51980),
         nVaxDoses = replace(nVaxDoses, population.type  == "Younger" & scenario == "boosting 5+",  70387))

write_csv(covidData, "data/covidData_All.csv")



covidData <- read_csv("data/covidData_All.csv")

### Take average of every 5 rows ########################################################################################

# install.packages("data.table")
library(data.table)
dt <- as.data.table(covidData) # Convert the data frame to a data.table
dt[, group_id := ceiling(.I / 5)] # Create a grouping variable based on row index
avg_dt <- dt[, lapply(.SD, mean, na.rm = TRUE), by = group_id, .SDcols = 12:25] # Calculate average for columns 12:25
first_dt <- dt[, .SD[1, ], by = group_id, .SDcols = c(1:11, 26:28)] # Take the first row values for columns 1:11 and 26:28 in each group
final_dt <- first_dt[avg_dt, on = "group_id"] # Combine the data
final_dt[, group_id.1 := NULL] # Drop the 'group_id' if needed
df_final <- as.data.frame(final_dt) # Convert back to data frame if needed
covidData_ave <- df_final
rm(df_final, final_dt, first_dt, dt, avg_dt)

write_csv(covidData_ave, "data/covidData_All_ave.csv")

##


### Select Epi scenarios for PSA ########################################################################################

# ### Select Epi scenarios for PSA ("All" Epi output methods)
# df <- covidData  %>%
#   filter(population.type=="Older" & immune.escape.starts=="1.50 yr" & transmission.potential.level=="high TP" & 
#            (boosting.starts=="Never" | boosting.starts=="2.00 yr") & 
#            (scenario=="No further boosting" | scenario=="High-risk boosting"))

### Select Epi scenarios for PSA (Average" Epi output methods
covidData_ave <- read_csv("data/covidData_All_ave.csv")

#old immuneescape = 1.5yr
#1 Oler 1.5yr CE
df  <- covidData_ave  %>%
  filter(population.type=="Older" & immune.escape.starts=="1.50 yr" & transmission.potential.level=="high TP" & 
           (boosting.starts=="Never" | boosting.starts=="2.00 yr") & 
           (scenario=="No further boosting" | scenario=="High-risk boosting"))

#2 Older 1.5yr Not CE
df  <- covidData_ave  %>%
  filter(population.type=="Older" & immune.escape.starts=="1.50 yr" & transmission.potential.level=="high TP" & 
           (boosting.starts=="Never" | boosting.starts=="2.00 yr") & 
           (scenario=="No further boosting" | scenario=="Pediatric boosting"))


#3 Younger 1.5 CE
df  <- covidData_ave  %>%
  filter(population.type=="Younger" & immune.escape.starts=="1.50 yr" & transmission.potential.level=="high TP" & 
           (boosting.starts=="Never" | boosting.starts=="2.00 yr") & 
           (scenario=="No further boosting" | scenario=="High-risk boosting"))

#4 Younger 1.5 Not CE
df  <- covidData_ave  %>%
  filter(population.type=="Younger" & immune.escape.starts=="1.50 yr" & transmission.potential.level=="high TP" & 
           (boosting.starts=="Never" | boosting.starts=="2.00 yr") & 
           (scenario=="No further boosting" | scenario=="Pediatric boosting"))
###
#old immuneescape = 2.5yr
#5 Oler 2.5yr CE
df  <- covidData_ave  %>%
  filter(population.type=="Older" & immune.escape.starts=="2.50 yr" & transmission.potential.level=="high TP" & 
           (boosting.starts=="Never" | boosting.starts=="2.00 yr") & 
           (scenario=="No further boosting" | scenario=="High-risk boosting"))

#6 Older 2.5yr Not CE
df  <- covidData_ave  %>%
  filter(population.type=="Older" & immune.escape.starts=="2.50 yr" & transmission.potential.level=="high TP" & 
           (boosting.starts=="Never" | boosting.starts=="2.00 yr") & 
           (scenario=="No further boosting" | scenario=="Pediatric boosting"))


#7 Younger 2.5 CE
df  <- covidData_ave  %>%
  filter(population.type=="Younger" & immune.escape.starts=="2.50 yr" & transmission.potential.level=="high TP" & 
           (boosting.starts=="Never" | boosting.starts=="2.00 yr") & 
           (scenario=="No further boosting" | scenario=="High-risk boosting"))

#8 Younger 2.5 Not CE
df  <- covidData_ave  %>%
  filter(population.type=="Younger" & immune.escape.starts=="2.50 yr" & transmission.potential.level=="high TP" & 
           (boosting.starts=="Never" | boosting.starts=="2.00 yr") & 
           (scenario=="No further boosting" | scenario=="Pediatric boosting"))



### low/med coverage for high-risk boosting in younger population
#med coverage
df  <- covidData_ave  %>%
  filter(population.type=="Younger" & immune.escape.starts=="2.00 yr" & transmission.potential.level=="high TP" & 
           (scenario=="No further vaccination" | scenario=="High-risk boosting") & X1st.year.vaccination.coverage == "50.0%")

#low coverage
df  <- covidData_ave  %>%
  filter(population.type=="Younger" & immune.escape.starts=="2.00 yr" & transmission.potential.level=="high TP" & 
           (scenario=="No further vaccination" | scenario=="High-risk boosting") & X1st.year.vaccination.coverage == "20.0%")


### Calculate Costs and DALYs ########################################################################################
set.seed(123)
covidData_PSA <- data.frame()
runs <- 5

obs <- n_distinct(df$iteration)


for (i in 1:runs){
  
  # Number of vaccine doses
  nVaxDoses    <- df$nVaxDoses
  
  # Scenario identifiers
  popSize      <- df$population.size
  popType      <- df$population.type
  scenario     <- df$scenario
  vaxCoverage  <- df$X1st.year.vaccination.coverage
  tpLevel      <- df$transmission.potential.level
  boostStart   <- df$boosting.starts
  immuneEscape <- df$immune.escape.starts
  timePeriod   <- df$time.period
  ageScenario  <- df$ageScenario
  group        <- ifelse(df$population.type=="Older", "A",
                         ifelse(df$population.type=="Younger" & df$X1st.year.vaccination.coverage !="20.0%", "B",
                                "C"))
  iteration   <- df$iteration
  
  # Categories of COVID-19 health states and deaths
  nAsymptom   <- df$infections_all_ages             - df$symptomatic_infections_all_ages
  nHomecare   <- df$symptomatic_infections_all_ages - df$admissions_all_ages
  nAdmitWard  <- df$admissions_all_ages             - df$ICU_admissions_all_ages
  nAdmitICU   <- df$ICU_admissions_all_ages
  nOccupyWard <- df$ward_occupancy_all_ages
  nOccupyICU  <- df$ICU_occupancy_all_ages
  nDeaths     <- df$deaths_all_ages
  
  # Random draws from specified probability distribution
  # Beta
  param           <- betaParam(mean = dModerate["mean"], se = (dModerate["high"]-dModerate["low"])/(2*1.96))
  dModerate.psa   <- rbeta(obs, param$alpha, param$beta)
  
  param           <- betaParam(mean = dSevere["mean"], se = (dSevere["high"]-dSevere["low"])/(2*1.96))
  dSevere.psa    <- rbeta(obs, param$alpha, param$beta)
  
  param           <- betaParam(mean = dCritical["mean"], se = (dCritical["high"]-dCritical["low"])/(2*1.96))
  dCritical.psa   <- rbeta(obs, param$alpha, param$beta)
  
  param           <- betaParam(mean = dPostacute["mean"], se = (dPostacute["high"]-dPostacute["low"])/(2*1.96))
  dPostacute.psa  <- rbeta(obs, param$alpha, param$beta)
  
  # Gamma
  param           <- gammaParam(mean = cHomeGroupA["mean"], se = (cHomeGroupA["high"]-cHomeGroupA["low"])/(2*1.96))
  cHomeGroupA.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cHomeGroupB["mean"], se = (cHomeGroupB["high"]-cHomeGroupB["low"])/(2*1.96))
  cHomeGroupB.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cHomeGroupC["mean"], se = (cHomeGroupC["high"]-cHomeGroupC["low"])/(2*1.96))
  cHomeGroupC.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cWardGroupA["mean"], se = (cWardGroupA["high"]-cWardGroupA["low"])/(2*1.96))
  cWardGroupA.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cWardGroupB["mean"], se = (cWardGroupB["high"]-cWardGroupB["low"])/(2*1.96))
  cWardGroupB.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cWardGroupC["mean"], se = (cWardGroupC["high"]-cWardGroupC["low"])/(2*1.96))
  cWardGroupC.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cICUGroupA["mean"], se = (cICUGroupA["high"]-cICUGroupA["low"])/(2*1.96))
  cICUGroupA.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cICUGroupB["mean"], se = (cICUGroupB["high"]-cICUGroupB["low"])/(2*1.96))
  cICUGroupB.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cICUGroupC["mean"], se = (cICUGroupC["high"]-cICUGroupC["low"])/(2*1.96))
  cICUGroupC.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cDeliveryA["mean"], se = (cDeliveryA["high"]-cDeliveryA["low"])/(2*1.96))
  cDeliveryA.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cDeliveryB["mean"], se = (cDeliveryB["high"]-cDeliveryB["low"])/(2*1.96))
  cDeliveryB.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cDeliveryC["mean"], se = (cDeliveryC["high"]-cDeliveryC["low"])/(2*1.96))
  cDeliveryC.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cVaxGroupA["mean"], se = (cVaxGroupA["high"]-cVaxGroupA["low"])/(2*1.96))
  cVaxGroupA.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cVaxGroupB["mean"], se = (cVaxGroupB["high"]-cVaxGroupB["low"])/(2*1.96))
  cVaxGroupB.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  param           <- gammaParam(mean = cVaxGroupC["mean"], se = (cVaxGroupC["high"]-cVaxGroupC["low"])/(2*1.96))
  cVaxGroupC.psa <- rgamma(obs, shape=param$shape, scale=param$scale)
  
  # Uniform
  nModerate.psa  <- runif(obs, min = nModerate["low"],  max = nModerate["high"])
  nSevere.psa    <- runif(obs, min = nSevere["low"],    max = nSevere["high"])
  nCritical.psa  <- runif(obs, min = nCritical["low"],  max = nCritical["high"])
  nPostacute.psa <- runif(obs, min = nPostacute["low"], max = nPostacute["high"])
  
  # Calculate Discounted YLLs by age groups and the total YLLs
  yll0.9   <- ifelse(popType=="Older", df$deaths0.9   * (1-exp(-dRate * lifeExpU[1]))/dRate, df$deaths0.9   * (1-exp(-dRate * lifeExpM[1]))/dRate)
  yll10.19 <- ifelse(popType=="Older", df$deaths10.19 * (1-exp(-dRate * lifeExpU[2]))/dRate, df$deaths10.19 * (1-exp(-dRate * lifeExpM[2]))/dRate)
  yll20.29 <- ifelse(popType=="Older", df$deaths20.29 * (1-exp(-dRate * lifeExpU[3]))/dRate, df$deaths20.29 * (1-exp(-dRate * lifeExpM[3]))/dRate)
  yll30.39 <- ifelse(popType=="Older", df$deaths30.39 * (1-exp(-dRate * lifeExpU[4]))/dRate, df$deaths30.39 * (1-exp(-dRate * lifeExpM[4]))/dRate)
  yll40.49 <- ifelse(popType=="Older", df$deaths40.49 * (1-exp(-dRate * lifeExpU[5]))/dRate, df$deaths40.49 * (1-exp(-dRate * lifeExpM[5]))/dRate)
  yll50.59 <- ifelse(popType=="Older", df$deaths50.59 * (1-exp(-dRate * lifeExpU[6]))/dRate, df$deaths50.59 * (1-exp(-dRate * lifeExpM[6]))/dRate)
  yll60.69 <- ifelse(popType=="Older", df$deaths60.69 * (1-exp(-dRate * lifeExpU[7]))/dRate, df$deaths60.69 * (1-exp(-dRate * lifeExpM[7]))/dRate)
  yll70.79 <- ifelse(popType=="Older", df$deaths70.79 * (1-exp(-dRate * lifeExpU[8]))/dRate, df$deaths70.79 * (1-exp(-dRate * lifeExpM[8]))/dRate)
  yll80.   <- ifelse(popType=="Older", df$deaths80.   * (1-exp(-dRate * lifeExpU[9]))/dRate, df$deaths80.   * (1-exp(-dRate * lifeExpM[9]))/dRate)
  yll      <- yll0.9 + yll10.19 + yll20.29 + yll30.39 + yll40.49 + yll50.59 + yll60.69 + yll70.79 + yll80.
  
  # Calculate YLDs by COVID categories and total YLDs
  yldAsymptom  <- 0
  yldHomecare  <- nHomecare  * (dModerate.psa * nModerate.psa)
  yldAdmitWard <- nAdmitWard * (dModerate.psa * nModerate.psa + dSevere.psa * nSevere.psa + 
                                  dPostacute.psa * nPostacute.psa)
  yldAdmitICU  <- nAdmitICU  * (dModerate.psa * nModerate.psa + dSevere.psa * nSevere.psa + 
                                  dCritical.psa * nCritical.psa + dPostacute.psa * nPostacute.psa)
  yld          <- yldAsymptom + yldHomecare + yldAdmitWard + yldAdmitICU 
  
  # Calculate DALYs
  daly  <- yld + yll
  
  # Calculating costs
  costHome    <- ifelse(group=="A", nHomecare * cHomeGroupA.psa, 
                        ifelse(group=="B", nHomecare * cHomeGroupB.psa,
                               ifelse(group=="C", nHomecare * cHomeGroupC.psa,
                                      NA)))
  
  costWard    <- ifelse(group=="A", nOccupyWard * cWardGroupA.psa,
                        ifelse(group=="B", nOccupyWard * cWardGroupB.psa,
                               ifelse(group=="C", nOccupyWard * cWardGroupC.psa,
                                      NA)))
  
  costICU     <- ifelse(group=="A", nOccupyICU * cICUGroupA.psa,
                        ifelse(group=="B", nOccupyICU * cICUGroupB.psa,
                               ifelse(group=="C", nOccupyICU * cICUGroupC.psa,
                                      NA)))
  
  costDoses   <-  ifelse(group=="A", nVaxDoses * (cVaxGroupA.psa + cDeliveryA.psa) * (1 + pVaxWaste[1]),
                         ifelse(group=="B", nVaxDoses * (cVaxGroupB.psa + cDeliveryB.psa) * (1 + pVaxWaste[1]),
                                ifelse(group=="C", nVaxDoses * (cVaxGroupC.psa + cDeliveryC.psa) * (1 + pVaxWaste[1]),
                                       NA)))
  
  costDeath   <- nDeaths * cBodyBag[1]
  
  costDisease <- costHome + costWard + costICU + costDeath 
  
  cost        <- costDisease + costDoses 
  
  
  dfTemp <- data.frame(group, popType, scenario, iteration, vaxCoverage, tpLevel, boostStart, immuneEscape, 
                       ageScenario, yld, yll, daly, costDeath, costDisease, cost)
  
  dfTemp <- dfTemp %>%
    group_by(iteration) %>%
    mutate(daly0 = daly[1], cost0 = cost[1], iDaly = daly0 - daly, iCost = cost - cost0) %>%
    unite(scenarioBoostStart, scenario, boostStart, sep = " at ", remove = FALSE) %>%
    unite(scenarioImmuneEscape, scenario, immuneEscape, sep = ", immune escape ", remove = FALSE) %>%
    unite(scenarioVaxCoverage, scenario, vaxCoverage, sep = ", coverage ", remove = FALSE) %>% 
    filter(iDaly!=0)
  
  covidData_PSA = rbind(covidData_PSA, dfTemp)
  
}

icostPSA <- mean(covidData_PSA$iCost)
idalyPSA <- mean(covidData_PSA$iDaly)
icerPSA <- icostPSA / idalyPSA

print(c("iCost", round(icostPSA,0)))
print(c("iDaly", round(idalyPSA,0)))
print(c("icer", round(icerPSA,0)))

### Cost-effectiveness plane ########################################################################################
cetWoodsA <- c(low=19000, high=30000)
cetWoodsB <- c(low=200,  high=1600)
cetWoodsC <- c(low=100,  high=1000)

cetLowerA  <- annotate("text", y = 150000, x = 500, size=4, label = "CET = $19,000")
cetHigherA <- annotate("text", y = 650000, x = 450,  size=4, label = "CET = $30,000")

cetLowerB  <- annotate("text", y = 150000, x = 500, size=4, label = "CET = $200")
cetHigherB <- annotate("text", y = 650000, x = 450, size=4, label = "CET = $1,600")

cetLowerC  <- annotate("text", y = 100000, x = 375, size=4, label = "CET = $100")
cetHigherC <- annotate("text", y = 650000, x = 375, size=4, label = "CET = $1,000")

units <- function(n) {
  labels <- ifelse(n < -1e9, paste0(round(n/1e6), 'M'),  # less than thousands
                   ifelse(n < 1e6, paste0(round(n/1e3), 'k'),  # in thousands
                          paste0(round(n/1e6, 1), 'M')  # in millions
                   ))
  return(labels)
}

### CE plane for 1.5yr ########################################################################################
#figpsa1/2 (older)
figpsa1 <- ggplot(covidData_PSA) +
  geom_point(aes(x=iDaly, y=iCost), shape=21, size=2.5, 
             stroke=0.5, fill="#FFFFFFEE", color="#ff0000") +
  geom_hline(yintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  geom_vline(xintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  theme_bw() +
  xlab("DALYs averted per 100,000 pop") + 
  ylab("Incremental costs ($) per 100,000 pop") +
  scale_y_continuous(breaks=seq(-450000, 750000, 150000), 
                     limits = c(-450000, 750000), 
                     labels=units) +
  scale_x_continuous(breaks=seq(-600, 600, 200),  limits = c(-600,  600)) +
  theme(axis.title        = element_text(size = 14),
        axis.text         = element_text(size = 10,  color = "black"),
        axis.line         = element_line(linewidth = 0,   color = "white"),
        axis.ticks        = element_line(linewidth = 0.2, color = "black"),
        axis.ticks.length = unit(0.2, "cm"),
        panel.grid.major  = element_line(linewidth = 0.25, colour = "gray97")) +
  geom_abline(intercept = 0, slope = cetWoodsB,  linewidth = 0.3, linetype="dashed") + cetLowerA + cetHigherA
#

figpsa2 <- ggplot(covidData_PSA) +
  geom_point(aes(x=iDaly, y=iCost), shape=21, size=2.5, 
             stroke=0.5, fill="#FFFFFFEE", color="#ff0000") +
  geom_hline(yintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  geom_vline(xintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  theme_bw() +
  xlab("DALYs averted per 100,000 pop") + 
  ylab("Incremental costs ($) per 100,000 pop") +
  scale_y_continuous(breaks=seq(-450000, 750000, 150000), 
                     limits = c(-450000, 750000), 
                     labels=units) +
  scale_x_continuous(breaks=seq(-600, 600, 200),  limits = c(-600,  600)) +
  theme(axis.title        = element_text(size = 14),
        axis.text         = element_text(size = 10,  color = "black"),
        axis.line         = element_line(linewidth = 0,   color = "white"),
        axis.ticks        = element_line(linewidth = 0.2, color = "black"),
        axis.ticks.length = unit(0.2, "cm"),
        panel.grid.major  = element_line(linewidth = 0.25, colour = "gray97")) +
  geom_abline(intercept = 0, slope = cetWoodsB,  linewidth = 0.3, linetype="dashed") + cetLowerA + cetHigherA

### CE plane for younger pop 
#figpsa3/4 (younger)
figpsa3 <- ggplot(covidData_PSA) +
  geom_point(aes(x=iDaly, y=iCost), shape=21, size=2.5, 
             stroke=0.5, fill="#FFFFFFEE", color="#1e90ff") +
  geom_hline(yintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  geom_vline(xintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  theme_bw() +
  xlab("DALYs averted per 100,000 pop") + 
  ylab("Incremental costs ($) per 100,000 pop") +
  scale_y_continuous(breaks=seq(-450000, 750000, 150000), 
                     limits = c(-450000, 750000), 
                     labels=units) +
  scale_x_continuous(breaks=seq(-600, 600, 200),  limits = c(-600,  600)) +
  theme(axis.title        = element_text(size = 14),
        axis.text         = element_text(size = 10,  color = "black"),
        axis.line         = element_line(linewidth = 0,   color = "white"),
        axis.ticks        = element_line(linewidth = 0.2, color = "black"),
        axis.ticks.length = unit(0.2, "cm"),
        panel.grid.major  = element_line(linewidth = 0.25, colour = "gray97")) +
  geom_abline(intercept = 0, slope = cetWoodsB,  linewidth = 0.3, linetype="dashed") + cetLowerB + cetHigherB
#

figpsa4 <- ggplot(covidData_PSA) +
  geom_point(aes(x=iDaly, y=iCost), shape=21, size=2.5, 
             stroke=0.5, fill="#FFFFFFEE", color="#1e90ff") +
  geom_hline(yintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  geom_vline(xintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  theme_bw() +
  xlab("DALYs averted per 100,000 pop") + 
  ylab("Incremental costs ($) per 100,000 pop") +
  scale_y_continuous(breaks=seq(-450000, 750000, 150000), 
                     limits = c(-450000, 750000), 
                     labels=units) +
  scale_x_continuous(breaks=seq(-600, 600, 200),  limits = c(-600,  600)) +
  theme(axis.title        = element_text(size = 14),
        axis.text         = element_text(size = 10,  color = "black"),
        axis.line         = element_line(linewidth = 0,   color = "white"),
        axis.ticks        = element_line(linewidth = 0.2, color = "black"),
        axis.ticks.length = unit(0.2, "cm"),
        panel.grid.major  = element_line(linewidth = 0.25, colour = "gray97")) +
  geom_abline(intercept = 0, slope = cetWoodsB,  linewidth = 0.3, linetype="dashed") + cetLowerB + cetHigherB


plot_grid(figpsa1,  figpsa3, figpsa2, figpsa4, labels = c("(a)","(b)","(c)","(d)"),label_x=0.12,label_y = 0.98, ncol = 2)

ggsave(height=10, width=12, dpi=600, file="plots/figure_psa1.pdf")

### CE plane for 2.5yr ########################################################################################
#figpsa5/6 (older)
figpsa5 <- ggplot(covidData_PSA) +
  geom_point(aes(x=iDaly, y=iCost), shape=21, size=2.5, 
             stroke=0.5, fill="#FFFFFFEE", color="#fa8072") +
  geom_hline(yintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  geom_vline(xintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  theme_bw() +
  xlab("DALYs averted per 100,000 pop") + 
  ylab("Incremental costs ($) per 100,000 pop") +
  scale_y_continuous(breaks=seq(-450000, 750000, 150000), 
                     limits = c(-450000, 750000), 
                     labels=units) +
  scale_x_continuous(breaks=seq(-600, 600, 200),  limits = c(-600,  600)) +
  theme(axis.title        = element_text(size = 14),
        axis.text         = element_text(size = 10,  color = "black"),
        axis.line         = element_line(linewidth = 0,   color = "white"),
        axis.ticks        = element_line(linewidth = 0.2, color = "black"),
        axis.ticks.length = unit(0.2, "cm"),
        panel.grid.major  = element_line(linewidth = 0.25, colour = "gray97")) +
  geom_abline(intercept = 0, slope = cetWoodsB,  linewidth = 0.3, linetype="dashed") + cetLowerA + cetHigherA
#

figpsa6 <- ggplot(covidData_PSA) +
  geom_point(aes(x=iDaly, y=iCost), shape=21, size=2.5, 
             stroke=0.5, fill="#FFFFFFEE", color="#fa8072") +
  geom_hline(yintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  geom_vline(xintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  theme_bw() +
  xlab("DALYs averted per 100,000 pop") + 
  ylab("Incremental costs ($) per 100,000 pop") +
  scale_y_continuous(breaks=seq(-450000, 750000, 150000), 
                     limits = c(-450000, 750000), 
                     labels=units) +
  scale_x_continuous(breaks=seq(-600, 600, 200),  limits = c(-600,  600)) +
  theme(axis.title        = element_text(size = 14),
        axis.text         = element_text(size = 10,  color = "black"),
        axis.line         = element_line(linewidth = 0,   color = "white"),
        axis.ticks        = element_line(linewidth = 0.2, color = "black"),
        axis.ticks.length = unit(0.2, "cm"),
        panel.grid.major  = element_line(linewidth = 0.25, colour = "gray97")) +
  geom_abline(intercept = 0, slope = cetWoodsB,  linewidth = 0.3, linetype="dashed") + cetLowerA + cetHigherA

### CE plane for younger pop 
#figpsa7/8 (younger)
figpsa7 <- ggplot(covidData_PSA) +
  geom_point(aes(x=iDaly, y=iCost), shape=21, size=2.5, 
             stroke=0.5, fill="#FFFFFFEE", color="#87cefa") +
  geom_hline(yintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  geom_vline(xintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  theme_bw() +
  xlab("DALYs averted per 100,000 pop") + 
  ylab("Incremental costs ($) per 100,000 pop") +
  scale_y_continuous(breaks=seq(-450000, 750000, 150000), 
                     limits = c(-450000, 750000), 
                     labels=units) +
  scale_x_continuous(breaks=seq(-600, 600, 200),  limits = c(-600,  600)) +
  theme(axis.title        = element_text(size = 14),
        axis.text         = element_text(size = 10,  color = "black"),
        axis.line         = element_line(linewidth = 0,   color = "white"),
        axis.ticks        = element_line(linewidth = 0.2, color = "black"),
        axis.ticks.length = unit(0.2, "cm"),
        panel.grid.major  = element_line(linewidth = 0.25, colour = "gray97")) +
  geom_abline(intercept = 0, slope = cetWoodsB,  linewidth = 0.3, linetype="dashed") + cetLowerB + cetHigherB
#

figpsa8 <- ggplot(covidData_PSA) +
  geom_point(aes(x=iDaly, y=iCost), shape=21, size=2.5, 
             stroke=0.5, fill="#FFFFFFEE", color="#87cefa") +
  geom_hline(yintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  geom_vline(xintercept=0, linetype="solid", color = "black", linewidth=0.5) +
  theme_bw() +
  xlab("DALYs averted per 100,000 pop") + 
  ylab("Incremental costs ($) per 100,000 pop") +
  scale_y_continuous(breaks=seq(-450000, 750000, 150000), 
                     limits = c(-450000, 750000), 
                     labels=units) +
  scale_x_continuous(breaks=seq(-600, 600, 200),  limits = c(-600,  600)) +
  theme(axis.title        = element_text(size = 14),
        axis.text         = element_text(size = 10,  color = "black"),
        axis.line         = element_line(linewidth = 0,   color = "white"),
        axis.ticks        = element_line(linewidth = 0.2, color = "black"),
        axis.ticks.length = unit(0.2, "cm"),
        panel.grid.major  = element_line(linewidth = 0.25, colour = "gray97")) +
  geom_abline(intercept = 0, slope = cetWoodsB,  linewidth = 0.3, linetype="dashed") + cetLowerB + cetHigherB





plot_grid(figpsa5, figpsa7, figpsa6, figpsa8, labels = c("(e)","(f)","(g)","(h)"),label_x=0.12,label_y = 0.98, ncol = 2)

ggsave(height=10, width=12, dpi=600, file="plots/figure_psa2.pdf")



plot_grid(figpsa1,  figpsa3, figpsa2, figpsa4, figpsa5, figpsa7, figpsa6, figpsa8, labels = c("(a)","(b)","(c)","(d)","(e)","(f)","(g)","(h)"),label_x=0.12,label_y = 0.98, ncol = 2)
ggsave(height=20, width=12, dpi=600, file="plots/figure_psa_combined.pdf")

### Cost-effectiveness acceptability curve ########################################################################################

# Cost-effectiveness acceptability curve
wtpLevels <- seq(0, 40000, by = 100) # Define WTP levels

ceacData <- data.frame(
  WTP = wtpLevels,
  Boost = rep(0, length(wtpLevels)),
  noBoost = rep(0, length(wtpLevels))  # Create ceacData dataframe
) 

# iterate through each WTP level to compute the probabilities
for(i in 1:length(wtpLevels)){
  covidData_PSA$nmb <- wtpLevels[i] * covidData_PSA$iDaly - covidData_PSA$iCost # Compute NMB for all PSA samples
  covidData_PSA$Boost <- ifelse(covidData_PSA$nmb > 0, 1, 0) # Derive binary values based on NMB for "Boost"
  covidData_PSA$noBoost <- ifelse(covidData_PSA$Boost == 1, 0, 1) # Derive binary values based on NMB for "noBoost"
  ceacData$Boost[i] <- mean(covidData_PSA$Boost)   # Compute the probabilities for "Boost" 
  ceacData$noBoost[i] <- mean(covidData_PSA$noBoost)  # Compute the probabilities for "noBoost"
}

### CEAC Plots data ########################################################################################
#remember go back to select epi scenarios first
### main paper
ceac1 <- ceacData
ceac1$strategy <- ("High-risk boosting, immune escape starts 1.5yr, boosting at 2.0yr")
ceac1$population <- ("older")

ceac2 <- ceacData 
ceac2$strategy <- ("Paediatric boosting, immune escape starts 1.5yr, boosting at 2.0yr")
ceac2$population <- ("older")

ceac3 <- ceacData
ceac3$strategy <- ("High-risk boosting, immune escape starts 1.5yr, boosting at 2.0yr")
ceac3$population <- ("younger")

ceac4 <- ceacData
ceac4$strategy <- ("Paediatric boosting, immune escape starts 1.5yr, boosting at 2.0yr")
ceac4$population <- ("younger")
##
ceac5 <- ceacData
ceac5$strategy <- ("High-risk boosting, immune escape starts 2.5yr, boosting at 2.0yr")
ceac5$population <- ("older")

ceac6 <- ceacData 
ceac6$strategy <- ("Paediatric boosting, immune escape starts 2.5yr, boosting at 2.0yr")
ceac6$population <- ("older")

ceac7 <- ceacData
ceac7$strategy <- ("High-risk boosting, immune escape starts 2.5yr, boosting at 2.0yr")
ceac7$population <- ("younger")

ceac8 <- ceacData
ceac8$strategy <- ("Paediatric boosting, immune escape starts 2.5yr, boosting at 2.0yr")
ceac8$population <- ("younger")

ceac <- rbind(ceac1, ceac2, ceac3, ceac4, ceac5, ceac6, ceac7, ceac8)

# write_csv(ceac, "data/ceac_main.csv")

### low/med coverage
ceacMed <- ceacData
ceacMed$strategy <- ("High-risk boost (medium coverage)")

ceacLow <- ceacData
ceacLow$strategy <- ("High-risk boost (low coverage)")

ceac <- rbind(ceacMed, ceacLow)

# write_csv(ceac, "data/ceac_coverage.csv")
