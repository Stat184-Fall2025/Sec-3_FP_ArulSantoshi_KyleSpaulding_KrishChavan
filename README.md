# Olympic Medals and Economic Development Analysis

An exploration of the relationship between national economic strength (GDP) and Summer Olympic medal performance across countries over time.

## Overview

This project investigates how a country's economic resources correlate with their success at the Summer Olympics. By combining historical Olympic medal data with historical GDP statistics, we aim to understand whether wealthier nations win more medals, and how this relationship has evolved over different Olympic years. The analysis includes visualizations of medal distributions, GDP comparisons, and statistical modeling to determine the strength of the relationship between a country's wealth and its Summer Olympics Performance

### Interesting Insight (Optional)

This is optional but highly recommended. You'll include one interesting insight from your project as part of the README. This insight is most effective when you include a visual. Keep in mind that this visual must be included as an image file (e.g., JPG, PNG, etc.). You can export plots created with `{ggplot2}` by using the function `ggsave`.

## Data Sources and Acknowledgements

**Olympic Medal Data**
- Source: Olympedia.org (https://www.olympedia.org/statistics/medal/country)
- Collection Date: November 23, 2024
- Coverage: Summer Olympics 1960-2020

**GDP Data**
- Source: World Bank Open Data
- Indicator: NY.GDP.MKTP.CD (GDP, current US$)
- URL: https://data.worldbank.org/indicator/NY.GDP.MKTP.CD
- Download Date: November 23, 2024
- File: `API_NY.GDP.MKTP.CD_DS2_en_csv_v2_269001.csv`
- Coverage: 1960-2023 (filtered to Olympic years)

## Current Plan

The analysis will proceed through several phases:

1. **Data Wrangling**: Import and tidy both Summer Olympic Medal data over time and GDP by country data over time
2. **Data Preparation**: Merge Olympic medal counts with GDP data by country and year
3. **Exploratory Analysis**: Examine distributions, trends over time, and outliers
4. **Statistical Modeling**: Quantify the relationship between GDP and medal counts using regression analysis
5. **Comparative Analysis**: Explore medals per capita and medals per GDP dollar to identify high-performing nations
6. **Visualization**: Create graphics showing the relationship between economic power and Olympic performance

## Repo Structure

Use this section to explain the structure of your repo. This should help visitors quickly figure out where they should look to find certain elements. Further, you can use this space to highlight and briefly explain important/key files in the repo.


## Authors
Arul Santoshi, Penn State Student  
   - Email: ajs10266@psu.edu  
   - Github: Arul-Santoshi
Kyle Spaulding, Penn State Student  
   - Email: kbs6178@psu.edu  
   - Github: spauldingk
Krish Chavan, Penn State Student  
   - Email: ksc5629@psu.edu  
   - Github: KrishPSU  
Feel free to contact us with any questions either via email or GitHub