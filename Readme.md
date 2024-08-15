# Time series Forecasting

## Summary 
Global warming, a phenomenon marked by an overall increase in Earth's average surface temperature, has sparked extensive debates with varying perspectives on its seriousness and causes. To provide a comprehensive, fact-based understanding of the situation, this report presents a statistical analysis of global temperature data from two prominent sources, NASA, and the UK MET Office. Through rigorous analyses, the report addresses key concerns related to global warming, forecasts future temperature trends, assesses the accuracy of claims, and examines the "Climate Bet" debate. 

This report employs statistical analyses of global temperature data to provide evidence-based insights into global warming. The findings support concerns about temperature rise, discredit claims of halted warming, and validate assertions of increased temperature fluctuations. The "Climate Bet" analysis underscores the necessity of robust models, while long-term analyses emphasize the dynamic nature of climate patterns. These findings contri

### CONTEXT
The dynamics of climate and global temperatures exhibit natural variability across different cyclical timeframes, influenced by factors like Earth's orbital variations, solar radiation distribution, and recurring oceanic and atmospheric processes [1]. These cycles encompass periods ranging from short intervals such as ten years (El Niño, La Niña) to longer spans of hundreds and even tens of thousands of years (glacial and interglacial periods). Human activities, particularly the unregulated release of CO2 and deforestation, have the potential to amplify these natural cycles.
Considering these factors, we formulated our initial model theory. Our approach involves incorporating distinct seasonality components to address two specific seasonal patterns:
* 12-Month Annual Cycles: This captures the short-term variations associated with the changing seasons of Spring, Summer, Fall, and Winter
* 48-Month (4-Year) Cycles: This component addresses the inter-decadal El Niño and La Niña cycles, offering insights into longer-term climatic variations
  
Our primary focus centers on forecasting global temperatures over the span of 77.5 years, specifically from July 2023 to December 2100. Additionally, it's important to acknowledge the disparity in temperature trends between the northern and southern hemispheres. The historical records indicate that the northern hemisphere has exhibited greater volatility and variability throughout the observation period. Notably, since the mid-1990s, a substantial temperature increase has been observed in the northern hemisphere compared to the southern hemisphere.

Although the localized patterns provide valuable insights, our objective is to forecast global anomaly temperatures. Consequently, we will refrain from developing distinct predictive models for each hemisphere, as their predictions would ultimately be averaged. This approach aligns with constructing a unified global model, capitalizing on the available datasets within our scope, and yielding outcomes comparable to those of individual hemisphere-specific models.

![image](https://github.com/user-attachments/assets/d0985d26-3210-4f83-8eda-4cdbda27f67e)


## STEPS TO BUILD A MODEL

### A. DECOMPOSITION:
It is a fundamental step in time series analysis to understand the underlying components. Intuitively, we know the data has complex seasonal patterns and due to the limitation of ETS decomposition that it cannot handle more complex seasonality patterns well, it doesn’t not perform optimally well. Thus, we leveraged TBATS (Trigonometric seasonality, Box-Cox transformation, ARMA errors, Trend, Seasonal) decomposition as it is a more advanced and versatile approach that can handle complex seasonality patterns, irregularities, and noisy data. By dissecting both datasets, we can extract several key insights that will significantly shape our decisions in constructing the model. A distinct upward trajectory is evident in both datasets, with a noticeable turning point emerging around the 1970s. Moreover, there exists substantial noise within the data, signifying that while certain cyclical patterns are moderately foreseeable and a more recent positive trend can be observed, there remains substantial ambiguity and fluctuation within the monthly temperature values.

Both seasonality terms identified in our initial theory hold true as we can see in the decomposition plots. While the annual seasonality is a little hard to decipher given the volume of data points, there is a clear pattern. More obvious is the clear seasonal pattern when looking at 48-month seasonality periods. In virtually every 4-year period, there is moderate drop in anomaly temperature, followed by a moderate increase, followed by a large drop, followed by a large increase.
![image](https://github.com/user-attachments/assets/72545c7e-9cc4-469b-a323-cf4a63d8d657)
![image](https://github.com/user-attachments/assets/7e3f06e1-ec6a-4510-adfb-cc328a11508e)

### B. MODEL IDENTIFICATION:
Autocorrelation Function (ACF) and Partial Autocorrelation Function (PACF) -
These are of paramount importance during the Model Identification phase to understand and model the underlying patterns and behaviors within time series data. Their significance lies in their ability to guide the selection and formulation of appropriate time series models. When we analyzed the autocorrelation and partial autocorrelation graphs of the dataset, it becomes apparent that there exists notable autocorrelation, with strong correlations across all lag periods. Additionally, the graphical representation distinctly showcases the previously mentioned seasonal and trend elements, implying the non-stationary nature of the data. For a stationary series, the ACF drops to zero relatively quickly, while the ACF of non-stationary data decreases slowly. It is critical that the time series data is stationary i.e., it has constant statistical properties such as mean, variance and autocorrelation, and does not depend on the time at which the series is observed to predict effectively.

![image](https://github.com/user-attachments/assets/79780aa0-3c7e-4865-8b7a-fe054e8c3307)

Examination of the partial autocorrelation plot reveals significance in the initial 10 lags, with the subsequent 14 lags also displaying a considerable degree of significance. To mitigate the stationarity and autocorrelation issues present in the data, we will look to incorporate non-seasonal and seasonal differencing terms in the model.

### C. MODEL BUILDING:
Given the multiple seasonality and non-stationary nature of the dataset, traditional ETS models are not suitable candidates. Therefore, we proceeded with building the following two models that we think would best suit the given circumstances and will also test during cross validation to determine the best model:
1. TBATS
2. ARIMA with residuals

   
1. TBATS: It stands as a robust solution when dealing with time series datasets that encompass multiple seasonal patterns. This model, when in conjunction with the 'msts' (multiple seasonal time series) package, offers a formidable approach for forecasting intricate time series with diverse recurring patterns.
   
#### Analysis: 
Utilizing the MET dataset yields a TBATS model characterized by parameters (1, {0,0}, 0.824, {<12,4>,<48,2>}). This configuration signifies that the model opts against a box-cox transformation, incorporates a dampening trend, and accounts for AR(0) and MA(0) components. Moreover, it employs 4 Fourier terms to accommodate the 12-month seasonal pattern and 2 Fourier terms for the 48-month seasonal cycle.
Similarly, the application of the NASA dataset results in a TBATS model featuring the parameter set (1, {0,0}, 0.835, {<12,4>,<48,3>}). In this scenario, the absence of a box-cox transformation is noted, alongside the inclusion of a dampening trend, and the consideration of AR(0) and MA(0) elements. Additionally, the model adapts by utilizing 4 Fourier terms to capture the 12-month seasonality and 3 Fourier terms to address the 48-month seasonal pattern.

![image](https://github.com/user-attachments/assets/2709ad5b-2ad1-4b41-a159-c8174d01172d)

2. ARIMA with residuals: A dynamic model that leverages combined predictions from a linear model and associated ARIMA model to capture complex seasonality, trend and error patterns. The "residuals" in the context of ARIMA refer to the differences between the observed values of the time series and the
8 values predicted by the linear model. These residuals are then fit in an ARIMA model, with parameters estimated in a way that minimizes the differences between the actual observed values error (residual) and the predicted error (residual) values.
#### Analysis:
• To produce the ARIMA on residuals model, we first built a time-series linear model on the trend and season – MetGloballm_msts <- tslm(MetGlobal_msts ~ trend + season) which yielded the following coefficients:

![image](https://github.com/user-attachments/assets/50e1e01b-126e-4238-b7b7-3c92c0d314a1)

Then, we leveraged the auto ARIMA functionality to build an ARIMA model on the residuals of the linear model above – residarima1 <- auto.arima (MetGloballm_msts$residuals) which yields the SARIMA model (2,1,2)(1,0,1)[48] with zero mean and (p,d,q) values as (2,1,2) and (P,D,Q) as (1,0,1) for MET dataset.


![image](https://github.com/user-attachments/assets/a25ab111-26e3-446d-965f-5e4994eb371e)

The resulting AIC is -3107.44 and the non-seasonal differencing term of 1 helps to solve the stationarity issues present in the data. Similarly, SARIMA model exhibits (4,1,1)(1,0,0)[48] value for the parameter with zero mean and an AIC of -2842.27 for NASA dataset.

![image](https://github.com/user-attachments/assets/61af88b0-5aa3-4118-8f93-100d9a0dfdfb)

* Lastly, forecasts from both the linear and ARIMA model were summed to get the total predicted value for this model

  ![image](https://github.com/user-attachments/assets/b7cabf14-33bc-4bd6-9523-4a384c79572d)

  ### D. MODEL SELECTION:
To compare the models, we leveraged a rolling window to train and test both models, checking the average 12-month prediction accuracy for 6 years. The graphic below illustrates our approach to the cross-validation process.

![image](https://github.com/user-attachments/assets/ace357ef-238f-4e7f-8a5b-99049db4b12a)

When evaluating the cross-validation outcomes, we examined the mean absolute error (MAE) and the root mean squared error (RMSE) across all six folds. In the case of the Met dataset, the ARIMA model displayed superior performance, yielding a mean MAE of 0.0979 with a standard deviation of 0.0292. This contrasted with the TBATS model, which exhibited a mean RMSE of 0.102 accompanied by a standard deviation of 0.029. Moreover, when comparing the RMSE values for both models, the ARIMA model boasted a marginally lower score of 0.121, paired with a standard deviation of 0.038. In contrast, the TBATS model registered an average RMSE of 0.124, coupled with a standard deviation of 0.036. Based on these findings, we can deduce that the ARIMA on residuals model outperforms the TBATS model when making predictions for future values.

![image](https://github.com/user-attachments/assets/27c6ec9d-5d17-4593-9be1-90f1bd6403e2)

Similarly, in the context of the NASA dataset, the ARIMA model showcased enhanced performance concerning MAE. Nonetheless, this discrepancy was less pronounced compared to the MET dataset, and the ARIMA model's MAE exhibited a narrower standard deviation, suggesting more consistent results. Notably, the mean RMSE for the TBATS model was slightly lower at 0.120, in contrast to the ARIMA model's mean RMSE of 0.121 but, we shall be choosing ARIMA on residuals considering less dispersion and a negligible delta of 0.001 in RMSE.
#### Conclusion:
The table below concludes our analysis for different models and highlights the model selected in green:

![image](https://github.com/user-attachments/assets/b282666d-66d8-438a-9276-e226690d7737)














