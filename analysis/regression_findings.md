# Regression Analysis Findings

**Date:** December 7, 2024  
**Analysis:** GDP-Medal Relationship Models

## Models Tested

### 1. Linear Model: Total_Medals ~ GDP

**Model Performance:**
- R² = 0.4725
- Adjusted R² = 0.4719
- p-value < 0.001 (highly significant)
- Residual standard error: 13.42

**Coefficients:**
- Intercept: 7.14 medals
- Slope: 7.67e-12 (0.0077 medals per billion USD GDP)

**Interpretation:**
- For every $1 billion increase in GDP, a country is expected to win approximately 0.0077 additional medals
- Equivalently, roughly $130 billion in GDP corresponds to 1 additional medal
- GDP explains 47.2% of the variance in Olympic medal counts
- The relationship is highly statistically significant (p < 2e-16)

### 2. Log-Log Model: log(Total_Medals) ~ log(GDP)

**Model Performance:**
- R² = 0.3561
- Adjusted R² = 0.3554
- p-value < 0.001 (highly significant)

**Coefficients:**
- Intercept: -3.34
- Slope: 0.369 (elasticity)

**Interpretation:**
- A 1% increase in GDP is associated with approximately 0.37% increase in medals
- Elasticity less than 1 suggests diminishing returns (but model fits worse overall)

## Model Comparison

| Metric | Linear Model | Log-Log Model | Winner |
|--------|--------------|---------------|---------|
| R² | 0.4725 | 0.3561 | Linear |
| Adjusted R² | 0.4719 | 0.3554 | Linear |
| Residual SE | 13.42 | 0.441 | - |

**Conclusion:** The linear model provides a better fit to the data based on R² values. This suggests the relationship between GDP and medals is relatively straightforward and linear, without strong evidence of diminishing returns at higher GDP levels.

## Key Insights

1. **Moderate Relationship Strength**
   - R² of 0.472 means GDP alone explains less than half the variance
   - 52.8% of variance remains unexplained
   - This suggests other factors beyond economic resources significantly impact Olympic success

2. **No Strong Diminishing Returns**
   - Linear model fits better than log-log
   - Larger economies continue to gain medals proportionally
   - Wealthier nations maintain advantage without plateauing

3. **Practical Significance**
   - Small countries with GDP < $100B unlikely to win many medals based on economics alone
   - Countries with GDP > $1 trillion have significant structural advantage
   - But substantial variance around the prediction line shows economics isn't destiny

4. **Unexplained Variance Creates Opportunities**
   - The 52.8% unexplained variance is where interesting stories live
   - Countries significantly above the line (positive residuals) are "efficient"
   - Countries significantly below the line (negative residuals) are "underperforming"

## Model Diagnostics

**Assumptions Checked:**
- Linearity: Residuals vs Fitted plot shows relatively random scatter
- Normality: Q-Q plot shows reasonable normality with some deviation in tails
- Homoscedasticity: Some evidence of increased variance at higher fitted values

**Potential Issues:**
- Slight heteroscedasticity (variance increases with predicted values)
- Some influential outliers (USA, China likely)
- Right-skewed distribution of both GDP and medals

**Implications:**
- Model is generally reliable for inference
- Predictions less reliable at extreme GDP values
- Residual analysis will identify interesting outliers


## Files Generated

- `figures/gdp_vs_medals_regression.png` - Main regression visualization
- `figures/residuals_vs_fitted.png` - Diagnostic plot
- `figures/qq_plot.png` - Normality check
- `figures/scale_location.png` - Homoscedasticity check
- `figures/log_gdp_vs_log_medals.png` - Log-log relationship
- `figures/model_comparison.csv` - Model statistics table
- `figures/regression_coefficients.csv` - Coefficient estimates
- `data/processed/olympics_gdp_with_residuals.csv` - Data with predictions