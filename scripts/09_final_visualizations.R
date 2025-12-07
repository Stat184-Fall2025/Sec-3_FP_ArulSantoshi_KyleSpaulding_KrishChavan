# Final Publication-Quality Visualizations
# Purpose: Create polished, consistent visualizations for report and presentation
# Creates 5-6 key plots that tell the project story

library(tidyverse)
library(scales)

# Load data
olympics_gdp <- read_csv("data/processed/olympics_gdp_merged.csv")
olympics_efficiency <- read_csv("data/processed/olympics_efficiency.csv")

# Load model data if needed
olympics_residuals <- read_csv("data/processed/olympics_gdp_with_residuals.csv")

# ============================================================================
# DEFINE CONSISTENT THEME
# ============================================================================

# Custom theme for all plots
theme_olympics <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 16, margin = margin(b = 10)),
      plot.subtitle = element_text(size = 12, color = "gray40", margin = margin(b = 15)),
      plot.caption = element_text(size = 9, color = "gray50", hjust = 0, margin = margin(t = 15)),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10),
      legend.title = element_text(face = "bold"),
      legend.position = "right",
      panel.grid.minor = element_blank(),
      plot.margin = margin(20, 20, 20, 20)
    )
}

# Color palette
color_primary <- "#2E86AB"    # Blue
color_secondary <- "#A23B72"  # Purple
color_accent <- "#F18F01"     # Orange
color_positive <- "#06A77D"   # Green
color_negative <- "#C73E1D"   # Red

cat("=== CREATING PUBLICATION-QUALITY VISUALIZATIONS ===\n\n")

# ============================================================================
# VISUALIZATION 1: GDP vs Medals - Main Relationship (HERO PLOT - LOG SCALE)
# ============================================================================

cat("Creating Plot 1: GDP vs Medals with Regression (LOG SCALE)...\n")

# Label only select 2020 examples to avoid clutter
olympics_labeled <- olympics_gdp %>%
  mutate(label = case_when(
    Year == 2020 & NOC == "USA" ~ "USA",
    Year == 2020 & NOC == "CHN" ~ "China",
    Year == 2020 & NOC == "IND" ~ "India",
    Year == 2020 & NOC == "HUN" ~ "Hungary",
    Year == 2020 & NOC == "KEN" ~ "Kenya",
    Year == 2020 & NOC == "JAM" ~ "Jamaica",
    TRUE ~ ""
  ))

p1_hero <- ggplot(olympics_gdp, aes(x = GDP / 1e9, y = Total_Medals)) +
  geom_point(alpha = 0.3, color = color_primary, size = 2) +
  geom_smooth(method = "lm", color = color_accent, fill = color_accent, 
              alpha = 0.2, linewidth = 1.2) +
  # Add labels for 2020 examples only
  geom_text(data = olympics_labeled %>% filter(label != "", Year == 2020), 
            aes(label = label), 
            size = 3.5, hjust = -0.1, vjust = 0.5, 
            color = "gray20", fontface = "bold") +
  scale_x_log10(labels = comma_format(suffix = "B"),
                breaks = c(1, 10, 100, 1000, 10000)) +
  labs(
    title = "Economic Power Predicts Olympic Success",
    subtitle = "GDP explains 47% of variance in medal counts (R² = 0.47, p < 0.001)",
    x = "GDP (Billions USD, log scale)",
    y = "Total Olympic Medals",
    caption = "Data: Olympedia.org, World Bank (Summer Olympics 1960-2020, 902 country-year observations)\nNote: Each point represents one country in one Olympic year. Log scale spreads data across all GDP levels.\nLabels show 2020 Olympics for reference countries."
  ) +
  theme_olympics()

ggsave("figures/final/01_gdp_medals_relationship.png", p1_hero, 
       width = 12, height = 8, dpi = 300)
cat("✓ Saved 01_gdp_medals_relationship.png\n\n")

# ============================================================================
# VISUALIZATION 2: Efficiency Champions - Bar Chart
# ============================================================================

cat("Creating Plot 2: Most Efficient Countries...\n")

# Calculate average efficiency by country (min 5 Olympics)
top_efficient <- olympics_efficiency %>%
  mutate(GDP_billions = GDP / 1e9,
         efficiency = Total_Medals / GDP_billions) %>%
  group_by(Country, NOC) %>%
  summarise(
    n_olympics = n(),
    avg_efficiency = mean(efficiency),
    .groups = "drop"
  ) %>%
  filter(n_olympics >= 5) %>%
  arrange(desc(avg_efficiency)) %>%
  head(12)

p2_efficiency <- ggplot(top_efficient, 
                        aes(x = reorder(Country, avg_efficiency), 
                            y = avg_efficiency)) +
  geom_col(fill = color_positive, alpha = 0.8) +
  geom_text(aes(label = round(avg_efficiency, 2)), 
            hjust = -0.2, size = 3.5, fontface = "bold") +
  coord_flip() +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  labs(
    title = "Most Efficient Olympic Performers",
    subtitle = "Hungary leads with 1.33 medals per billion GDP—162x more efficient than India",
    x = NULL,
    y = "Average Medals per Billion USD GDP",
    caption = "Data: Olympedia.org, World Bank (Summer Olympics 1960-2020)\nIncludes countries with minimum 5 Olympic appearances"
  ) +
  theme_olympics() +
  theme(panel.grid.major.y = element_blank())

ggsave("figures/final/02_efficiency_champions.png", p2_efficiency, 
       width = 11, height = 8, dpi = 300)
cat("✓ Saved 02_efficiency_champions.png\n\n")

# ============================================================================
# VISUALIZATION 3: The Efficiency Paradox - GDP vs Efficiency
# ============================================================================

cat("Creating Plot 3: GDP Size vs Efficiency...\n")

olympics_eff_plot <- olympics_efficiency %>%
  mutate(GDP_billions = GDP / 1e9,
         efficiency = Total_Medals / GDP_billions)

# Highlight key countries
highlight_countries <- c("HUN", "IND", "USA", "KEN", "JAM", "CHN")

p3_paradox <- ggplot(olympics_eff_plot, 
                     aes(x = GDP_billions, y = efficiency)) +
  geom_point(alpha = 0.3, color = color_primary, size = 2) +
  # Highlight special countries
  geom_point(data = olympics_eff_plot %>% filter(NOC %in% highlight_countries),
             aes(color = NOC), size = 3, alpha = 0.8) +
  geom_smooth(method = "loess", color = color_negative, fill = color_negative,
              alpha = 0.2, linewidth = 1) +
  scale_x_log10(labels = comma_format(suffix = "B")) +
  scale_color_manual(values = c("HUN" = "#06A77D", "IND" = "#C73E1D", 
                                "USA" = "#2E86AB", "KEN" = "#F18F01",
                                "JAM" = "#A23B72", "CHN" = "#7209B7"),
                     labels = c("Hungary", "India", "USA", "Kenya", "Jamaica", "China")) +
  labs(
    title = "The Efficiency Paradox: Smaller Economies Perform Better",
    subtitle = "Negative correlation (r = -0.12): Larger GDP doesn't guarantee efficiency",
    x = "GDP (Billions USD, log scale)",
    y = "Medals per Billion GDP",
    color = "Featured\nCountries",
    caption = "Data: Olympedia.org, World Bank (Summer Olympics 1960-2020)\nEach point represents one country in one Olympic year"
  ) +
  theme_olympics()

ggsave("figures/final/03_efficiency_paradox.png", p3_paradox, 
       width = 12, height = 8, dpi = 300)
cat("✓ Saved 03_efficiency_paradox.png\n\n")

# ============================================================================
# VISUALIZATION 4: Top Performers Over Time
# ============================================================================

cat("Creating Plot 4: Medal Trends Over Time...\n")

# Get top 8 countries by total medals
top_8_countries <- olympics_gdp %>%
  group_by(Country, NOC) %>%
  summarise(total = sum(Total_Medals), .groups = "drop") %>%
  arrange(desc(total)) %>%
  head(8) %>%
  pull(NOC)

olympics_top8 <- olympics_gdp %>%
  filter(NOC %in% top_8_countries)

p4_trends <- ggplot(olympics_top8, 
                    aes(x = Year, y = Total_Medals, color = Country, group = Country)) +
  geom_line(linewidth = 1.2, alpha = 0.8) +
  geom_point(size = 2.5, alpha = 0.8) +
  scale_color_brewer(palette = "Set2") +
  scale_x_continuous(breaks = seq(1960, 2020, 8)) +
  labs(
    title = "Olympic Dominance Over Time",
    subtitle = "USA and China lead, but competition has intensified",
    x = "Olympic Year",
    y = "Total Medals",
    color = "Country",
    caption = "Data: Olympedia.org, World Bank (Summer Olympics 1960-2020)\nTop 8 countries by total medal count"
  ) +
  theme_olympics() +
  theme(legend.position = "right")

ggsave("figures/final/04_medal_trends_over_time.png", p4_trends, 
       width = 12, height = 7, dpi = 300)
cat("✓ Saved 04_medal_trends_over_time.png\n\n")

# ============================================================================
# VISUALIZATION 5: Over/Under Performers - Residual Plot
# ============================================================================

cat("Creating Plot 5: Over and Under Performers...\n")

# Calculate average residuals by country
avg_residuals <- olympics_residuals %>%
  group_by(Country, NOC) %>%
  summarise(
    avg_residual = mean(residuals),
    n_olympics = n(),
    avg_medals = mean(Total_Medals),
    .groups = "drop"
  ) %>%
  filter(n_olympics >= 5) %>%
  arrange(desc(abs(avg_residual)))

# Get top 10 over-performers and top 10 under-performers
top_10_over <- avg_residuals %>% 
  arrange(desc(avg_residual)) %>% 
  head(10) %>%
  mutate(category = "Over-performers")

top_10_under <- avg_residuals %>% 
  arrange(avg_residual) %>% 
  head(10) %>%
  mutate(category = "Under-performers")

residual_plot_data <- bind_rows(top_10_over, top_10_under)

p5_residuals <- ggplot(residual_plot_data, 
                       aes(x = reorder(Country, avg_residual), 
                           y = avg_residual,
                           fill = category)) +
  geom_col() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray30") +
  coord_flip() +
  scale_fill_manual(values = c("Over-performers" = color_positive, 
                               "Under-performers" = color_negative)) +
  labs(
    title = "Countries That Defy Economic Predictions",
    subtitle = "Positive values = more medals than GDP predicts | Negative = fewer medals than expected",
    x = NULL,
    y = "Average Residual (Actual Medals - Predicted Medals)",
    fill = "Category",
    caption = "Data: Olympedia.org, World Bank (Summer Olympics 1960-2020)\nBased on linear regression model (Total Medals ~ GDP)\nIncludes countries with minimum 5 Olympic appearances"
  ) +
  theme_olympics() +
  theme(legend.position = "bottom")

ggsave("figures/final/05_over_under_performers.png", p5_residuals, 
       width = 11, height = 9, dpi = 300)
cat("✓ Saved 05_over_under_performers.png\n\n")

# ============================================================================
# VISUALIZATION 6: Correlation Over Time (Bonus)
# ============================================================================

cat("Creating Plot 6: GDP-Medal Correlation Over Time...\n")

correlation_by_year <- olympics_gdp %>%
  group_by(Year) %>%
  summarise(
    correlation = cor(GDP, Total_Medals),
    n_countries = n()
  )

p6_correlation <- ggplot(correlation_by_year, aes(x = Year, y = correlation)) +
  geom_line(color = color_primary, linewidth = 1.5) +
  geom_point(color = color_primary, size = 4) +
  geom_hline(yintercept = 0.687, linetype = "dashed", color = color_accent,
             linewidth = 1) +
  annotate("text", x = 1985, y = 0.75, 
           label = "Overall correlation = 0.687", 
           color = color_accent, fontface = "bold", size = 4) +
  annotate("rect", xmin = 1978, xmax = 1982, ymin = 0, ymax = 0.3,
           alpha = 0.2, fill = color_negative) +
  annotate("text", x = 1980, y = 0.35, 
           label = "1980 Moscow\nBoycott", 
           size = 3, color = color_negative, fontface = "bold") +
  scale_x_continuous(breaks = seq(1960, 2020, 8)) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2)) +
  labs(
    title = "GDP Became a Stronger Predictor Over Time",
    subtitle = "Correlation strengthened from 1980s onward (except 1980 boycott anomaly)",
    x = "Olympic Year",
    y = "Correlation (GDP vs Total Medals)",
    caption = "Data: Olympedia.org, World Bank (Summer Olympics 1960-2020)\nDashed line shows overall correlation across all years"
  ) +
  theme_olympics()

ggsave("figures/final/06_correlation_over_time.png", p6_correlation, 
       width = 12, height = 7, dpi = 300)
cat("✓ Saved 06_correlation_over_time.png\n\n")

# ============================================================================
# CREATE SUMMARY DOCUMENT
# ============================================================================

cat("Creating visualization summary document...\n")

summary_text <- "# Final Visualizations Summary

**Created:** December 7, 2024  
**Purpose:** Publication-quality plots for final report and presentation

## Visualization Inventory

### 1. GDP vs Medals Relationship (HERO PLOT)
**File:** `01_gdp_medals_relationship.png`  
**Purpose:** Main finding - shows the core relationship between GDP and medals  
**Key Message:** Economic power predicts Olympic success (R² = 0.47)  
**Design Note:** Log scale on x-axis spreads data points across all GDP levels
**Use in Report:** Introduction/Results section, README hero image  

### 2. Efficiency Champions
**File:** `02_efficiency_champions.png`  
**Purpose:** Highlight countries that achieve most medals per GDP dollar  
**Key Message:** Hungary leads efficiency at 1.33 medals per billion GDP  
**Use in Report:** Efficiency analysis section  

### 3. The Efficiency Paradox
**File:** `03_efficiency_paradox.png`  
**Purpose:** Show inverse relationship between GDP size and efficiency  
**Key Message:** Smaller economies are MORE efficient per dollar  
**Use in Report:** Discussion section, challenges conventional wisdom  

### 4. Medal Trends Over Time
**File:** `04_medal_trends_over_time.png`  
**Purpose:** Show how top countries have performed across Olympics  
**Key Message:** USA dominates but China rising, competition intensifying  
**Use in Report:** Historical context section  

### 5. Over and Under Performers
**File:** `05_over_under_performers.png`  
**Purpose:** Identify countries that defy economic predictions  
**Key Message:** Some countries win more/fewer medals than GDP predicts  
**Use in Report:** Residual analysis section  

### 6. Correlation Over Time
**File:** `06_correlation_over_time.png`  
**Purpose:** Show how GDP-medal relationship has evolved  
**Key Message:** Correlation strengthening over time (except 1980 boycott)  
**Use in Report:** Temporal trends section  

## Design Choices

**Color Palette:**
- Primary Blue (#2E86AB): Main data points, USA
- Green (#06A77D): Positive/over-performers, Hungary
- Red (#C73E1D): Negative/under-performers, India
- Orange (#F18F01): Regression lines, accent, Kenya
- Purple (#A23B72): Secondary accent, Jamaica

**Typography:**
- Titles: Bold, 16pt
- Subtitles: Regular, 12pt, gray
- Body text: 10-11pt
- Captions: 9pt, gray

**Theme Consistency:**
- All plots use `theme_olympics()` for uniform appearance
- Minimal grid lines (no minor gridlines)
- Consistent margins and spacing
- Source citations on all plots

**Scale Decisions:**
- Plot 1 & 3: Log scale on x-axis (GDP) to spread data points
- Plot 2 & 5: Linear scales with categorical data
- Plot 4 & 6: Linear scales for time series

## Usage

**For README:**
- Use Plot 1 (Hero) or Plot 3 (Paradox) as main visual
- Include 1-2 sentence interpretation

**For Report:**
- Plot 1: Introduction - establishes main relationship
- Plot 2: Results - efficiency findings
- Plot 3: Discussion - nuances in the relationship
- Plot 5: Results - over/under performers
- Plot 6: Optional - temporal trends if discussing time

**For Presentation:**
- Start with Plot 1 (big picture)
- Move to Plot 3 (interesting paradox)
- Highlight Plot 2 (Hungary success story)
- End with Plot 5 (practical implications)

## Files Generated

All final visualizations saved to: `figures/final/`
- High resolution (300 DPI)
- PNG format for compatibility
- Sized for reports (11-12 inches wide)
"

writeLines(summary_text, "figures/final/VISUALIZATION_SUMMARY.md")

cat("\n=== FINAL VISUALIZATIONS COMPLETE ===\n")
cat("✓ Created 6 publication-quality visualizations\n")
cat("✓ Applied consistent theme and color palette\n")
cat("✓ Used log scale for Plot 1 to better display data\n")
cat("✓ All plots saved to figures/final/\n")
cat("✓ Created summary documentation\n\n")
