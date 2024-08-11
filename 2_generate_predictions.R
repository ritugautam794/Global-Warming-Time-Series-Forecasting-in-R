library(forecast)

#import data and set up timeseries with multiple seasonality. 12 for annual cycle of seasons and 48 for el nino cycles
GlobalData<-read.csv(file.choose(), header=TRUE, sep=",")
Global_msts <- msts(GlobalData$anomaly_c, seasonal.periods=c(12,48))

Globallm_msts <- tslm(Global_msts ~ trend + season) # Build a linear model for trend and seasonality
residarima1 <- auto.arima(Globallm_msts$residuals) # Build ARIMA on it's residuals

residualsArimaForecast <- forecast(residarima1, h=930, level=c(0.9, 0.95)) #forecast from ARIMA
residualsF <- as.numeric(residualsArimaForecast$mean) #point predictions
regressionForecast <- forecast(Globallm_msts,h=930, level=c(0.9, 0.95)) #forecast from lm
regressionF <- as.numeric(regressionForecast$mean) #point predictions
forecastR <- regressionF+residualsF # Total prediction

#Total Predictions and confidence interval
GlobalMeanPred <- regressionForecast$mean + residualsArimaForecast$mean
GlobalLCPred <- regressionForecast$lower + residualsArimaForecast$lower
GlobalUCPred <- regressionForecast$upper + residualsArimaForecast$upper

#dates for predicted values
xSeq <- seq(as.Date("2023/7/1"), by = "month", length.out = 930)

#values to produce confidence interval plotting
min_a <- pmin(GlobalMeanPred, GlobalLCPred[,1], GlobalUCPred[,1])
max_a <- pmax(GlobalMeanPred, GlobalLCPred[,1], GlobalUCPred[,1])

#dates for the full dataset + predicted months
xSeqFull <- seq(as.Date(GlobalData$month[1]), by = "month", length.out = length(Global_msts)+930)

#plot actuals and point predictions
plot(xSeqFull,c(Global_msts,GlobalMeanPred), type="l", ylim=c(-0.2,0.2))
#plot confidence interval as shaded areas
polygon(c(xSeq, rev(xSeq)), c(max_a ,rev(min_a)), col = rgb(0.3,0.3,0.7,0.2), border="NA")

#create df with dates, point predictions and upper/lower ci
PredictionsOutput <- data.frame(`month`=xSeq, `point_prediction`=GlobalMeanPred,`lower_ci_90`=GlobalLCPred[,1], 
                                `upper_ci_90`=GlobalUCPred[,1],stringsAsFactors=F, check.names=F)

#write predictions to csv
write.csv(PredictionsOutput, file = "climate_model_predictions.csv")
