# EDA Script: Exploratory Data Analysis
# Purpose: Generate summary statistics and initial visualizations
# Data: olympics_gdp_merged.csv (1960-2020 Olympics with GDP data)

library(tidyverse)

# Load the merged data
olympics_gdp <- read_csv("data/processed/olympics_gdp_merged.csv")


# ============================================================================
# SUMMARY STATISTICS
# ============================================================================

cat("=== OVERALL SUMMARY STATISTICS ===\n\n")

# Medal statistics
medal_stats <- olympics_gdp %>%
  summarise(
    n_observations = n(),
    n_countries = n_distinct(iso3c),
    n_years = n_distinct(Year),
    mean_medals = mean(Total_Medals),
    median_medals = median(Total_Medals),
    sd_medals = sd(Total_Medals),
    min_medals = min(Total_Medals),
    max_medals = max(Total_Medals)
  )

cat("MEDAL STATISTICS:\n")
print(medal_stats)

# GDP statistics
gdp_stats <- olympics_gdp %>%
  summarise(
    mean_gdp = mean(GDP),
    median_gdp = median(GDP),
    sd_gdp = sd(GDP),
    min_gdp = min(GDP),
    max_gdp = max(GDP)
  )

cat("\nGDP STATISTICS (current US$):\n")
print(gdp_stats)

# Summary by year
cat("\n=== SUMMARY BY OLYMPIC YEAR ===\n\n")
yearly_summary <- olympics_gdp %>%
  group_by(Year) %>%
  summarise(
    n_countries = n(),
    total_medals = sum(Total_Medals),
    mean_medals = mean(Total_Medals),
    median_medals = median(Total_Medals),
    mean_gdp = mean(GDP),
    median_gdp = median(GDP)
  )

print(yearly_summary, n = Inf)

# Save summary tables
write_csv(medal_stats, "figures/medal_summary_stats.csv")
write_csv(gdp_stats, "figures/gdp_summary_stats.csv")
write_csv(yearly_summary, "figures/yearly_summary.csv")

# ============================================================================
# CORRELATION ANALYSIS
# ============================================================================

cat("\n=== CORRELATION ANALYSIS ===\n\n")

# Overall correlation
correlation <- cor(olympics_gdp$GDP, olympics_gdp$Total_Medals)
cat("Correlation between GDP and Total Medals:", round(correlation, 3), "\n")

# Correlation by year
yearly_correlation <- olympics_gdp %>%
  group_by(Year) %>%
  summarise(
    correlation = cor(GDP, Total_Medals),
    n_countries = n()
  )

cat("\nCorrelation by Year:\n")
print(yearly_correlation, n = Inf)

write_csv(yearly_correlation, "figures/correlation_by_year.csv")

# ============================================================================
# TOP PERFORMERS
# ============================================================================

cat("\n=== TOP PERFORMERS ===\n\n")

# Top 10 countries by total medals (summed across all years)
top_overall <- olympics_gdp %>%
  group_by(Country, NOC) %>%
  summarise(
    total_medals = sum(Total_Medals),
    n_olympics = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(total_medals)) %>%
  head(10)

cat("Top 10 Countries by Total Medals (1960-2020):\n")
print(top_overall)

# Top 10 countries by average medals per Olympic appearance
top_average <- olympics_gdp %>%
  group_by(Country, NOC) %>%
  summarise(
    avg_medals = mean(Total_Medals),
    total_medals = sum(Total_Medals),
    n_olympics = n(),
    .groups = "drop"
  ) %>%
  filter(n_olympics >= 5) %>%  # At least 5 Olympic appearances
  arrange(desc(avg_medals)) %>%
  head(10)

cat("\nTop 10 Countries by Average Medals per Olympics (min 5 appearances):\n")
print(top_average)

write_csv(top_overall, "figures/top_countries_total.csv")
write_csv(top_average, "figures/top_countries_average.csv")

# ============================================================================
# VISUALIZATIONS
# ============================================================================

cat("\n=== CREATING VISUALIZATIONS ===\n\n")

# 1. Distribution of Total Medals
p1 <- ggplot(olympics_gdp, aes(x = Total_Medals)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  labs(
    title = "Distribution of Olympic Medal Counts",
    subtitle = "Summer Olympics 1960-2020",
    x = "Total Medals",
    y = "Frequency (Country-Year Observations)"
  ) +
  theme_minimal()

ggsave("figures/medal_distribution.png", p1, width = 8, height = 6, dpi = 300)
cat("✓ Saved medal_distribution.png\n")

# 2. Distribution of GDP (log scale for better visualization)
p2 <- ggplot(olympics_gdp, aes(x = GDP)) +
  geom_histogram(bins = 30, fill = "darkgreen", color = "white") +
  scale_x_log10(labels = scales::dollar_format(scale = 1e-9, suffix = "B")) +
  labs(
    title = "Distribution of GDP",
    subtitle = "Countries in Summer Olympics 1960-2020",
    x = "GDP (Billions USD, log scale)",
    y = "Frequency (Country-Year Observations)"
  ) +
  theme_minimal()

ggsave("figures/gdp_distribution.png", p2, width = 8, height = 6, dpi = 300)
cat("✓ Saved gdp_distribution.png\n")

# 3. Initial Scatterplot: GDP vs Total Medals
p3 <- ggplot(olympics_gdp, aes(x = GDP, y = Total_Medals)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  scale_x_log10(labels = scales::dollar_format(scale = 1e-9, suffix = "B")) +
  labs(
    title = "GDP vs Olympic Medal Count",
    subtitle = "Summer Olympics 1960-2020",
    x = "GDP (Billions USD, log scale)",
    y = "Total Medals",
    caption = "Data sources: Olympedia.org, World Bank"
  ) +
  theme_minimal()

ggsave("figures/gdp_vs_medals_initial.png", p3, width = 10, height = 7, dpi = 300)
cat("✓ Saved gdp_vs_medals_initial.png\n")

# 4. Time series: Total medals awarded over time
medals_over_time <- olympics_gdp %>%
  group_by(Year) %>%
  summarise(total_medals = sum(Total_Medals))

p4 <- ggplot(medals_over_time, aes(x = Year, y = total_medals)) +
  geom_line(color = "steelblue", size = 1) +
  geom_point(color = "steelblue", size = 3) +
  labs(
    title = "Total Olympic Medals Awarded Over Time",
    subtitle = "Summer Olympics 1960-2020",
    x = "Olympic Year",
    y = "Total Medals Awarded"
  ) +
  theme_minimal()

ggsave("figures/medals_over_time.png", p4, width = 10, height = 6, dpi = 300)
cat("✓ Saved medals_over_time.png\n")

# 5. Top 10 countries over time (line plot)
top_10_countries <- top_overall$NOC[1:10]

top_countries_time <- olympics_gdp %>%
  filter(NOC %in% top_10_countries)

p5 <- ggplot(top_countries_time, aes(x = Year, y = Total_Medals, color = Country, group = Country)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  labs(
    title = "Medal Performance of Top 10 Countries Over Time",
    subtitle = "Summer Olympics 1960-2020",
    x = "Olympic Year",
    y = "Total Medals",
    color = "Country"
  ) +
  theme_minimal() +
  theme(legend.position = "right")

ggsave("figures/top_countries_over_time.png", p5, width = 12, height = 7, dpi = 300)
cat("✓ Saved top_countries_over_time.png\n")

# ============================================================================
# IDENTIFY OUTLIERS
# ============================================================================

cat("\n=== IDENTIFYING OUTLIERS ===\n\n")

# High medals, low GDP (medals > 20, GDP < median GDP)
median_gdp <- median(olympics_gdp$GDP)

high_medals_low_gdp <- olympics_gdp %>%
  filter(Total_Medals > 20, GDP < median_gdp) %>%
  arrange(desc(Total_Medals)) %>%
  select(Year, Country, NOC, Total_Medals, GDP)

cat("Countries with High Medals (>20) but Below-Median GDP:\n")
print(high_medals_low_gdp, n = 20)

# Low medals, high GDP (medals < 5, GDP > median GDP)
low_medals_high_gdp <- olympics_gdp %>%
  filter(Total_Medals < 5, GDP > median_gdp) %>%
  arrange(desc(GDP)) %>%
  select(Year, Country, NOC, Total_Medals, GDP)

cat("\nCountries with Low Medals (<5) but Above-Median GDP:\n")
print(low_medals_high_gdp, n = 20)

write_csv(high_medals_low_gdp, "figures/outliers_high_medals_low_gdp.csv")
write_csv(low_medals_high_gdp, "figures/outliers_low_medals_high_gdp.csv")

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n=== EDA COMPLETE ===\n")
cat("✓ Summary statistics calculated and saved\n")
cat("✓ Correlation analysis completed\n")
cat("✓ Top performers identified\n")
cat("✓ 5 visualizations created and saved to figures/\n")
cat("✓ Outliers identified and documented\n")
cat("\nAll outputs saved to figures/ directory\n")

