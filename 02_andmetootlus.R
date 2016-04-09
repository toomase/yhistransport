# Kaardil kõik Tallinna ühistranspordi sõidud ühe päeva jooksul
# Lisaks arvutatud kogu distants, mille sõidukid päeva jokksul läbivad

library(dplyr)
library(ggmap)
library(ggplot2)
library(sp)
library(ggthemes)
library(extrafont)
library(purrr)
library(stringr)

load("data/yhistranspordi_gps.RData")

# töötle andmed visualiseerimiseks sobivale kujule
gps <- yhistranspordi_gps %>%
    # võta arvesse ainult Tallinna piirkonnas olevad koordinaadid
    filter(suund != 999, lng > 24.558454, lng < 24.953275,
           lat > 59.342081, lat < 59.511817) %>%
    # välista kordused (need koordinaadid, kus buss seisab)
    distinct(vehicle_id, liik, liin, suund, lng, lat) %>%
    arrange(vehicle_id, aeg) %>%
    # leia iga sõiduki unikaalsed sõidud
    # arvesse lähevad need andmed, kus kahe punkti vahe on väiksem kui 2 min
    # iga selline sõit saab unikaalse id
    group_by(vehicle_id) %>%
    mutate(aeg_eelmine = lag(aeg),
           aeg_erinevus = difftime(aeg, aeg_eelmine, units = "mins"),
           jrk = ifelse(is.na(aeg_eelmine), 1, 
                        ifelse(aeg_erinevus > 2, sample(2:100, 1), 0)),
           jrk_2 = cumsum(jrk),
           id = str_c(as.character(vehicle_id), "_", as.character(jrk_2))) %>%
    ungroup() %>%
    select(-aeg_eelmine, -aeg_erinevus, -jrk, -jrk_2)


# funktsioon, mis arvutab ia üksiku joone pikkuse
# selleks on vajalik koordinaatidest teha matrix, millest omakorda SpatialLines classi objekt
joone_pikkus <- function(x){
    pikkus <- gps %>%
        filter(id == x) %>%
        select(lng, lat) %>%
        as.matrix() %>%
        Line(.) %>%
        Lines(., ID = "a") %>%
        list(.) %>%
        SpatialLines() %>%
        SpatialLinesLengths(., longlat = TRUE)
    
    data_frame(x, pikkus)
}   

# unikaalsed sõitude tunnused, et nende pikkused arvutada
tunnused <- gps %>%
    select(id) %>%
    distinct() %>%
    .$id

# sõitude pikkuste data frame
pikkused <- map_df(tunnused, joone_pikkus)

# kõigi sõitude pikkus kokku KM-tes
pikkused %>%
    summarise(sum(pikkus))

# Tallinna piirkonna koordinaadid
tallinn <- c(left = 24.558454, bottom = 59.342081, right = 24.953275, 
             top = 59.511817)

# Tallinna aluskaart
tallinna_kaart <- get_map(tallinn, zoom = 11, maptype = "toner-background")

# salvest sõidud kaardile
png(filename = "output/yhistransport.png", width = 1000, height = 1000)
ggmap(tallinna_kaart, darken = 0.7) +  # alusaakrt tumedat tooni 
    geom_path(data = gps, aes(x = lng, y = lat, group = factor(id)), 
              colour = "#FFFF33", alpha = 0.02) +  # joonesd kollased ja peenikesed
    theme_map() + 
    # pealkiri graafiku sees
    annotate("text", x = min(gps$lng), y = max(gps$lat),
             hjust = -0.05, vjust = 1, label = "Tallinna ühistransport ühes päevas",
             colour = "grey", size = 12) +
    # alapealkiri selgitustega graafiku sees
    annotate("text", x = min(gps$lng), y = max(gps$lat),
             hjust = -0.04, vjust = 2.3, label = "22.03.2016 tehtud kõik sõidud busside, trollide ja trammidega (kokku ca 98 000 km)\n  Paksem kollane jooned tähendab rohkem sõite",
             colour = "grey", size = 6)
dev.off()