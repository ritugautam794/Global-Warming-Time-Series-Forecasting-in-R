library(forecast)

GlobalData<-read.csv(file.choose(), header=TRUE, sep=",")
Global_msts <- msts(GlobalData$anomaly_c, seasonal.periods=c(12,48))

Global_tbats <- tbats(Global_msts) #create TBATS model
plot(Global_tbats) #plot decomposition

Acf(Global_msts,main="") #autocorrelation
Pacf(Global_msts,main="") #partial autocorrelation

Global_tbats_pred <- forecast(Global_tbats, h=930, level=0.9) #Generate predictions until 2100 from TBATS model
plot(Global_tbats_pred, xlab="Time", ylab="Predicted Global Anomaly Temp, C") #plot predictions

Globallm_msts <- tslm(Global_msts ~ trend + season) # Build a linear model for trend and seasonality
residarima1 <- auto.arima(Globallm_msts$residuals) # Build ARIMA on it's residuals

residarima1 #show ARIMA on residuals model
Globallm_msts #show linear model

residualsArimaForecast <- forecast(residarima1, h=930, level=0.9) #forecast from ARIMA
residualsF <- as.numeric(residualsArimaForecast$mean) #point predictions from ARIMA
regressionForecast <- forecast(Globallm_msts,h=930, level=0.9) #forecast from lm
regressionF <- as.numeric(regressionForecast$mean) #point predictions from lm
forecastR <- regressionF+residualsF # Total prediction

plot(Global_tbats_pred, xlab="Time", ylab="Predicted Global Anomaly Temp, C") #plot TBATS model predictions
for (i in 1:930) {
  points((i+length(Global_msts)+48)/48,forecastR[i],col="red",pch=19, cex=0.5) 
} #plot ARIMA on residuals predictions on top of TBATS for visual comparison

###############################
#######Cross Validation########
###############################
# TBATS Accuracy CV
accuracy.tbats = 0 #check average 12 month out accuracy for 6 years
for (i in 1:6) {
  nTest <- 12*i  
  nTrain <- length(Global_msts)- nTest -1
  train <- window(Global_msts, start=1, end=1+(nTrain)/72)
  test <- window(Global_msts, start=1+(nTrain+1)/72, end=1+(nTrain+12)/72)
  
  
  s <- tbats(train)
  sp<- predict(s,h=12)
  
  cat("----------------------------------
      
      Data Partition",i,"
      Training Set includes",nTrain," time periods. Observations 1 to ",nTrain, "
      Test Set includes 12 time periods. Observations", nTrain+1, "to", nTrain+12,"
      
      ")
  print(accuracy(sp,test))
  accuracy.tbats<-rbind(accuracy.tbats,accuracy(sp,test)[2,2]) #note: [2,2] is a row,column reference. There are 2 rows (Train Results, Test Results), and 7 columns (The 7 accuracy metrics computed). This indicates that we are taking the RMSE from the test set
}
accuracy.tbats<-accuracy.tbats[-1]

# ARIMA accuracy CV
accuracy.arima=0 # we will check average 12-month-out accuracy for 6 years
for (i in 1:6)  {
  nTest <- 12*i  
  nTrain <- length(Global_msts)- nTest -1
  train <- window(Global_msts, start=1, end=1+(nTrain)/72)
  test <- window(Global_msts, start=1+(nTrain+1)/72, end=1+(nTrain+12)/72)
  
  trainlm <- tslm(train ~ trend + season)
  trainlmf <- forecast(trainlm,h=12)
  
  residauto <- auto.arima(trainlm$residuals)
  residf <- forecast(residauto,h=12)
  
  y <- as.numeric(trainlmf$mean)
  x <- as.numeric(residf$mean)
  sp <- x+y
  
  cat("----------------------------------
      
      Data Partition",i,"
      
      Training Set includes",nTrain," time periods. Observations 1 to", nTrain, "
      Test Set includes 12 time periods. Observations", nTrain+1, "to", nTrain+12,"
      
      ")
  print(accuracy(sp,test))
  accuracy.arima<-rbind(accuracy.arima,accuracy(sp,test)[1,2])
}
accuracy.arima<-accuracy.arima[-1]

mean(accuracy.tbats)
mean(accuracy.arima)
sd(accuracy.tbats)
sd(accuracy.arima)


fitted <- residarima1$fitted + Globallm_msts$fitted
plot(Global_msts)
for (i in 1:2082) {
  points((i+48)/48,fitted[i],col="red",pch=19, cex=0.5) 
}