# Exploratory Data Analysis Findings

**Date:** December 7, 2024  
**Dataset:** olympics_gdp_merged.csv (902 observations, 130 countries, 1960-2020)

## Summary Statistics

- **Mean medals per country-year:** 11.0 (median: 4)
- **Medal range:** 1-174 medals
- **Mean GDP:** $498.8 billion (median: $73.4 billion)

## Key Findings

### 1. Overall GDP-Medal Correlation: 0.687
Moderately strong positive correlation indicates GDP is an important but not sole predictor of Olympic success.

### 2. Correlation Varies Over Time

**Strongest correlations:**
- 1984: 0.955
- 1976: 0.953
- 1968: 0.946

**Weakest correlation:**
- 1980: 0.198 (likely due to US-led Moscow Olympics boycott)

**Recent trend:** Correlation strengthening (2012: 0.859 → 2020: 0.872)

### 3. Top Performers (1960-2020)

| Rank | Country | Total Medals | Avg per Olympics |
|------|---------|--------------|------------------|
| 1 | USA | 1,577 | 105.1 |
| 2 | China | 636 | 63.6 |
| 3 | Germany | 508 | 50.8 |
| 4 | Great Britain | 504 | 31.5 |
| 5 | Australia | 458 | 28.6 |

### 4. Notable Over-Performers (High medals, below-median GDP)

**Cuba** - Appears 5 times (1992, 1996, 2000, 2004, 2008)
- Consistent over-performance despite economic challenges
- 25-31 medals per appearance with GDP well below median

**Hungary** - Appears 5 times across multiple decades
- Strong sports program relative to economic size
- 22-35 medals in over-performing years

**Bulgaria** - 1980 (41 medals), 1988 (35 medals)
- Peak performance during Soviet era

### 5. Notable Under-Performers (Low medals, above-median GDP)

**India** - 4 appearances (2000, 2004, 2008, 2016)
- Large economy but minimal Olympic success
- 1-3 medals despite GDP > $700 billion

**Mexico, Indonesia, Saudi Arabia** - Multiple appearances
- Significant economic resources but limited medal counts

### 6. Participation Growth

- Countries participating: 34 (1960) → 89 (2020) = 162% increase
- Total medals awarded: 284 (1960) → 991 (2020) = 249% increase

## Implications for Analysis

1. The 1980 boycott year should be noted as an outlier in any time-series analysis
2. Cuba and Hungary are prime candidates for case studies on efficiency
3. India presents an interesting case of under-performance relative to economic size
4. Recent strengthening of GDP-medal correlation suggests economic resources becoming more important
