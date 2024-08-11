library(forecast)

MetGlobalData<-read.csv(file.choose(), header=TRUE, sep=",")
MetGlobal_msts <- msts(MetGlobalData$anomaly_c, seasonal.periods=c(12,48))
idx <- which(MetGlobalData$month == "2006-12-01") #get index of last month for training set
naiveStart <- time(MetGlobal_msts)[idx-12] #get scaled index for naive start date
trainEnd <- time(MetGlobal_msts)[idx] #get scaled index for end date
train <- window(MetGlobal_msts, start=1 , end=trainEnd ) #filter dataset for the training period

mean(window(MetGlobal_msts, start=naiveStart , end=trainEnd )) #average the 12 month anomaly temps for the last year prior to prediction

#naiveForecast
naiveForecast <- rep(mean(window(MetGlobal_msts, start=naiveStart , end=trainEnd )), each = 120) #create naive predictions

#train model
MetGloballm_msts <- tslm(train ~ trend + season) # Build a linear model for trend and seasonality
residarima1 <- auto.arima(MetGloballm_msts$residuals) # Build ARIMA on it's residuals

residualsArimaForecast <- forecast(residarima1, h=120, level=c(0.9, 0.95)) #forecast from ARIMA
residualsF <- as.numeric(residualsArimaForecast$mean) #point predictions ARIMA
regressionForecast <- forecast(MetGloballm_msts,h=120, level=c(0.9, 0.95)) #forecast from lm
regressionF <- as.numeric(regressionForecast$mean) #point predictions lm
forecastR <- regressionF+residualsF # Total prediction

GlobalMeanPred <- regressionForecast$mean + residualsArimaForecast$mean #Total point predictions
GlobalLCPred <- regressionForecast$lower + residualsArimaForecast$lower #Total CI lower
GlobalUCPred <- regressionForecast$upper + residualsArimaForecast$upper #Total CI upper

xSeq <- seq(as.Date("2007/1/1"), by = "month", length.out = 120) #monthly dates for the test period

#this creates the boundaries for shaded CI area on plots
min_a <- pmin(GlobalMeanPred, GlobalLCPred[,1], GlobalUCPred[,1])
max_a <- pmax(GlobalMeanPred, GlobalLCPred[,1], GlobalUCPred[,1])

idx <- which(MetGlobalData == '2016-12-01') #index for last month in the test set
valEnd <- time(MetGlobal_msts)[idx] #scaled index
val_ts <- window(MetGlobal_msts, start=1 , end=valEnd) #filter dataset for full train + test period

xSeqFull <- seq(as.Date(MetGlobalData$month[1]), by = "month", length.out = length(train)+120) #create list of month from beginning of dataset to end of test period

plot(xSeqFull, val_ts, type="l", xlab="Time", ylab="Anomaly Temp, C") #plot actuals
lines(xSeq, GlobalMeanPred, col="blue") #plot out predictions
lines(xSeq, naiveForecast, col="red") #plot naive predictions
polygon(c(xSeq, rev(xSeq)), c(max_a ,rev(min_a)), col = rgb(0.3,0.3,0.7,0.2), border="NA") #plot confidence interval

#calculate mean absolute error for each forecast
idx <- which(MetGlobalData == '2007-01-01') #get index for beginning of test period
actualStart <- time(MetGlobal_msts)[idx] #scaled index
actuals <- window(MetGlobal_msts, start=actualStart , end=valEnd) #actuals for the test period

mean(abs(naiveForecast-actuals)) #MAE for naive forecast
mean(abs(GlobalMeanPred-actuals)) #MAE for ARIMA model