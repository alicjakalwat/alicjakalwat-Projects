#3.3

library(readxl)
library(dplyr)
library(psych)
library(ggplot2)
library(tidyr)

df_raw <- read_excel("C:/Dane/Studia/magisterka/seminarium/ankieta_r/Environmental_Attitudes_and_Behaviors_R_ready.xlsx", sheet = "Data_Clean_PL")

df_metrics <- df_raw %>%
  select(
    id,
    age,
    gender,
    country,
    university,
    field_study,
    childhood_place_size,
    childhood_nature_freq
  )


df_peb <- df_raw %>%
  select(starts_with("peb_")) %>%
  mutate(across(starts_with("peb_11"), ~ 6 - .x))
         

cor_matrix_peb <- cor(df_peb)
korelacja_peb <- round(cor_matrix_peb, 2)
korelacja_peb


### ANALIZA RZETELNOŚCI

rel_alpha_peb <- psych::alpha(df_peb)
print(rel_alpha_peb)

rel_omega_peb <- psych::omega(df_peb, nfactors = 1)
print(rel_omega_peb)

### ANALIZA SKUPIEŃ

df_metrics <- df_raw %>%
  select(
    id,
    age,
    gender,
    country,
    university,
    field_study,
    childhood_place_size,
    childhood_nature_freq
  )


df_peb <- df_raw %>%
  select(starts_with("peb_")) %>%
  mutate(across(starts_with("peb_11"), ~ 6 - .x))

df_peb_full <- bind_cols(df_metrics, df_peb)

dane_peb_scaled <- scale(df_peb)
macierz_odleglosci_peb <- dist(dane_peb_scaled, method = "euclidean")
fit_ward_peb <- hclust(macierz_odleglosci_peb, method = "ward.D2")

plot(fit_ward_peb, main = "Profile zachowań PEB wśród badanych", xlab = "Badani", sub = "")
rect.hclust(fit_ward_peb, k = 2, border = "red")


df_peb_full <- df_peb_full %>%
  mutate(Profil_PEB = factor(cutree(fit_ward_peb, k = 2), labels = c("Profil 1", "Profil 2")))


porownanie_srednich_peb <- df_peb_full %>% 
  group_by(Profil_PEB) %>% 
  summarise(across(starts_with("peb_"), ~ mean(.x, na.rm = TRUE))) %>% 
  t()

porownanie_srednich_peb

#wykres

df_chart <- as.data.frame(porownanie_srednich_peb)
colnames(df_chart) <- df_chart[1, ]        
df_chart <- df_chart[-1, ]                  
df_chart$Kod_Pytania <- rownames(df_chart)     

df_long <- df_chart %>%
  pivot_longer(cols = c("Profil 1", "Profil 2"), names_to = "Profil", values_to = "Srednia") %>%
  mutate(
    Srednia = as.numeric(Srednia),
    Pytanie_Etykieta = case_when(
      Kod_Pytania == "peb_1_recycle"         ~ "Pytanie 1 (recykling)",
      Kod_Pytania == "peb_2_lights"          ~ "Pytanie 2 (wyłączanie światła)",
      Kod_Pytania == "peb_3_water"           ~ "Pytanie 3 (oszczędzanie wody)",
      Kod_Pytania == "peb_4_standby"         ~ "Pytanie 4 (wyłączanie standby)",
      Kod_Pytania == "peb_5_reusable"        ~ "Pytanie 5 (siatki wielorazowe)",
      Kod_Pytania == "peb_6_ecolabels"       ~ "Pytanie 6 (eko-etykiety)",
      Kod_Pytania == "peb_7_refillable"      ~ "Pytanie 7 (wielorazowe opakowania)",
      Kod_Pytania == "peb_8_transport"       ~ "Pytanie 8 (eko-transport)",
      Kod_Pytania == "peb_9_reduce_flights"  ~ "Pytanie 9 (mniej lotów)",
      Kod_Pytania == "peb_10_meat_reduction" ~ "Pytanie 10 (mniej mięsa)",
      Kod_Pytania == "peb_11_fast_fashion"   ~ "Pytanie 11 (unikanie fast fashion)",
      Kod_Pytania == "peb_12_vote_eco"       ~ "Pytanie 12 (głosowanie eko)",
      Kod_Pytania == "peb_13_activities"     ~ "Pytanie 13 (aktywizm)",
      Kod_Pytania == "peb_14_donate"         ~ "Pytanie 14 (darowizny)",
      Kod_Pytania == "peb_15_read_news"      ~ "Pytanie 15 (czytanie newsów)",
      TRUE ~ Kod_Pytania
    )
  )


ggplot(df_long, aes(x = reorder(Pytanie_Etykieta, Srednia), y = Srednia, fill = Profil)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8), width = 0.7) +
  coord_flip() + 
  scale_y_continuous(limits = c(1, 5), oob = scales::oob_keep) + 
  scale_fill_manual(values = c("Profil 1" = "#E69F00", "Profil 2" = "#009E73")) +
  labs(
    title = "Średnie wartości zachowań proekologicznych (PEB) w podziale na Profile",
    x = "Zachowanie proekologiczne",
    y = "Średnia ocena (Skala Likerta 1–5)",
    fill = "Profil"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    axis.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 9, color = "black"),
    legend.position = "bottom"
  )


# ZALEŻNOŚCI Z METRYCZKĄ

tabela_plec <- table(df_peb_full$Profil_PEB, df_peb_full$gender)
tabela_plec
prop.table(tabela_plec, margin = 1) * 100
fisher.test(tabela_plec)


tabela_wiek <- table(df_peb_full$Profil_PEB, df_peb_full$age)
tabela_wiek
prop.table(tabela_wiek, margin = 1) * 100
fisher.test(tabela_wiek)

tabela_miejsce <- table(df_peb_full$Profil_PEB, df_peb_full$childhood_place_size)
tabela_miejsce
fisher.test(tabela_miejsce)

tabela_natura <- table(df_peb_full$Profil_PEB, df_peb_full$childhood_nature_freq)
tabela_natura
fisher.test(tabela_natura)


df_peb_full <- df_peb_full %>%
  mutate(field_study_agg = case_when(
    # STEM / Ścisłe / Inżynieryjne
    field_study %in% c("Informatyka / IT", "Informatyka, Językoznawstwo i literatura", 
                       "Interdyscyplinarne studia STEM", "Inżynieria, Informatyka, Matematyka", 
                       "Matematyka i statystyka") ~ "STEM i Ścisłe",
    
    # Nauki Społeczne, Ekonomia i Prawo
    field_study %in% c("Ekonomia i biznes", "Ekonomia, Nauki społeczne, Prawo", 
                       "Nauki społeczne", "Prawo", "Stosunki międzynarodowe / Polityka") ~ "Społeczne, Ekonomia i Prawo",
    
    # Humaniści i Językoznawstwo
    field_study %in% c("Językoznawstwo i literatura", "Nauki humanistyczne", 
                       "Nauki społeczne, Nauki humanistyczne") ~ "Humanistyczne i Językowe",
    
    # Przyrodnicze, Medyczne i Rolnicze
    field_study %in% c("Nauki przyrodnicze", "Nauki przyrodnicze, Inżynieria", 
                       "Nauki medyczne i o zdrowiu", "Inżynieria, Rolnictwo / Leśnictwo / Weterynaria") ~ "Przyrodnicze i Medyczne",
    
    # Sztuka i Muzyka
    field_study %in% c("Muzyka", "Sztuka i design", "Sztuki performatywne") ~ "Sztuka i Muzyka",
    
    TRUE ~ "Inne"
  ))


tabela_kierunek_agg <- table(df_peb_full$Profil_PEB, df_peb_full$field_study_agg)
print(tabela_kierunek_agg)

prop.table(tabela_kierunek_agg, margin = 1) * 100
fisher.test(tabela_kierunek_agg)


### Kraje - EPI

df_peb_full <- df_peb_full %>%
  mutate(epi_group = case_when(
    country %in% c("Dania", "Finlandia", "Szwecja", "Francja", 
                   "Austria", "Niemcy", "Wielka Brytania", "Hiszpania") ~ "Liderzy EPI",
    country %in% c("Polska", "Chorwacja", "Łotwa", "Litwa", 
                   "Włochy", "Portugalia", "Rumunia", "Chile", "Chiny", "Indie") ~ "Rozwijające się EPI",
    TRUE ~ "Inne"
  ))

tabela_epi <- table(df_peb_full$epi_group, df_peb_full$Profil_PEB)
print(tabela_epi)

test_fishera <- fisher.test(tabela_epi)
print(test_fishera)
