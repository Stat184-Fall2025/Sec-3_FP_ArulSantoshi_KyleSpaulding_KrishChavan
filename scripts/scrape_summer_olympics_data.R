library(tidyverse)

# All Summer Olympic years from 1900-2020
# Note: 1916, 1940, 1944 were cancelled due to World Wars
all_years <- c(1900, 1904, 1908, 1912, 1920, 1924, 1928, 1932, 1936, 
               1948, 1952, 1956, 1960, 1964, 1968, 1972, 1976, 1980, 
               1984, 1988, 1992, 1996, 2000, 2004, 2008, 2012, 2016, 
               2020)

# Create empty list to store data from each year
all_data <- list()

# Loop through each Olympic year
for(year in all_years) {
  # Print instructions for the user
  cat("\n\n========================================")
  cat("\n--- Copy the table for", year, "(WITHOUT the header row) ---")
  cat("\nSelect from the FIRST COUNTRY down to the last")
  cat("\nThen press Enter in the console...")
  cat("\n========================================\n")
  
  # Pause and wait for user to press Enter after copying data
  readline()
  
  # Read data from clipboard
  # header = FALSE: Don't treat first row as column names
  # sep = "\t": Data is separated by tabs
  # fill = TRUE: If rows have different numbers of columns, fill with NA
  # quote = "": Don't treat quotation marks specially
  raw_data <- read.table("clipboard", 
                         header = FALSE, 
                         sep = "\t",
                         stringsAsFactors = FALSE,
                         fill = TRUE,
                         quote = "")
  
  # Determine how many columns were read
  # This varies because country names can have different numbers of words
  n_cols <- ncol(raw_data)
  
  # Process the raw data
  temp_data <- raw_data %>%
    mutate(
      # The LAST 5 columns are always in fixed positions:
      # Column n is Total medals
      Total = .[[n_cols]],
      # Column n-1 is Bronze medals
      Bronze = .[[n_cols - 1]],
      # Column n-2 is Silver medals
      Silver = .[[n_cols - 2]],
      # Column n-3 is Gold medals
      Gold = .[[n_cols - 3]],
      # Column n-4 is the NOC code (3-letter country code)
      NOC = .[[n_cols - 4]],
      
      # Everything BEFORE the last 5 columns is the country name
      # Some countries have multi-word names like "United States" or "People's Republic of China"
      # apply() goes through each row
      # We take columns 1 through (n_cols - 5) and paste them together
      # The function removes empty strings and joins words with spaces
      Country = apply(.[, 1:(n_cols - 5), drop = FALSE], 1, 
                      function(x) paste(x[x != ""], collapse = " "))
    ) %>%
    # Keep only the columns we need in the final dataset
    select(Country, NOC, Gold, Silver, Bronze, Total) %>%
    # Add a Year column so we know which Olympics this data is from
    mutate(Year = year) %>%
    # Remove any rows where NOC is missing or blank
    # This catches any stray rows from the bottom of the table
    filter(!is.na(NOC), NOC != "", NOC != "NA")
  
  # Store this year's data in the list using the year as the name
  all_data[[as.character(year)]] <- temp_data
  
  # Print confirmation showing how many countries were captured
  cat("Successfully saved", year, "with", nrow(temp_data), "countries\n")
}

# Combine all years into one large dataframe
# bind_rows() stacks all the data frames on top of each other
olympics_full <- bind_rows(all_data)

# Print summary statistics
cat("\n\n=== FINAL COMBINED DATA ===\n")
cat("Total rows:", nrow(olympics_full), "\n")
cat("Years covered:", length(unique(olympics_full$Year)), "\n")

# Save the complete dataset to CSV file in user's default documents folder
write_csv(olympics_full, "olympics_medals_summer_unclean.csv")
cat("\n Saved as olympics_medals_summer_unclean.csv\n")
