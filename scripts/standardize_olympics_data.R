library(tidyverse)
library(countrycode)

# Load both datasets
olympics <- read_csv("olympics_medals_summer_clean.csv")
gdp <- read_csv("gdp_clean.csv")

# Convert Olympic NOC codes to ISO3 codes with manual fixes
olympics_standardized <- olympics %>%
  mutate(
    # Use countrycode to convert NOC (IOC codes) to ISO3 codes
    iso3c = countrycode(NOC, origin = "ioc", destination = "iso3c")
  ) %>%
  # Remove entities that don't have GDP data available
  filter(
    !NOC %in% c(
      "UAR",  # United Arab Republic (historical - Egypt+Syria union)
      "WIF",  # West Indies Federation (historical - dissolved 1962)
      "AHO",  # Netherlands Antilles (historical - dissolved 2010)
      "KOS",  # Kosovo (not in World Bank GDP data)
      "TPE",  # Chinese Taipei/Taiwan (not in World Bank GDP data)
      "PRK"   # North Korea (not in World Bank GDP data)
    )
  ) %>%
  # Also remove any that failed to convert to iso3c
  filter(!is.na(iso3c))

# Summary of removals
cat("=== COUNTRIES REMOVED (no GDP data available) ===\n")
removed_countries <- olympics %>%
  filter(NOC %in% c("UAR", "WIF", "AHO", "KOS", "TPE", "PRK")) %>%
  distinct(NOC, Country) %>%
  arrange(Country)
print(removed_countries)

cat("\n=== IMPACT OF REMOVALS ===\n")
cat("Countries removed:", medals_removed$countries, "\n")
cat("Country-year observations removed:", medals_removed$total_rows, "\n")
cat("Total medals removed:", medals_removed$total_medals, "\n")

# Save standardized data
write_csv(olympics_standardized, "olympics_medals_standardized.csv")

cat("\nSaved as olympics_medals_standardized.csv\n")
cat("Ready for merging with GDP data\n")
