library(forecast)

GlobalData<-read.csv(file.choose(), header=TRUE, sep=",")
Global_ts <- ts(GlobalData$anomaly_c,start=1850, frequency=12) #for met dataset, change start=1880 for NASA

for (i in (1:6)) {
  idxStart <- 1+((i-1)*360)
  idxEnd <- min((360*i),length(Global_ts),na.rm=TRUE)
  assign(paste0("dataset_", min((i*30+1850),2023)), window(GlobalData$anomaly_c, start=idxStart , end=idxEnd))
}

label=c("1880","1910","1940","1970","2000","2023") #for Met, change to labal=c("1910","1940","1970","2000",""2023) for NASA

#plot boxplots for each 30 year interval. update dataset_% for the NASA dataset to align to the labels above
boxplot(dataset_1880,
dataset_1910,
dataset_1940,
dataset_1970,
dataset_2000,
dataset_2023, 
names=label)

#print standard deviation for each 30 year interval. update dataset_% for the NASA dataset to align to the labels above
sd(dataset_1880)
sd(dataset_1910)
sd(dataset_1940)
sd(dataset_1970)
sd(dataset_2000)
sd(dataset_2023)

#print interquartile range for each 30 year interval. update dataset_% for the NASA dataset to align to the labels above
IQR(dataset_1880)
IQR(dataset_1910)
IQR(dataset_1940)
IQR(dataset_1970)
IQR(dataset_2000)
IQR(dataset_2023)
