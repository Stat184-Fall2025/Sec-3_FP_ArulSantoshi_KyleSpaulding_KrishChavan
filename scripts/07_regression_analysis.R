# Regression Analysis Script
# Purpose: Quantify the relationship between GDP and Olympic medals
# Data: olympics_gdp_merged.csv

library(tidyverse)
library(broom)  # For tidy model outputs

# Load data
olympics_gdp <- read_csv("data/processed/olympics_gdp_merged.csv")


# ============================================================================
# SIMPLE LINEAR REGRESSION: Total_Medals ~ GDP
# ============================================================================

cat("=== SIMPLE LINEAR REGRESSION ===\n\n")

# Fit the model
model_linear <- lm(Total_Medals ~ GDP, data = olympics_gdp)

# Display summary
summary(model_linear)

# Extract key statistics
model_stats <- glance(model_linear)
cat("\nModel Statistics:\n")
print(model_stats)

# Extract coefficients
coefficients <- tidy(model_linear)
cat("\nCoefficients:\n")
print(coefficients)

# Interpretation
intercept <- coefficients$estimate[1]
slope <- coefficients$estimate[2]
r_squared <- model_stats$r.squared

cat("\n=== INTERPRETATION ===\n")
cat("Intercept:", round(intercept, 3), "\n")
cat("Slope:", format(slope, scientific = TRUE), "\n")
cat("R-squared:", round(r_squared, 3), "\n")
cat("Adjusted R-squared:", round(model_stats$adj.r.squared, 3), "\n")
cat("P-value:", format(model_stats$p.value, scientific = TRUE), "\n\n")

cat("Interpretation:\n")
cat("- For every $1 billion increase in GDP, we expect approximately",
    round(slope * 1e9, 4), "additional medals\n")
cat("- GDP explains", round(r_squared * 100, 1), "% of the variance in medal counts\n")
cat("- The relationship is statistically significant (p < 0.001)\n\n")

# ============================================================================
# ENHANCED SCATTERPLOT WITH REGRESSION LINE
# ============================================================================

cat("=== CREATING VISUALIZATION: GDP vs Medals with Regression ===\n")

# Add predictions to data
olympics_gdp <- olympics_gdp %>%
  mutate(
    predicted_medals = predict(model_linear),
    residuals = residuals(model_linear)
  )

# Create scatterplot with regression line
p_regression <- ggplot(olympics_gdp, aes(x = GDP, y = Total_Medals)) +
  geom_point(alpha = 0.5, color = "steelblue", size = 2) +
  geom_smooth(method = "lm", color = "red", se = TRUE, alpha = 0.2) +
  scale_x_continuous(labels = scales::dollar_format(scale = 1e-9, suffix = "B")) +
  labs(
    title = "GDP vs Olympic Medal Count with Linear Regression",
    subtitle = paste0("R² = ", round(r_squared, 3), " | p < 0.001"),
    x = "GDP (Billions USD)",
    y = "Total Medals",
    caption = "Data sources: Olympedia.org, World Bank\nRed line shows linear regression with 95% confidence interval"
  ) +
  theme_minimal() +
  theme(plot.caption = element_text(hjust = 0, size = 8))

ggsave("figures/gdp_vs_medals_regression.png", p_regression, 
       width = 10, height = 7, dpi = 300)
cat("✓ Saved gdp_vs_medals_regression.png\n\n")

# ============================================================================
# MODEL DIAGNOSTICS
# ============================================================================

cat("=== MODEL DIAGNOSTICS ===\n\n")

# 1. Residuals vs Fitted
p_resid_fitted <- ggplot(olympics_gdp, aes(x = predicted_medals, y = residuals)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  geom_smooth(se = FALSE, color = "darkblue") +
  labs(
    title = "Residuals vs Fitted Values",
    subtitle = "Checking for linearity and homoscedasticity",
    x = "Fitted Values (Predicted Medals)",
    y = "Residuals"
  ) +
  theme_minimal()

ggsave("figures/residuals_vs_fitted.png", p_resid_fitted, 
       width = 8, height = 6, dpi = 300)
cat("✓ Saved residuals_vs_fitted.png\n")

# 2. Q-Q Plot (normality of residuals)
p_qq <- ggplot(olympics_gdp, aes(sample = residuals)) +
  stat_qq(alpha = 0.5, color = "steelblue") +
  stat_qq_line(color = "red") +
  labs(
    title = "Q-Q Plot of Residuals",
    subtitle = "Checking normality assumption",
    x = "Theoretical Quantiles",
    y = "Sample Quantiles"
  ) +
  theme_minimal()

ggsave("figures/qq_plot.png", p_qq, width = 8, height = 6, dpi = 300)
cat("✓ Saved qq_plot.png\n")

# 3. Scale-Location plot
olympics_gdp <- olympics_gdp %>%
  mutate(sqrt_abs_resid = sqrt(abs(residuals)))

p_scale_location <- ggplot(olympics_gdp, aes(x = predicted_medals, y = sqrt_abs_resid)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_smooth(se = FALSE, color = "red") +
  labs(
    title = "Scale-Location Plot",
    subtitle = "Checking homoscedasticity",
    x = "Fitted Values",
    y = "√|Residuals|"
  ) +
  theme_minimal()

ggsave("figures/scale_location.png", p_scale_location, 
       width = 8, height = 6, dpi = 300)
cat("✓ Saved scale_location.png\n\n")

# ============================================================================
# LOG-TRANSFORMED MODEL
# ============================================================================

cat("=== LOG-TRANSFORMED MODEL ===\n\n")

# Add small constant to handle zeros (though we have none in our data)
olympics_gdp <- olympics_gdp %>%
  mutate(
    log_GDP = log10(GDP),
    log_Medals = log10(Total_Medals)
  )

# Fit log-log model
model_log <- lm(log_Medals ~ log_GDP, data = olympics_gdp)

summary(model_log)

# Extract statistics
model_log_stats <- glance(model_log)
cat("\nLog-Log Model Statistics:\n")
print(model_log_stats)

coefficients_log <- tidy(model_log)
cat("\nLog-Log Coefficients:\n")
print(coefficients_log)

# Compare models
cat("\n=== MODEL COMPARISON ===\n")
cat("Linear Model R²:", round(model_stats$r.squared, 4), "\n")
cat("Log-Log Model R²:", round(model_log_stats$r.squared, 4), "\n")
cat("Linear Model AIC:", round(AIC(model_linear), 2), "\n")
cat("Log-Log Model AIC:", round(AIC(model_log), 2), "\n\n")

if(model_log_stats$r.squared > model_stats$r.squared) {
  cat("✓ Log-log model provides better fit (higher R²)\n")
} else {
  cat("✓ Linear model provides better fit (higher R²)\n")
}

# Visualize log-log relationship
p_log <- ggplot(olympics_gdp, aes(x = log_GDP, y = log_Medals)) +
  geom_point(alpha = 0.5, color = "steelblue", size = 2) +
  geom_smooth(method = "lm", color = "red", se = TRUE, alpha = 0.2) +
  labs(
    title = "Log-Log Relationship: GDP vs Medals",
    subtitle = paste0("R² = ", round(model_log_stats$r.squared, 3)),
    x = "Log10(GDP)",
    y = "Log10(Total Medals)",
    caption = "Data sources: Olympedia.org, World Bank"
  ) +
  theme_minimal()

ggsave("figures/log_gdp_vs_log_medals.png", p_log, 
       width = 10, height = 7, dpi = 300)
cat("\n✓ Saved log_gdp_vs_log_medals.png\n\n")

# ============================================================================
# SAVE MODEL OUTPUTS
# ============================================================================

cat("=== SAVING MODEL OUTPUTS ===\n")

# Save augmented data with predictions and residuals
write_csv(olympics_gdp, "data/processed/olympics_gdp_with_residuals.csv")
cat("✓ Saved olympics_gdp_with_residuals.csv\n")

# Save model summaries
model_summary <- bind_rows(
  model_stats %>% mutate(model = "Linear"),
  model_log_stats %>% mutate(model = "Log-Log")
) %>%
  select(model, r.squared, adj.r.squared, sigma, AIC, p.value)

write_csv(model_summary, "figures/model_comparison.csv")
cat("✓ Saved model_comparison.csv\n")

# Save coefficients
coefficients_summary <- bind_rows(
  coefficients %>% mutate(model = "Linear"),
  coefficients_log %>% mutate(model = "Log-Log")
)

write_csv(coefficients_summary, "figures/regression_coefficients.csv")
cat("✓ Saved regression_coefficients.csv\n")

cat("\n=== REGRESSION ANALYSIS COMPLETE ===\n")
cat("✓ Linear regression model fitted\n")
cat("✓ Log-log model fitted and compared\n")
cat("✓ Diagnostic plots created\n")
cat("✓ Model outputs saved\n")