#3.4

library(dplyr)
library(ggplot2)
library(stats)


df_merged <- inner_join(
  df_nep_full %>% select(id, Profil_NEP),
  df_peb_full %>% select(id, Profil_PEB),
  by = "id"
)

df_merged


tabela_postawy_zachowania <- table(NEP = df_merged$Profil_NEP, PEB = df_merged$Profil_PEB)
print(tabela_postawy_zachowania)

prop.table(tabela_postawy_zachowania, margin = 1) * 100


test_fishera <- fisher.test(tabela_postawy_zachowania)
print(test_fishera)


#### INDEKSY NEP I PEB

df_nep_full$Indeks_NEP <- rowMeans(df_nep_full %>% select(starts_with("nep_")), na.rm = TRUE)
df_peb_full$Indeks_PEB <- rowMeans(df_peb_full %>% select(starts_with("peb_")), na.rm = TRUE)

df_indeksy <- inner_join(
  df_nep_full %>% select(id, Indeks_NEP),
  df_peb_full %>% select(id, Indeks_PEB),
  by = "id"
)


korelacja <- cor.test(df_indeksy$Indeks_NEP, df_indeksy$Indeks_PEB, method = "spearman")
print(korelacja)

ggplot(df_indeksy, aes(x = Indeks_NEP, y = Indeks_PEB)) +
  geom_point(color = "#2E7D32", size = 3, alpha = 0.7) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Zależność między postawami (NEP) a zachowaniami proekologicznymi (PEB)",
    subtitle = "Współczynnik korelacji Spearmana: rho = 0.516, p = 0.0015",
    x = "Ogólny Indeks Postaw (NEP)",
    y = "Ogólny Indeks Zachowań (PEB)"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  )
