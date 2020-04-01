#title: "Health_covid19cases"

# Import libraries
library(dplyr) # Version: ‘0.8.5’
library(tidyr) # ‘1.0.2’
library(lubridate) # ‘1.7.4’
library(reshape2)
library(xts)
library(lattice)
#library(hochr)


# Number formatting
options(scipen = 1000000)
options(digits = 6)
options(encoding="UTF-8")
#Einlesen Fälle
url_cases  <- "https://raw.githubusercontent.com/openZH/covid_19/master/COVID19_Fallzahlen_CH_total.csv"
cases <- read.csv(url(url_cases), header=T, sep=",", stringsAsFactors=FALSE, encoding="UTF-8")
# Schlüsselfile Grossregionen
grossregion <- read.csv("KantonGrossregion.csv", header=T, sep=",", stringsAsFactors=FALSE, encoding="UTF-8")

#confirmed cases by canton
conf<-with(cases, tapply(ncumul_conf, list(date, abbreviation_canton_and_fl), sum))
#first row of data: 0 except for ticino
conf[1,]<-ifelse(is.na(conf[1,]), 0, conf[1,])
#replace NA with last number before
conf<-na.locf(as.xts(conf))
# decumulate
conf<-apply(conf,2, diff)
#long format
conf<-melt(as.matrix(conf))
# variables
conf$variable_short<-"faelle_sars_cov2"
conf$variable_long<-"Gemeldete Anzahl SARS-CoV-2 Fälle"

#dead cases by canton
dead<-with(cases, tapply(ncumul_deceased, list(date, abbreviation_canton_and_fl), sum))
#replace NA with last number before
#first row of data (25.2.2020): no dead
dead[1,]<-ifelse(is.na(dead[1,]), 0,dead[1,])
#replace NA with last value above
dead<-na.locf(as.xts(dead))
#decumulate
dead<-apply(dead,2, diff)
#long format
dead<-melt(as.matrix(dead))
dead$variable_short<-"verstorbene_sars_cov2"
dead$variable_long<-"Gemeldete Anzahl SARS-CoV-2 Verstorbene"

all<-rbind(conf, dead)

#Aggregation auf Gesamtschweiz
chtotal<-with(all, aggregate(value, list(date=Var1, variable_short=variable_short, variable_long=variable_long), sum))
chtotal$location<-"CH"

#Aggregation auf die Grossregionen
all<-merge(all, grossregion, by.x="Var2", by.y="Kanton", all.x=T)
allreg<-with(all, aggregate(value, list(date=Var1, 
                                        location=location, 
                                        variable_short=variable_short, 
                                        variable_long=variable_long), sum))
#Beides zusammen
allreg<-rbind(allreg, chtotal)

covid19<-data.frame(date=as.POSIXct(paste(allreg$date, "00:00:00", sep=" ")),
                       value=allreg$x,
                       topic="Gesundheit",
                       variable_short=allreg$variable_short,
                       variable_long=allreg$variable_long,
                       location=allreg$location,
                       unit="Anzahl",
                       source="Gesundheitsdirektion Kanton Zürich",
                       update="täglich",
                       public="ja",
                       description="https://github.com/statistikZH/covid19monitoring_health_covid19cases")

#letzte zwei tage rausnehmen zu sicherheit, um keine unvollständig erfassten Tage drin zu haben
covid19<-subset(covid19, date<Sys.Date()-1)

write.table(covid19, "Health_covid19cases.csv", sep=",", fileEncoding="UTF-8", row.names = F)



#tests

#gesamtschweizerische Entwicklung
ee<-subset(covid19, location=="CH" & variable_short=="faelle_sars_cov2")[,c("date", "value")]
data.frame(ee)

ee$cumsum<-cumsum(ee$value)
rownames(ee)<-ee$date
ee<-as.xts(ee[,2:3])

wk<-data.frame(apply.weekly(ee$value, sum))
wk$cumsum<-cumsum(wk$value)

xyplot(wk$value~wk$cumsum, 
       #par.settings=my, 
       type=c("p", "l"), cex=3, scales=list(log=T),
       ylab="new cases",
       xlab="cumulated cases",
       panel = function(x, y, ...) {
         panel.xyplot(x, y, ...)
        panel.text(x, y, labels=rownames(wk))
       }
       )


xyplot(ee$value~ee$cumsum, 
       #par.settings=my, 
       type=c("p", "l"), cex=3, scales=list(log=T),
       ylab="new cases",
       xlab="cumulated cases",
       panel = function(x, y, ...) {
         panel.xyplot(x, y, ...)
         panel.text(x, y, labels=format(as.Date(index(ee)),format="%d%m"))
       }
)


