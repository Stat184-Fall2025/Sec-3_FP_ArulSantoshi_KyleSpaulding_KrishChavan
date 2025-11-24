library(tidyverse)

# Load both standardized datasets
olympics <- read_csv("olympics_medals_standardized.csv")
gdp <- read_csv("gdp_clean.csv")

# Filter Olympics data to 1960 onwards (when GDP data begins)
olympics_1960_onwards <- olympics %>%
  filter(Year >= 1960)

# Perform the merge
olympics_gdp_merged <- olympics_1960_onwards %>%
  inner_join(gdp, by = c("iso3c", "Year")) %>%
  select(
    Year,
    Country = Country.x,
    NOC,
    iso3c,
    Gold,
    Silver,
    Bronze,
    Total_Medals = Total,
    GDP
  ) %>%
  filter(!is.na(GDP))

# Check which Olympics countries didn't have GDP data
olympics_no_gdp <- olympics_1960_onwards %>%
  anti_join(gdp, by = c("iso3c", "Year")) %>%
  distinct(Country, NOC, iso3c) %>%
  arrange(Country)

cat("\n=== OLYMPICS COUNTRIES MISSING GDP DATA ===\n")
cat("(These won medals in 1960-2020 but lack GDP data for those specific years)\n")
print(olympics_no_gdp, n = Inf)
cat("Total countries:", nrow(olympics_no_gdp), "\n")

# Count how many medals were lost
medals_lost <- olympics_1960_onwards %>%
  anti_join(gdp, by = c("iso3c", "Year")) %>%
  summarise(
    rows_lost = n(),
    medals_lost = sum(Total)
  )

cat("\n=== DATA LOSS FROM MERGE ===\n")
cat("Country-year observations lost:", medals_lost$rows_lost, "\n")
cat("Total medals lost:", medals_lost$medals_lost, "\n")
cat("Percentage of 1960+ data retained:", 
    round(100 * nrow(olympics_gdp_merged) / nrow(olympics_1960_onwards), 1), "%\n")

# Save the merged dataset
write_csv(olympics_gdp_merged, "olympics_gdp_merged.csv")

cat("\nSaved merged dataset to olympics_gdp_merged.csv\n")
cat("Final dataset: 1960-2020 Olympics with GDP data, ready for analysis\n")
