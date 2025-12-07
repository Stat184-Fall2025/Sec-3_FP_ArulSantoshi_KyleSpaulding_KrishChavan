# GDP Data Cleaning Script
# 
# Data Source: World Bank Open Data
# Indicator: NY.GDP.MKTP.CD (GDP, current US$)
# URL: https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
# Downloaded: November 23, 2024
# File: API_NY.GDP.MKTP.CD_DS2_en_csv_v2_269001.csv

library(tidyverse)

# Read the World Bank GDP data
# The file typically has several header rows, so we need to skip them
gdp_raw <- read_csv("API_NY.GDP.MKTP.CD_DS2_en_csv_v2_269001.csv", 
                    skip = 4)  # Skip the first 4 metadata rows

# Check the column names
colnames(gdp_raw)

# Clean and reshape the data
gdp_clean <- gdp_raw %>%
  # Select country info and year columns
  # Column names are: "Country Name", "Country Code", "Indicator Name", "Indicator Code", "1960", "1961", etc.
  select(
    Country = `Country Name`,
    iso3c = `Country Code`,
    `1960`:`2023`  # Select all year columns from 1960 to most recent
  ) %>%
  # Pivot from wide to long format
  # This converts year columns into rows
  pivot_longer(
    cols = `1960`:`2023`,
    names_to = "Year",
    values_to = "GDP"
  ) %>%
  # Convert Year to numeric
  mutate(Year = as.numeric(Year)) %>%
  # Remove rows with missing GDP values
  filter(!is.na(GDP)) %>%
  # Filter to only Olympic years from 1960-2020
  filter(Year %in% c(1960, 1964, 1968, 1972, 1976, 1980, 
                     1984, 1988, 1992, 1996, 2000, 2004, 
                     2008, 2012, 2016, 2020))

# Check the result
glimpse(gdp_clean)
head(gdp_clean, 20)

# Check how many countries and years we have
cat("Number of unique countries:", n_distinct(gdp_clean$Country), "\n")
cat("Number of unique years:", n_distinct(gdp_clean$Year), "\n")
cat("Total rows:", nrow(gdp_clean), "\n")

# Save the cleaned GDP data
write_csv(gdp_clean, "gdp_clean.csv")

cat("\nGDP data cleaned and saved as gdp_clean.csv\n")

