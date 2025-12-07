# Efficiency Analysis Script
# Purpose: Calculate medals per GDP dollar to identify efficient countries
# Data: olympics_gdp_merged.csv

library(tidyverse)

# Load data
olympics_gdp <- read_csv("data/processed/olympics_gdp_merged.csv")

# ============================================================================
# CALCULATE MEDALS PER BILLION GDP
# ============================================================================

cat("=== CALCULATING EFFICIENCY METRICS ===\n\n")

# Calculate medals per billion GDP for each country-year
olympics_efficiency <- olympics_gdp %>%
  mutate(
    GDP_billions = GDP / 1e9,  # Convert to billions for readability
    medals_per_billion_gdp = Total_Medals / GDP_billions
  )

# Summary statistics
efficiency_stats <- olympics_efficiency %>%
  summarise(
    mean_efficiency = mean(medals_per_billion_gdp),
    median_efficiency = median(medals_per_billion_gdp),
    sd_efficiency = sd(medals_per_billion_gdp),
    min_efficiency = min(medals_per_billion_gdp),
    max_efficiency = max(medals_per_billion_gdp)
  )

cat("Medals per Billion GDP Statistics:\n")
print(efficiency_stats)

# ============================================================================
# TOP EFFICIENT COUNTRIES (BY COUNTRY-YEAR)
# ============================================================================

cat("\n=== TOP 20 MOST EFFICIENT COUNTRY-YEAR OBSERVATIONS ===\n")

top_efficiency_instances <- olympics_efficiency %>%
  arrange(desc(medals_per_billion_gdp)) %>%
  select(Year, Country, NOC, Total_Medals, GDP_billions, medals_per_billion_gdp) %>%
  head(20)

print(top_efficiency_instances)

# ============================================================================
# AVERAGE EFFICIENCY BY COUNTRY (across all Olympic appearances)
# ============================================================================

cat("\n=== TOP 20 COUNTRIES BY AVERAGE EFFICIENCY ===\n")

avg_efficiency_by_country <- olympics_efficiency %>%
  group_by(Country, NOC) %>%
  summarise(
    n_olympics = n(),
    avg_medals = mean(Total_Medals),
    avg_gdp_billions = mean(GDP_billions),
    avg_efficiency = mean(medals_per_billion_gdp),
    total_medals = sum(Total_Medals),
    .groups = "drop"
  ) %>%
  arrange(desc(avg_efficiency))

# Top 20 most efficient
top_20_efficient <- avg_efficiency_by_country %>%
  head(20)

print(top_20_efficient)

# Require at least 5 Olympic appearances for robustness
cat("\n=== TOP 15 COUNTRIES BY EFFICIENCY (min 5 Olympics) ===\n")

top_15_consistent <- avg_efficiency_by_country %>%
  filter(n_olympics >= 5) %>%
  head(15)

print(top_15_consistent)

# ============================================================================
# LEAST EFFICIENT COUNTRIES (UNDER-PERFORMERS)
# ============================================================================

cat("\n=== 15 LEAST EFFICIENT COUNTRIES (min 5 Olympics) ===\n")

least_efficient <- avg_efficiency_by_country %>%
  filter(n_olympics >= 5) %>%
  arrange(avg_efficiency) %>%
  head(15)

print(least_efficient)

# ============================================================================
# SAVE RESULTS
# ============================================================================

write_csv(olympics_efficiency, "data/processed/olympics_efficiency.csv")
write_csv(avg_efficiency_by_country, "figures/efficiency_by_country.csv")
write_csv(top_20_efficient, "figures/top_20_efficient_countries.csv")
write_csv(least_efficient, "figures/least_efficient_countries.csv")

cat("\n✓ Saved efficiency datasets\n")

# ============================================================================
# VISUALIZATIONS
# ============================================================================

cat("\n=== CREATING VISUALIZATIONS ===\n")

# 1. Bar chart: Top 15 most efficient countries (min 5 Olympics)
p_efficiency_bar <- ggplot(top_15_consistent, 
                           aes(x = reorder(Country, avg_efficiency), 
                               y = avg_efficiency)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Most Efficient Countries: Medals per Billion GDP",
    subtitle = "Average across all Olympic appearances (minimum 5 Olympics, 1960-2020)",
    x = NULL,
    y = "Average Medals per Billion USD GDP",
    caption = "Data sources: Olympedia.org, World Bank"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold"),
    axis.text.y = element_text(size = 10)
  )

ggsave("figures/top_efficient_countries_bar.png", p_efficiency_bar, 
       width = 10, height = 8, dpi = 300)
cat("✓ Saved top_efficient_countries_bar.png\n")

# 2. Scatterplot: GDP vs Efficiency (medals per billion)
p_gdp_vs_efficiency <- ggplot(olympics_efficiency, 
                              aes(x = GDP_billions, y = medals_per_billion_gdp)) +
  geom_point(alpha = 0.4, color = "steelblue") +
  scale_x_log10(labels = scales::comma_format(suffix = "B")) +
  geom_smooth(method = "loess", color = "red", se = TRUE, alpha = 0.2) +
  labs(
    title = "GDP vs Medal Efficiency",
    subtitle = "Smaller economies tend to be more efficient per GDP dollar",
    x = "GDP (Billions USD, log scale)",
    y = "Medals per Billion GDP",
    caption = "Data sources: Olympedia.org, World Bank"
  ) +
  theme_minimal()

ggsave("figures/gdp_vs_efficiency.png", p_gdp_vs_efficiency, 
       width = 10, height = 7, dpi = 300)
cat("✓ Saved gdp_vs_efficiency.png\n")

# 3. Comparison: Top efficient vs Top total medals
top_medals <- olympics_gdp %>%
  group_by(Country, NOC) %>%
  summarise(total_medals = sum(Total_Medals), .groups = "drop") %>%
  arrange(desc(total_medals)) %>%
  head(10) %>%
  mutate(category = "Top 10 by Total Medals")

top_efficient_compare <- top_15_consistent %>%
  head(10) %>%
  select(Country, NOC) %>%
  mutate(category = "Top 10 by Efficiency")

comparison <- bind_rows(top_medals, top_efficient_compare)

p_comparison <- ggplot(comparison, aes(x = category, fill = category)) +
  geom_bar() +
  facet_wrap(~Country, ncol = 5) +
  labs(
    title = "Top Medal Winners vs Top Efficient Countries",
    subtitle = "Different countries excel in total medals vs efficiency",
    x = NULL,
    y = "Count"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_blank(),
    strip.text = element_text(size = 8)
  )

# Actually, let's make this simpler - just show which countries appear in both lists
cat("\n=== OVERLAP ANALYSIS ===\n")

top_10_medals_countries <- olympics_gdp %>%
  group_by(Country, NOC) %>%
  summarise(total_medals = sum(Total_Medals), .groups = "drop") %>%
  arrange(desc(total_medals)) %>%
  head(10) %>%
  pull(NOC)

top_10_efficient_countries <- top_15_consistent %>%
  head(10) %>%
  pull(NOC)

overlap <- intersect(top_10_medals_countries, top_10_efficient_countries)

cat("Countries in BOTH top 10 total medals AND top 10 efficiency:\n")
if(length(overlap) > 0) {
  print(overlap)
} else {
  cat("No overlap - different countries excel at total medals vs efficiency!\n")
}

cat("\nTop 10 by Total Medals:\n")
print(top_10_medals_countries)

cat("\nTop 10 by Efficiency:\n")
print(top_10_efficient_countries)

# ============================================================================
# KEY INSIGHTS
# ============================================================================

cat("\n=== KEY INSIGHTS ===\n\n")

# Highest efficiency country
most_efficient <- top_15_consistent[1, ]
cat("Most efficient country (min 5 Olympics):", most_efficient$Country, "\n")
cat("  - Average efficiency:", round(most_efficient$avg_efficiency, 2), 
    "medals per billion GDP\n")
cat("  - Average medals per Olympics:", round(most_efficient$avg_medals, 1), "\n")
cat("  - Number of Olympics:", most_efficient$n_olympics, "\n\n")

# Least efficient with high GDP
underperformer <- least_efficient[1, ]
cat("Least efficient country (min 5 Olympics):", underperformer$Country, "\n")
cat("  - Average efficiency:", round(underperformer$avg_efficiency, 3), 
    "medals per billion GDP\n")
cat("  - Average GDP:", round(underperformer$avg_gdp_billions, 0), "billion USD\n")
cat("  - Average medals per Olympics:", round(underperformer$avg_medals, 1), "\n\n")

# Relationship between GDP size and efficiency
cor_gdp_efficiency <- cor(olympics_efficiency$GDP_billions, 
                          olympics_efficiency$medals_per_billion_gdp)
cat("Correlation between GDP and efficiency:", round(cor_gdp_efficiency, 3), "\n")
if(cor_gdp_efficiency < 0) {
  cat("→ NEGATIVE correlation: Smaller economies tend to be MORE efficient\n\n")
} else {
  cat("→ POSITIVE correlation: Larger economies tend to be MORE efficient\n\n")
}

cat("=== EFFICIENCY ANALYSIS COMPLETE ===\n")
cat("✓ Calculated medals per billion GDP\n")
cat("✓ Identified most and least efficient countries\n")
cat("✓ Created visualizations\n")
cat("✓ Saved results to data/processed/ and figures/\n")
