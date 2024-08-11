library(forecast)

MetGlobalData<-read.csv(file.choose(), header=TRUE, sep=",")
MetGlobal_msts <- msts(MetGlobalData$anomaly_c, seasonal.periods=c(12,48)) 

#training window pre-2000
idx <- which(MetGlobalData$month == "1999-12-01") #determine index number for the date we want to train up until
trainEnd <- time(MetGlobal_msts)[idx] #determine scaled index for seasons of 48 months
naiveStart <- time(MetGlobal_msts)[idx-12]
train <- window(MetGlobal_msts, start=1 , end=trainEnd ) #filter the full dataset to a training set from the beginning until Dec 1999

#naive forecast
naiveForecast10 <- rep(mean(window(MetGlobal_msts, start=naiveStart , end=trainEnd )), each = 120) #create naive predictions
naiveForecast20 <- rep(mean(window(MetGlobal_msts, start=naiveStart , end=trainEnd )), each = 240) #create naive predictions


#naiveForecast10 <- rep(train[idx], each = 120) #10 year forecast
#naiveForecast20 <- rep(train[idx], each = 240) #20 year forecast

#train model
MetGloballm_msts <- tslm(train ~ trend + season) # Build a linear model for trend and seasonality
residarima1 <- auto.arima(MetGloballm_msts$residuals) # Build ARIMA on it's residuals

#10 year prediction
residualsArimaForecast <- forecast(residarima1, h=120, level=c(0.9, 0.95)) #forecast from ARIMA
residualsF <- as.numeric(residualsArimaForecast$mean) # get point predictions from ARIMA
regressionForecast <- forecast(MetGloballm_msts,h=120, level=c(0.9, 0.95)) #forecast from lm
regressionF <- as.numeric(regressionForecast$mean) # get point predictions from lm
forecastR <- regressionF+residualsF # Total prediction

GlobalMeanPredTen <- regressionForecast$mean + residualsArimaForecast$mean #Total point prediction
GlobalLCPredTen <- regressionForecast$lower + residualsArimaForecast$lower #Total CI lower
GlobalUCPredTen <- regressionForecast$upper + residualsArimaForecast$upper #Total CI upper

#20 year prediction
residualsArimaForecast <- forecast(residarima1, h=240, level=c(0.9, 0.95)) #forecast from ARIMA
residualsF <- as.numeric(residualsArimaForecast$mean) # get point predictions from ARIMA
regressionForecast <- forecast(MetGloballm_msts,h=240, level=c(0.9, 0.95)) #forecast from lm
regressionF <- as.numeric(regressionForecast$mean) # get point predictions from lm
forecastR <- regressionF+residualsF # Total prediction

GlobalMeanPredTwenty <- regressionForecast$mean + residualsArimaForecast$mean #Total point predictions
GlobalLCPredTwenty <- regressionForecast$lower + residualsArimaForecast$lower #Total CI lower
GlobalUCPredTwenty <- regressionForecast$upper + residualsArimaForecast$upper #Total CI upper

#get index for dates of interest from original dataset
idxStart <- which(MetGlobalData$month == "2000-01-01") 
idxEnd10 <- which(MetGlobalData$month == "2009-12-01")
idxEnd20 <- which(MetGlobalData$month == "2019-12-01")

#get scaled index for seasons of 48 months
start <- time(MetGlobal_msts)[idxStart]
end10 <- time(MetGlobal_msts)[idxEnd10]
end20 <- time(MetGlobal_msts)[idxEnd20]

#calculate mean absolute error for each forecast
actuals <- window(MetGlobal_msts, start=start , end=end10) #actuals temperature anomalies for the 10 years
naiveMAE10 <- mean(abs(naiveForecast10-actuals)) #calculate mean absolute error for 10 years using naive forecast
naiveMAE10sd <- sd(abs(naiveForecast10-actuals))
arimaResidMAE10 <- mean(abs(GlobalMeanPredTen-actuals)) #calculate mean absolute error for 10 years using our forecast
arimaResidMAE10sd <- sd(abs(GlobalMeanPredTen-actuals))


actuals <- window(MetGlobal_msts, start=start , end=end20) #actuals temperature anomalies for 20 years
naiveMAE20 <- mean(abs(naiveForecast20-actuals)) #calculate mean absolute error for 20 years using naive forecast
naiveMAE20sd <- sd(abs(naiveForecast20-actuals))
arimaResidMAE20 <- mean(abs(GlobalMeanPredTwenty-actuals)) #calculate mean aboslute error for 20 years using our forecast
arimaResidMAE20sd <- sd(abs(GlobalMeanPredTwenty-actuals))


#print out the results
cat("Ten Year Accuracy (MAE): 
    Naive Forecast: ",naiveMAE10,"Std Dev: ",naiveMAE10sd,"
    ARIMA on Residuals Forecast (our model): ",arimaResidMAE10,"Std Dev: ",arimaResidMAE10sd,"
    
    Twenty Year Accuracy (MAE): 
    Naive Forecast: ",naiveMAE20,"Std Dev: ",naiveMAE20sd,"
    ARIMA on Residuals Forecast (our model): ",arimaResidMAE20,"Std Dev: ",arimaResidMAE20sd,"
    ")


xSeq10 <- seq(as.Date("2000/1/1"), by = "month", length.out = 12*10) #10 year monthly dates for xaxes plot
xSeq20 <- seq(as.Date("2000/1/1"), by = "month", length.out = 12*20) #20 year monthly dates for xaxes plot

#this sets the boundaries for the shaded confidence interval on the plots
min_a10 <- pmin(GlobalMeanPredTen, GlobalLCPredTen[,1], GlobalUCPredTen[,1])
max_a10 <- pmax(GlobalMeanPredTen, GlobalLCPredTen[,1], GlobalUCPredTen[,1])
min_a20 <- pmin(GlobalMeanPredTwenty, GlobalLCPredTwenty[,1], GlobalUCPredTwenty[,1])
max_a20 <- pmax(GlobalMeanPredTwenty, GlobalLCPredTwenty[,1], GlobalUCPredTwenty[,1])

#actuals from beginning of dataset up until the end of the prediction periods for 10 years
idx <- which(MetGlobalData == '2009-12-01')
valEnd10 <- time(MetGlobal_msts)[idx]
val_ts10 <- window(MetGlobal_msts, start=1 , end=valEnd10)

#actuals from beginning of dataset up until the end of the prediction periods for 10 years
idx <- which(MetGlobalData == '2019-12-01')
valEnd20 <- time(MetGlobal_msts)[idx]
val_ts20 <- window(MetGlobal_msts, start=1 , end=valEnd20)


xSeqFull10 <- seq(as.Date(MetGlobalData$month[1]), by = "month", length.out = length(train)+(12*10)) #list of months from beginning of dataset to end of test perio 10 yearsd
xSeqFull20 <- seq(as.Date(MetGlobalData$month[1]), by = "month", length.out = length(train)+(12*20)) #list of months from beginning of dataset to end of test period 20 years

#plot 10 year actuals and both forecasts
plot(xSeqFull10, val_ts10, type="l", xlab="Time", ylab="Anomaly Temp, C")
lines(xSeq10, GlobalMeanPredTen, col="blue")
lines(xSeq10, naiveForecast10, col="red")
polygon(c(xSeq10, rev(xSeq10)), c(max_a10 ,rev(min_a10)), col = rgb(0.3,0.3,0.7,0.2), border="NA")

#plot 20 year actuals and both forecasts
plot(xSeqFull20, val_ts20, type="l", xlab="Time", ylab="Anomaly Temp, C")
lines(xSeq20, GlobalMeanPredTwenty, col="blue")
lines(xSeq20, naiveForecast20, col="red")
polygon(c(xSeq20, rev(xSeq20)), c(max_a20 ,rev(min_a20)), col = rgb(0.3,0.3,0.7,0.2), border="NA")