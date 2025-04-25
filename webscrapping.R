#' @title Access the DollyWood website and Scan Attributes
#' @description
#' This function works to retrieve the name of the rides in the park and extract various pieces of info about each ride.
#' @importFrom
#' @export


library(rvest)
library(stringr)
library(tidyverse)

dollywood <- rvest::read_html("https://www.dollywood.com/themepark/rides/")

# Retrieves ride names
ride_names <- dollywood |>
  html_elements("h3") |>
  html_text()
ride_names

#Cleans the ride names
ride_names <- unique(ride_names)
ride_names

links <- dollywood |>
  html_elements(".resultItem a.hfe-cta-link") |>
  html_attr("href")

links <- paste0("https://www.dollywood.com", links)

rvest::read_html(links[1])
rvest::read_html(links[2])

#location of rides
ride_location <- dollywood |>
  html_elements(".result-attributes div") |>
  html_text()
ride_location

# Removes any weird spaces
clean_locations <- str_squish(ride_location)
clean_locations

ride_names_clean <- str_squish(ride_names)
ride_locations_clean <- str_squish(ride_location)

#Gets rid of the timesaver pass and keeps only the location
valid_indices <- ride_locations_clean != "TimeSaver Pass"

# filtered ride locations
ride_names_filtered <- ride_names_clean[valid_indices]
ride_locations_filtered <- ride_locations_clean[valid_indices]

ride_locations_filtered

links_filtered <- links[valid_indices]

ride_descriptions <- sapply(links_filtered, function(link) {
  tryCatch({
    page <- read_html(link)
    desc <- page |>
      html_element(".activity-info p") |>
      html_text() |>
      str_squish()
    return(desc)
  }, error = function(e) {
    return(NA)
  })
})

sum(is.na(ride_descriptions))  # Should show how many links failed


rides_df <- tibble(
  name = ride_names_filtered,
  location = ride_locations_filtered,
  description = ride_descriptions
)
rides_df




