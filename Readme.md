
**Grundlage**

Die Daten zu den bestätigten COVID19-Fällen und den Verstorbenen beruhen auf den [Angaben der Kantone](https://raw.githubusercontent.com/openZH/covid_19/master/COVID19_Fallzahlen_CH_total.csv). Dieses Skript bringt sie in das für die Integration in den [harmonisierten Datensatz "Gesellschaftsmonitoring COVID19"](https://raw.githubusercontent.com/statistikZH/covid19monitoring/master/covid19socialmonitoring.csv) benötigte Format. 

**Methodisches**

Die kumulierten Fallzahlen werden kantonsweise ergänzt mit dem letzten bekannten Tageswert, wo die Werte fehlen (insbesondere in der Anfangszeit der Epidemie und an Wochenenden). Diese komplettierten Zeitreihen werden dann dekumuliert, und anschliessend auf die [Grossregionen  des BFS NUTS-3 Eurostat](https://www.bfs.admin.ch/bfs/de/home/statistiken/querschnittsthemen/raeumliche-analysen/raeumliche-gliederungen/analyseregionen.assetdetail.1031445.html))  aggregiert, um die Aussagekraft und Stabilität zu erhöhen. Der Vortag wird weggelassen, um verspätete Meldungen der Kantone ausszuschliessen.

**Weitere Informationen**

[Projektseite: "Gesellschafsmonitoring COVID19"](https://github.com/statistikZH/covid19monitoring)

[Datenbezug](https://www.web.statistik.zh.ch/covid19_indikatoren_uebersicht/#/)