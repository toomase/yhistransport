# Tallinna üistranspordi gps andmete laadimine perioodi kohta 22.03.2016 05:00 - 23.03.2016 00:40
# Aluseks on Rstudio serveri abil alla laetud andmed aadressilt http://soiduplaan.tallinn.ee/gps.txt
# Andmed on laetud ühe päeva kohta iga 15 sekundi tagant
# Täpsem kirjeldus andmete laadimise kohta "R/lae_andmed.R" failis
# Antud skript paneb kõik gps andmete failid ühte tabelisse kokku
library(readr)
library(dplyr)
library(stringr)
library(lubridate)
library(purrr)

# failide nimekiri laadimiseks
files = list.files("data/gps", full.names = TRUE)

# funktsioon andmete laadimiseks
laadimine <- function(x){
    raw <- read_csv2(x)
    raw %>%
        mutate(aeg = str_sub(x, start = 10, end = 19))  # kellaaeg õigesse formaati
}

# andmed ühte tabelisse kokku (võtab ca 5 min aega)
yhistranspordi_gps_raw <- map_df(files, laadimine)

# muuda veergude nimed
names(yhistranspordi_gps_raw) <- c("liik", "liin", "lng", "lat", "puudu", "suund", 
                        "vehicle_id", "aeg")

# esialgne andmetöötlus
yhistranspordi_gps <- yhistranspordi_gps_raw %>%
    tbl_df() %>%
    # erista buss/troll/tramm, koordinaadid õigesse formaati ja kp/kell õigesse formaati
    mutate(liik = ifelse(liik == 1, "troll", ifelse(liik == 2, "buss", "tramm")),
           lng = lng / 1000000,
           lat = lat / 1000000,
           aeg = as.POSIXct(as.numeric(aeg), origin = "1970-01-01")) %>%
    # kustuta ilma koordinaatideta ja liini tunnuseta read
    filter(lng != 0, lat != 0, liin != 0) %>%
    select(vehicle_id, liik, liin, suund, aeg, lng, lat) %>%
    arrange(aeg)

# salvesta töödeldud tabel
save(yhistranspordi_gps, file = "data/yhistranspordi_gps.RData")