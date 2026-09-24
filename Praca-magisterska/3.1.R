#3.1

library(readxl)
library(ggplot2)
library(dplyr)
library(packcircles)
library(stringr)
library(treemapify)
library(grid)
library(ggthemes)

# Wczytanie danych
df <- read_excel("C:/Dane/Studia/magisterka/seminarium/ankieta_r/Environmental_Attitudes_and_Behaviors_R_ready.xlsx", sheet = "Data_Clean_PL")


# --- CHARAKTERYSTYKA RESPONDENTÓW ---


# 1. Wykres kołowy - Płeć

df %>%
  count(gender) %>%
  ggplot(aes(x = "", y = n, fill = gender)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y") +
  geom_text(aes(label = n), position = position_stack(vjust = 0.5)) +
  theme_void() +
  scale_fill_brewer(palette = "Pastel1") +
  labs(title = "Rozkład płci", fill = "Płeć")


# 2. Wykres słupkowy - Wiek

ggplot(df, aes(x = factor(age))) +
  geom_bar(fill = "steelblue") +
  theme_minimal() +
  scale_fill_brewer(palette = "Pastel1") +
  labs(title = "Rozkład wieku", x = "Wiek", y = "Liczba osób")


# 3. Wykres kołowy - Wielkość miejscowości z dzieciństwa

kolejnosc <- c(
  "Tereny wiejskie / wieś",
  "Małe miasteczko (<20 tys.)",
  "Średnie miasto (20–100 tys.)",
  "Duże miasto (100–500 tys.)",
  "Obszar metropolitalny (>500 tys.)"
)

df %>%
  mutate(childhood_place_size = factor(childhood_place_size, levels = kolejnosc)) %>%
  count(childhood_place_size) %>%
  ggplot(aes(x = "", y = n, fill = childhood_place_size)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y") +
  geom_text(aes(label = n), position = position_stack(vjust = 0.5)) +
  theme_void() +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Wielkość miejscowości z dzieciństwa", fill = "Miejscowość")


# 4. Wykres kołowy - Kontakt z naturą

kolejnosc_natury <- c("Rzadko", "Czasami", "Często", "Bardzo często")

df %>%
  mutate(childhood_nature_freq = factor(childhood_nature_freq, levels = kolejnosc_natury)) %>%
  count(childhood_nature_freq) %>%
  ggplot(aes(x = "", y = n, fill = childhood_nature_freq)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y") +
  geom_text(aes(label = n), position = position_stack(vjust = 0.5)) +
  theme_void() +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Częstość kontaktu z naturą w dzieciństwie", fill = "Częstość")


# 5. Wykres bąbelkowy - Kraj pochodzenia respondentów

set.seed(40)
data_country <- df %>%
  count(country, name = "n") %>% slice_sample(prop = 1)

packing <- circleProgressiveLayout(data_country$n, sizetype = 'area')
data_country <- cbind(data_country, packing)
dat.gg <- circleLayoutVertices(packing, npoints = 50)

ggplot() +
  geom_polygon(data = dat.gg, aes(x, y, group = id, fill = as.factor(id)), color = "white", alpha = 0.85) +
  geom_text(data = data_country, aes(x, y, label = paste0(country, "\n", n)), fontface = "bold", size = 3.2) +
  theme_void() +
  theme(legend.position = "none", plot.title = element_text(hjust = 0.5, face = "bold", size = 14)) +
  coord_equal() +
  scale_fill_tableau("Tableau 20") + 
  labs(title = "Kraj pochodzenia respondentów (N = 35)")


# 6. Treemap - Dziedzina studiów

data_field <- df %>%
  count(field_study, name = "n")

ggplot(data_field, aes(area = n, fill = field_study, label = paste0(field_study, "\n", n))) +
  geom_treemap(color = "white", linewidth = 1.5, show.legend = FALSE) +
  geom_treemap_text(
    colour = "black", 
    place = "center", 
    reflow = TRUE,
    fontface = "plain",
    size = 12,                 
    padding.x = unit(3, "mm"), 
    padding.y = unit(3, "mm")  
  ) +
  labs(title = "Dziedzina studiów respondentów (N = 35)") +
  scale_fill_tableau("Tableau 20") +
  theme(plot.title = element_text(hjust = 0.5, face = "bold", size = 14))
  
