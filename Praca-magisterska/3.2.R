#3.2

library(readxl)
library(dplyr)
library(psych)

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


# pytania parzyste (antropocentryczne) do odwrócenia
parzyste_nep <- c(
  "nep_2_modify", 
  "nep_4_ingenuity", 
  "nep_6_resources", 
  "nep_8_balance_strong", 
  "nep_10_exaggerated", 
  "nep_12_rule", 
  "nep_14_control"
)

# odwrócenie skali dla tych pytań (1->5, 2->4, 3->3, 4->2, 5->1)

df_nep <- df_raw %>%
  select(starts_with("nep_")) %>%
  mutate(across(all_of(parzyste_nep), ~ 6 - .x))

df_nep_full <- bind_cols(df_metrics, df_nep)


cor_matrix_nep <- cor(df_nep)
korelacja_nep <- round(cor_matrix_nep, 2)
korelacja_nep


### ANALIZA RZETELNOŚCI

rel_alpha <- psych::alpha(df_nep)
print(rel_alpha)

rel_omega <- psych::omega(df_nep, nfactors = 3)
print(rel_omega)


### ANALIZA SKUPIEŃ

dane_nep <- df_nep
dane_scaled_nep <- scale(dane_nep)

macierz_odleglosci <- dist(dane_scaled_nep, method = "euclidean")
fit_ward <- hclust(macierz_odleglosci, method = "ward.D2")

plot(fit_ward, main = "Profile postaw NEP wśród badanych", xlab = "Badani", sub = "")
rect.hclust(fit_ward, k = 2, border = "red") 

df_nep_full$Profil_NEP <- cutree(fit_ward, k = 2)
df_nep_full$Profil_NEP <- factor(df_nep_full$Profil_NEP, labels = c("Profil 1", "Profil 2"))


dane_nep %>% 
  mutate(Profil = df_nep_full$Profil_NEP) %>% 
  group_by(Profil) %>% 
  summarise(across(everything(), mean)) %>% 
  t()


table(df_nep_full$Profil_NEP)



# ZALEŻNOŚCI Z METRYCZKĄ

tabela_plec <- table(df_nep_full$Profil_NEP, df_nep_full$gender)
tabela_plec
prop.table(tabela_plec, margin = 1) * 100
fisher.test(tabela_plec)


tabela_wiek <- table(df_nep_full$Profil_NEP, df_nep_full$age)
tabela_wiek
prop.table(tabela_wiek, margin = 1) * 100
fisher.test(tabela_wiek)

tabela_miejsce <- table(df_nep_full$Profil_NEP, df_nep_full$childhood_place_size)
tabela_miejsce
fisher.test(tabela_miejsce)

tabela_natura <- table(df_nep_full$Profil_NEP, df_nep_full$childhood_nature_freq)
tabela_natura
fisher.test(tabela_natura)


df_nep_full <- df_nep_full %>%
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


tabela_kierunek_agg <- table(df_nep_full$Profil_NEP, df_nep_full$field_study_agg)
print(tabela_kierunek_agg)

prop.table(tabela_kierunek_agg, margin = 1) * 100
fisher.test(tabela_kierunek_agg)


### Kraje - EPI

df_nep_full <- df_nep_full %>%
  mutate(epi_group = case_when(
    country %in% c("Dania", "Finlandia", "Szwecja", "Francja", 
                   "Austria", "Niemcy", "Wielka Brytania", "Hiszpania") ~ "Liderzy EPI",
    country %in% c("Polska", "Chorwacja", "Łotwa", "Litwa", 
                   "Włochy", "Portugalia", "Rumunia", "Chile", "Chiny", "Indie") ~ "Rozwijające się EPI",
    TRUE ~ "Inne"
  ))

tabela_epi <- table(df_nep_full$epi_group, df_nep_full$Profil_NEP)
print(tabela_epi)

test_fishera <- fisher.test(tabela_epi)
print(test_fishera)



## Ogólny Indeks NEP

df_nep_full$Indeks_NEP <- rowMeans(df_nep_full %>% select(starts_with("nep_")), na.rm = TRUE)

srednie_profilow <- df_nep_full %>%
  group_by(Profil_NEP) %>%
  summarise(Srednia_NEP = mean(Indeks_NEP, na.rm = TRUE))

print(srednie_profilow)
