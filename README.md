# yhistransport
Tallinna ühistranspordi gps andmete visualiseerimine

* Aluseks on Tallinna üistranspordi gps andmed perioodil 22.03.2016 05:00 - 23.03.2016 00:40
* Andmed on laetud ühe päeva kohta iga 15 sekundi tagant
* Täpsem kirjeldus andmete laadimise kohta "R/lae_andmed.R" failis. Selle abil toimus alusandmete salvestamine aadressilt http://soiduplaan.tallinn.ee/gps.txt
* Skripti "01_andmete_laadimine.R" abil toimub csv failides olevate andmete kokku tõstmine ühte tabelisse ning esmane andmetöötlus.
* Skripti "02_andmetootlus.R" abil on arvutatud kõigi sõitude kogupikkus ning joonistatud kaart sõitudest.
