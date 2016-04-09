# lae gps andmed veebist
# cronjob abil saab panna Rstudio serveri iga 15 sek järel faili maha salvestama
library(readr)

aeg <- round(as.numeric(Sys.time()), 0)  # salvestamise aeg

# faili salvestamise asukoht ja faili nimi
file <- paste('~/Dropbox/DataScience/R/yhistransport/data/gps/', aeg, '.csv', sep = '')

# yistranspordi gps faili asukoht
gps <- read_delim("http://soiduplaan.tallinn.ee/gps.txt", delim = ",",
                  col_names = FALSE)

# salvesta iga fail asukohta
write.csv2(gps, file, row.names = FALSE)

## rstudio serveri script, mis käib iga 15 sekundi tagant ja kl 20.40 - 20.50
## ava MobaXterm tarkvara ja logi Rstudio serverisse sisse
## seejärel sisene cronjob vaatesse
# sudo crontab -u rstudio -e

## lisa cronjob vaates järgnevad read
# 40-50 20 * * * Rscript ~/Dropbox/DataScience/R/yhistransport/R/lae_andmed.R
# 40-50 20 * * * sleep 15; Rscript ~/Dropbox/DataScience/R/yhistransport/R/lae_andmed.R
# 40-50 20 * * * sleep 30; Rscript ~/Dropbox/DataScience/R/yhistransport/R/lae_andmed.R
# 40-50 20 * * * sleep 45; Rscript ~/Dropbox/DataScience/R/yhistransport/R/lae_andmed.R