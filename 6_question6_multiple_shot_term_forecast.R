library(forecast)

MetGlobalData<-read.csv(file.choose(), header=TRUE, sep=",")
MetGlobal_msts <- msts(MetGlobalData$anomaly_c, seasonal.periods=c(12,48))

###############################
#######10-YEAR ACCURACY########
###############################
# Naive Accuracy for CV
accuracy.naive = 0 
for (i in 1:10) {
  idx <- which(MetGlobalData$month == "1999-12-01")
  idx <- idx + ((i-1)*12)
  naiveStart <- time(MetGlobal_msts)[idx-12]
  naiveForecast <- rep(mean(window(MetGlobalData$anomaly_c, start=idx-12 , end=idx )), each = 12) #create naive predictions
#  naiveForecast <- rep(MetGlobalData$anomaly_c[idx], each = 12) #create naive predictions
  
  idxStart <- time(MetGlobal_msts)[idx+1]
  idxEnd <- time(MetGlobal_msts)[idx+12]
  
  actuals <- window(MetGlobal_msts, start=idxStart , end=idxEnd)
  mae <- mean(abs(naiveForecast-actuals)) #MAE for naive forecast  
  mae <- as.numeric(mae)
  accuracy.naive<-append(accuracy.naive,mae)
  print(accuracy.naive)
}

accuracy.naive<-accuracy.naive[-1]

# ARIMA accuracy CV
accuracy.arima=0 
for (i in 1:10)  {
  
  idx <- which(MetGlobalData$month == "1999-12-01")
  idx <- idx + ((i-1)*12)
  idxTrainEnd <- time(MetGlobal_msts)[idx]
  
  idxTestStart <- time(MetGlobal_msts)[idx+1]
  idxTestEnd <- time(MetGlobal_msts)[idx+12]
  
  train <- window(MetGlobal_msts, start=1 , end=idxTrainEnd)
  test <- window(MetGlobal_msts, start=idxTestStart , end=idxTestEnd)
  
  trainlm <- tslm(train ~ trend + season)
  trainlmf <- forecast(trainlm,h=12)
  
  residauto <- auto.arima(trainlm$residuals)
  residf <- forecast(residauto,h=12)
  
  y <- as.numeric(trainlmf$mean)
  x <- as.numeric(residf$mean)
  sp <- x+y
  cat("----------------------------------
      
      Data Partition",i,"
      
      Training Set includes",length(train)," time periods. Observations 1 to", idx, "
      Test Set includes 12 time periods. Observations", idx+1, "to", idx+12,"
      
      ")
  print(accuracy(sp,test))
  accuracy.arima<-rbind(accuracy.arima,accuracy(sp,test)[1,3])
}
accuracy.arima<-accuracy.arima[-1]

cat("10 Year Interval Results:
    Naive Forecast: 
    Mean MAE: ",mean(accuracy.naive),"
    Std Dev MAE: ",sd(accuracy.naive),"
    
    ARIMA on residuals:
    Mean MAE: ",mean(accuracy.arima),"
    Std Dev MAE: ",sd(accuracy.arima),"
    ")


#mean(accuracy.arima)
#sd(accuracy.arima)
#mean(accuracy.naive)
#sd(accuracy.naive)

###############################
#######20-YEAR ACCURACY########
###############################
# Naive Accuracy for CV
accuracy.naive = 0 #check average 12 month out accuracy for 10 years
for (i in 1:20) {
  idx <- which(MetGlobalData$month == "1999-12-01")
  idx <- idx + ((i-1)*12)
  naiveStart <- time(MetGlobal_msts)[idx-12]
  naiveForecast <- rep(mean(window(MetGlobalData$anomaly_c, start=idx-12 , end=idx )), each = 12) #create naive predictions
  
  idxStart <- time(MetGlobal_msts)[idx+1]
  idxEnd <- time(MetGlobal_msts)[idx+12]
  
  actuals <- window(MetGlobal_msts, start=idxStart , end=idxEnd)
  mae <- mean(abs(naiveForecast-actuals)) #MAE for naive forecast  
  mae <- as.numeric(mae)
  accuracy.naive<-append(accuracy.naive,mae)
  print(accuracy.naive)
}

accuracy.naive<-accuracy.naive[-1]

# ARIMA accuracy CV
accuracy.arima=0 # we will check average 12-month-out accuracy for 60 months
for (i in 1:20)  {
  
  idx <- which(MetGlobalData$month == "1999-12-01")
  idx <- idx + ((i-1)*12)
  idxTrainEnd <- time(MetGlobal_msts)[idx]
  
  idxTestStart <- time(MetGlobal_msts)[idx+1]
  idxTestEnd <- time(MetGlobal_msts)[idx+12]
  
  train <- window(MetGlobal_msts, start=1 , end=idxTrainEnd)
  test <- window(MetGlobal_msts, start=idxTestStart , end=idxTestEnd)
  
  trainlm <- tslm(train ~ trend + season)
  trainlmf <- forecast(trainlm,h=12)
  
  residauto <- auto.arima(trainlm$residuals)
  residf <- forecast(residauto,h=12)
  
  y <- as.numeric(trainlmf$mean)
  x <- as.numeric(residf$mean)
  sp <- x+y
  cat("----------------------------------
      
      Data Partition",i,"
      
      Training Set includes",length(train)," time periods. Observations 1 to", idx, "
      Test Set includes 12 time periods. Observations", idx+1, "to", idx+12,"
      
      ")
  print(accuracy(sp,test))
  accuracy.arima<-rbind(accuracy.arima,accuracy(sp,test)[1,3])
}
accuracy.arima<-accuracy.arima[-1]

cat("20 Year Interval Results:
    Naive Forecast: 
    Mean MAE: ",mean(accuracy.naive),"
    Std Dev MAE: ",sd(accuracy.naive),"
    
    ARIMA on residuals:
    Mean MAE: ",mean(accuracy.arima),"
    Std Dev MAE: ",sd(accuracy.arima),"
    ")

#mean(accuracy.arima)
#sd(accuracy.arima)
#mean(accuracy.naive)
#sd(accuracy.naive)