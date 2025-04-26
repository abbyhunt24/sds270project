#' @title Access the DollyWood website and Scanning Attributes
#' @description
#' This function works to retrieve the name of the rides in the park and extract various pieces of info about each ride including the name of each ride and its location in the park.
#' @importFrom
#' @export

#total number of rides on DollyWood website: 44

library(rvest)
library(stringr)
library(tidyverse)

dollywood <- rvest::read_html("https://www.dollywood.com/themepark/rides/")

# Retrieves ride names
ride_names <- dollywood |>
  html_elements("h3") |>
  html_text()
ride_names

#Cleans the ride names, deletes duplicates, do we need to filter out stuff at the bottom (book your trip, help, etc?), after doing these steps we still have 44
ride_names <- unique(ride_names)
ride_names <- ride_names[-c(45:50)] #gets rid of the last 5, which are functions on the websites and not attractions
ride_names

# works to extract the links, we have 65 links, not super sure why? can filter it later
links <- dollywood |>
  html_elements(".resultItem a.hfe-cta-link") |>
  html_attr("href")

links <- paste0("https://www.dollywood.com", links)

rvest::read_html(links[1])
rvest::read_html(links[2])

#location of rides, 85 results (includes timesaver which we don't need)
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

# filtered ride locations, no more timesaver
ride_names_filtered <- ride_names_clean[valid_indices] #this ends up getting rid of some of the rides, adding a bunch of NA values, not sure why so maybe we don't use it?
ride_locations_filtered <- ride_locations_clean[valid_indices] #this doesn't get rid of timesaver premium only, can do that further down

valid_indices2 <- ride_locations_filtered != "TimeSaver Premium Only"
ride_locations_filtered <- ride_locations_filtered[valid_indices2]

ride_locations_filtered
# this still prints out more locations than we have rides, this annoyed me so i went through and compared to try and figure out what the duplicates were:
#5-8: wildwood grove
#10: country fair
#17-18: wildwood grove
#23: wilderness pass
#25-26: wildnerness grove
#30-32: wildwood grove
#35: jukebox junction
#40: timber canyon
#48: craftsman valley
#50: country fair
#52: wildwood grove
#56: timber canyon
#58: wildwood grove
#62: wilderness pass
#wildwood grove is listed as a ride but it's an area of the park? im going to add one i guess
# im going to filter these out manually for now, not sure why it's doing this
ride_locations_filtered <- ride_locations_filtered[-c(5:8, 10, 17:18, 23, 25:26, 30:32, 35, 40, 48, 50, 52, 56, 58, 62)]
ride_locations_filtered <- c("Wildwood Grove", as.list(ride_locations_filtered))
ride_locations_filtered <- append(ride_locations_filtered[-1], ride_locations_filtered[1], 42)

links_filtered <- links[valid_indices] #doing this adds two more links and makes a bunch of them NA? i dont think that there are any time saver functions in the links but there are duplicates, so maybe we do the unique() function instead??

links_filtered <- unique(links) #something like this?? this also gets the NA count down

#ride pictures, can't get this to work LOL
ride_pictures <- dollywood |>
  html_elements(".result-image img") |>
  html_text()
ride_pictures

#only some of the images have these coordinates, need to figure out how to capture the info from the rest, make like an if else loop to catch it and have it run to look for the other ones?
ride_descriptions <- sapply(links_filtered, function(link) {
  tryCatch({
    page <- read_html(link)
    desc <- page |>
      html_nodes(".activity-info p") |>
      html_text()
      #html_element(".activity-info p") |>
      #html_text() |>
      #str_squish()
    return(desc)
  }, error = function(e) {
    return(NA)
  })
})

sum(is.na(ride_descriptions))  # Should show how many links failed


rides_df <- tibble(
  name = ride_names_clean, #i made this ride_names_clean just for now but there are still the issues about size incompatability
  location = ride_locations_filtered,
  description = ride_descriptions
)
rides_df




