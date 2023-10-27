

## ----eval=FALSE------------------------------------------------------------------------------------
## setwd("YOUR/WORKING/DIRECTORY")


## --------------------------------------------------------------------------------------------------
library(tidyverse)
library(readxl)
library(xts)
library(ggplot2)
library(ggpubr)  # to combine ggplots
library(AER)


## ----echo=FALSE------------------------------------------------------------------------------------
rv_data <- read_xlsx("data/SP500_RV_5min.xlsx")


str(rv_data)


min(rv_data$Date)
max(rv_data$Date)


## Configure as xts dated dataset
rv_data <- xts(rv_data, order.by=as.Date(as.character(rv_data$Date),"%Y%m%d"))

str(rv_data)


head(rv_data$RV)


names(rv_data)


p1 <- ggplot(rv_data,aes(y=RV, x=Index)) + 
  geom_line() + 
  labs(x = "Time",title="S&P500, Realized Volatility") +
  theme_light()

p2 <- ggplot(rv_data,aes(y=RQ, x=Index)) + 
  geom_line() + 
  labs(x = "Time",title="S&P500, Realized Quarticity") +
  theme_light()

ggarrange(p1,p2,nrow = 2, ncol = 1)



## --------------------------------------------------------------------------------------------------
p3 <- ggplot(rv_data,aes(x=RV)) +
  geom_density() + 
  labs(x = "RV",title="S&P500, Density of Realized Volatility") +
  theme_light()
p4 <- ggplot(rv_data,aes(x=RQ)) +
  geom_density() + 
  labs(x = "RQ",title="S&P500, Density of Realized Quarticity") +
  theme_light()
ggarrange(p3,p4,nrow = 2, ncol = 1)


## Transform the RV data
rv_data$logRV <- log(rv_data$RV)
rv_data$srRV <- 2*(sqrt(rv_data$RV)-1)


## --------------------------------------------------------------------------------------------------

p5 <- ggplot(rv_data) +
  geom_density(aes(x=logRV), color="blue", size = 1.5) + 
  geom_density(aes(x=srRV), color="red", size = 1.5) + 
  labs(x = "logRV (blue), srRV (red)",title="S&P500, Density of log and square root Realized Volatility") +
  theme_light()
p5


## Estimate HAR Models
library(highfrequency)


## --------------------------------------------------------------------------------------------------
data_temp <- rv_data[,"RV"]
mod_HAR <- HARmodel(data = data_temp , periods = c(1,5,22), 
              type = "HAR", h = 1, inputType = "RM")
summary(mod_HAR)


## Replicate using the lm function
rv_data$RV1 <- lag.xts(rv_data$RV,1)

rv_data$RV5 <- (lag.xts(rv_data$RV,1)+lag.xts(rv_data$RV,2)+lag.xts(rv_data$RV,3)+
                  lag.xts(rv_data$RV,4)+lag.xts(rv_data$RV,5))/5

rv_data$RV22 <- (lag.xts(rv_data$RV,1)+lag.xts(rv_data$RV,2)+
                  lag.xts(rv_data$RV,3)+lag.xts(rv_data$RV,4)+lag.xts(rv_data$RV,5)+
                  lag.xts(rv_data$RV,6)+lag.xts(rv_data$RV,7)+lag.xts(rv_data$RV,8)+
                  lag.xts(rv_data$RV,9)+lag.xts(rv_data$RV,10)+lag.xts(rv_data$RV,11)+
                  lag.xts(rv_data$RV,12)+lag.xts(rv_data$RV,13)+lag.xts(rv_data$RV,14)+
                  lag.xts(rv_data$RV,15)+lag.xts(rv_data$RV,16)+lag.xts(rv_data$RV,17)+
                  lag.xts(rv_data$RV,18)+lag.xts(rv_data$RV,19)+lag.xts(rv_data$RV,20)+
                  lag.xts(rv_data$RV,21)+lag.xts(rv_data$RV,22))/22


## --------------------------------------------------------------------------------------------------
mod_HAR_vlm <- lm(RV~RV1+RV5+RV22,data=rv_data)
summary(mod_HAR_vlm)


## Apply Newey-West standard errors
coeftest(mod_HAR_vlm, vcov = vcovHAC(mod_HAR_vlm))


## Forecasting
tail(rv_data[,c("RV", "RV1", "RV5", "RV22")])


## --------------------------------------------------------------------------------------------------
predict(mod_HAR)


## Forecasting 5 periods ahead
tail(index(rv_data),6)


## define estimation sample
data_temp <- rv_data[index(rv_data)<="2013-08-23","RV"]

mod_HAR5 <- HARmodel(data = data_temp , periods = c(1,5,22), 
              type = "HAR", h = 5, inputType = "RM")
summary(mod_HAR5)


## check how HARmodel saves model data
tail(mod_HAR5$model,6)



## Pretend call of HARmodel to get the right data structure
data_fore <- rv_data[(4096-40):4096,"RV"]
fore_HAR5 <- HARmodel(data = data_fore , periods = c(1,5,22), 
              type = "HAR", h = 5, inputType = "RM")
tail(fore_HAR5$model,6)


## Feed the data into predict
data_fore<- fore_HAR5$model[nrow(fore_HAR5$model),c("RV1","RV5","RV22")]
data_fore <- as.xts(data_fore)  # when extracting $model the data loose their
                                # xts formatting, we need to add that back
predict(mod_HAR5,newdata = data_fore)


## Pseudo Out-of-Sample forecasting exercise
l <- 22   # max lag in explanatory variables
h <- 1    # forecast horizon
n <- 1000 # estimation sample


## --------------------------------------------------------------------------------------------------
data_temp <- rv_data[1:1022,"RV"] 


## --------------------------------------------------------------------------------------------------
est_start <- 1:3074
est_end <- 1022:4095
est_end_dates <- index(rv_data)[est_end]

est_info <- tibble(est_end_dates,est_start,est_end)
est_samples <- nrow(est_info)  # number of estimation samples


## --------------------------------------------------------------------------------------------------
est_info$beta0_1 <- NA   # four HAR coefficients to be saved
est_info$beta1_1 <- NA
est_info$beta2_1 <- NA
est_info$beta3_1 <- NA
est_info$f1 <- NA
est_info$f1b <- NA
est_info$r1 <- NA


## --------------------------------------------------------------------------------------------------
for(j in 1:est_samples) {
  st <- unlist(est_info[j,"est_start"])   # the unlist argument strips the number
  en <- unlist(est_info[j,"est_end"])     # out of the tibble structure
  
  # Estimate the HAR model
  data_temp <- rv_data[st:en,"RV"] 
  mod_HAR_loop <- HARmodel(data = data_temp , periods = c(1,5,22), 
              type = "HAR", h = 1, inputType = "RM")
  est_info$beta0_1[j] <- mod_HAR_loop$coefficients[1]  # saves the estimated coefficients 
  est_info$beta1_1[j] <- mod_HAR_loop$coefficients[2]  # into est_info
  est_info$beta2_1[j] <- mod_HAR_loop$coefficients[3]
  est_info$beta3_1[j] <- mod_HAR_loop$coefficients[4]
  
  # now forecast one step ahead
  # as demonstrated above we, need the explanatory variable from en+h
  est_info$f1[j] <- predict(mod_HAR_loop,newdata = rv_data[en+h,c("RV1","RV5","RV22")])
  
  # or use the trick
  ## Pretend call of HARmodel to get the right data structure
  data_fore <- rv_data[(en-40):(en+h),"RV"]
  mod_fore <- HARmodel(data = data_fore , periods = c(1,5,22), 
                        type = "HAR", h = 1, inputType = "RM")

  ## Feed the data into predict
  data_fore<- mod_fore$model[nrow(mod_fore$model),c("RV1","RV5","RV22")]
  data_fore <- as.xts(data_fore)  # when extracting $model the data loose their
                                  # xts formatting, we need to add that back
  est_info$f1b[j] <- predict(mod_HAR_loop,newdata = data_fore)
  
  # and we need the realisation from en+h
  est_info$r1[j] <- rv_data[en+1,"RV"]

  
}


## --------------------------------------------------------------------------------------------------
p5 <- ggplot(est_info, aes(y=beta0_1,x=est_end_dates)) +
  geom_line() +
  labs(x = "Time",title="HAR1, beta_0") +
  theme_light()
p6 <- ggplot(est_info, aes(y=beta1_1,x=est_end_dates)) +
  geom_line() +
  labs(x = "Time",title="HAR1, beta_1") +
  theme_light()
p7 <- ggplot(est_info, aes(y=beta2_1,x=est_end_dates)) +
  geom_line() +
  labs(x = "Time",title="HAR1, beta_2") +
  theme_light()
p8 <- ggplot(est_info, aes(y=beta3_1,x=est_end_dates)) +
  geom_line() +
  labs(x = "Time",title="HAR1, beta_3") +
  theme_light()

ggarrange(p5,p6,p7,p8,nrow = 2, ncol = 2)


## --------------------------------------------------------------------------------------------------
p9 <- ggplot(est_info, aes(y=r1,x=est_end_dates)) +
  geom_line() +
  geom_line(aes(y = f1), color = "blue") +
  labs(x = "Time",title="HAR1, forecast and realisation") +
  theme_light()
p9


## --------------------------------------------------------------------------------------------------
MSE = mean((est_info$r1-est_info$f1)^2)
QLIKE = mean(est_info$r1/est_info$f1 - log(est_info$r1/est_info$f1) - 1)

print(paste("MSE = ", MSE))
print(paste("QLIKE = ", QLIKE))



## --------------------------------------------------------------------------------------------------
rv_data$logRV <- log(rv_data$RV)
rv_data$srRV <- 2*(sqrt(rv_data$RV)-1)


## --------------------------------------------------------------------------------------------------
data_temp <- rv_data[,c("srRV")]
mod_HARsq <- HARmodel(data = data_temp , periods = c(1,5,22),
              type = "HAR", h = 1, inputType = "RM")
summary(mod_HARsq)


## --------------------------------------------------------------------------------------------------
data_temp <- rv_data[,c("RV")]
mod_HARsq2 <- HARmodel(data = data_temp , periods = c(1,5,22),
              type = "HAR", h = 1, inputType = "RM", transform = "sqrt")
summary(mod_HARsq2)


## --------------------------------------------------------------------------------------------------
mod_HAR$model[nrow(mod_HAR$model),]
mod_HARsq$model[nrow(mod_HARsq$model),]
mod_HARsq2$model[nrow(mod_HARsq2$model),]


## --------------------------------------------------------------------------------------------------
data_temp <- rv_data[,c("RV","RQ")]
mod_HARQ <- HARmodel(data = data_temp , periods = c(1,5,22), periodsQ = c(1),
              type = "HARQ", h = 1, inputType = "RM")
summary(mod_HARQ)


## --------------------------------------------------------------------------------------------------
data_temp <- rv_data[3074:4095,c("RV","RQ")]
mod_HARQ <- HARmodel(data = data_temp , periods = c(1,5,22), periodsQ = c(1),
              type = "HARQ", h = 1, inputType = "RM")


## --------------------------------------------------------------------------------------------------
data_temp <- rv_data[4056:4096,c("RV","RQ")]
fore_HARQ <- HARmodel(data = data_temp , periods = c(1,5,22), periodsQ = c(1),
              type = "HARQ", h = 1, inputType = "RM")


## --------------------------------------------------------------------------------------------------
fore_HARQ$model[nrow(fore_HARQ$model),]


## --------------------------------------------------------------------------------------------------
data_fore<- fore_HARQ$model[nrow(fore_HARQ$model),c("RV1","RV5","RV22","RQ1")]
data_fore <- as.xts(data_fore)  # when extracting $model the data loose their
                                # xts formatting, we need to add that back
predict(mod_HARQ,newdata = data_fore)


## --------------------------------------------------------------------------------------------------
est_info$fQ1 <- NA
est_info$rQ1 <- NA


## --------------------------------------------------------------------------------------------------
for(j in 1:est_samples) {
  
  # 1) get the estimation sample
  st <- unlist(est_info[j,"est_start"])   # the unlist argument strips the number
  en <- unlist(est_info[j,"est_end"])     # out of the tibble structure
  data_temp <- rv_data[st:en,c("RV","RQ")] 
  
  # 2) Estimate the model
  mod_HARQ_loop <- HARmodel(data = data_temp , periods = c(1,5,22), periodsQ = c(1),
              type = "HARQ", h = 1, inputType = "RM")

  # 3) get the explanatory variables for the forecast
  data_temp <- rv_data[(en-40):(en+1),c("RV","RQ")]
  fore_HARQ_loop <- HARmodel(data = data_temp , periods = c(1,5,22), periodsQ = c(1),
              type = "HARQ", h = 1, inputType = "RM")
  data_fore <- fore_HARQ_loop$model[nrow(fore_HARQ_loop$model),c("RV1","RV5","RV22","RQ1")]
  data_fore <- as.xts(data_fore)  
                               
  # 4) forecast and save results
  est_info$fQ1[j] <- predict(mod_HARQ_loop,newdata = data_fore)
  est_info$rQ1[j] <- rv_data[en+1,"RV"]

}


## --------------------------------------------------------------------------------------------------
p10 <- ggplot(est_info, aes(y=rQ1,x=est_end_dates)) +
  geom_line() +
  geom_line(aes(y = fQ1), color = "blue") +
  geom_line(aes(y = f1), color = "red") +
  labs(x = "Time",title="HARQ1, forecast and realisation") +
  theme_light()
p10


## --------------------------------------------------------------------------------------------------
MSE_Q = mean((est_info$rQ1-est_info$fQ1)^2)
QLIKE_Q = mean(est_info$rQ1/est_info$fQ1 - log(est_info$rQ1/est_info$fQ1) - 1)


print(paste("MSE_Q = ", MSE_Q))
print(paste("QLIKE_Q = ", QLIKE_Q))
print(paste("MSE = ", MSE))
print(paste("QLIKE = ", QLIKE))
print(paste("MSE_Q/MSE = ", MSE_Q/MSE))
print(paste("QLIKE_Q/QLIKE = ", QLIKE_Q/QLIKE))


