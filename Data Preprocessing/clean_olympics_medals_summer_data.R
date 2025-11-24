library(tidyverse)

# Read the data
olympics_full <- read_csv("olympics_medals_summer_unclean.csv")

# Fix special characters and remove non-country teams
olympics_full <- olympics_full %>%
  mutate(Country = case_when(
    Country == "Türkiye" | NOC == "TUR" ~ "Turkey",
    Country == "Côte d'Ivoire" | NOC == "CIV" ~ "Cote d'Ivoire",
    TRUE ~ Country
  )) %>%
  # Remove teams that don't correspond to current countries with (current) GDP data
  filter(
    !NOC %in% c(
      "BOH",  # Bohemia (historical)
      "ANZ",  # Australasia (Australia + New Zealand combined team)
      "IOA",  # Independent Olympic Athletes
      "MIX",  # Mixed team (Joint team)
      "ROC",  # Russian Olympic Committee (not officially Russia)
      "SCG",  # Serbia and Montenegro (Joint team)
      "EUN",  # Unified Team (former Soviet states in 1992)
      "URS",  # Soviet Union (dissolved, now various countries)
      "GDR",  # East Germany (dissolved, now Germany)
      "FRG",  # West Germany (dissolved, now Germany)
      "TCH",  # Czechoslovakia (dissolved, now Czech Republic)
      "YUG"   # Yugoslavia (dissolved, now various countries)
    )
  )

# Check what we removed
cat("Removed teams:\n")
read_csv("olympics_medals_summer_unclean.csv") %>%
  anti_join(olympics_full, by = c("Country", "NOC", "Year", "Gold", "Silver", "Bronze", "Total")) %>%
  distinct(Country, NOC) %>%
  arrange(NOC) %>%
  print()

# Check final row count
cat("\nOriginal rows:", nrow(read_csv("olympics_medals_summer_unclean.csv")), "\n")
cat("After filtering:", nrow(olympics_full), "\n")
cat("Rows removed:", nrow(read_csv("olympics_medals_summer_unclean.csv")) - nrow(olympics_full), "\n")

# Save the cleaned version
write_csv(olympics_full, "olympics_medals_summer_clean.csv")

cat("\nFixed special characters and removed non-country teams\n")
cat("Saved as olympics_medals_summer_clean.csv\n")
