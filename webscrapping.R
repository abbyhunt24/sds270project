#' @title Access the DollyWood website and Scanning Attributes
#' @description
#' This function works to retrieve the name of the rides in the park and extract various pieces of info about each ride including the name of each ride and its location in the park.
#' @importFrom
#' @returns A list of NUMBER elements
#' * Ride name:
#' *
#' @export

###LOADING PACKAGES
#total number of rides on DollyWood website: 44
library(rvest)
library(stringr)
library(tidyverse)



###LOADING IN WEBPAGE
dollywood <- rvest::read_html("https://www.dollywood.com/themepark/rides/")


###RIDE NAMES
ride_names <- dollywood |>
  html_elements("h3") |>
  html_text()
ride_names

#Cleaing ride names
ride_names <- unique(ride_names)
ride_names <- ride_names[-c(45:50)]
ride_names



###LINKS
links <- dollywood |>
  html_elements(".resultItem a.hfe-cta-link") |>
  html_attr("href")

links <- links[grepl("/themepark/rides/", links)]
links <- unique(links)
links <- paste0("https://www.dollywood.com", links)
length(links)


rvest::read_html(links[1])
rvest::read_html(links[2])


###RIDE LOCATIONS

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
ride_names_filtered <- ride_names_clean[valid_indices]
ride_locations_filtered <- ride_locations_clean[valid_indices]

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




###RIDE PICTURES
images <- dollywood |>
  html_elements(".resultItem img") |>
  html_attr("src")

images <- unique(images)
images <- images [1:44]
head(images)



###RIDE DESCRIPTIONS
ride_descriptions <- sapply(links, function(link) {
  tryCatch({
    page <- read_html(link)
    desc <- page |>
      html_nodes("p:nth-child(3) , .sectionDetails h2:nth-child(1), .hfe-grid-fullwidth h2, .hfe-grid-fullwidth .sectionDetails p, h1") |>
      html_text()
    return(desc)
  }, error = function(e) {
    return(NA)
  })
})

sum(is.na(ride_descriptions))  # Should show how many links failed - 0!

###RIDE HEIGHT REQUIREMENTS (some of them don't have requirements or pick up wrong info, can manually clean the three with wrong info)
ride_height <- sapply(links, function(link) {
  tryCatch({
    page <- read_html(link)
    height <- page |>
      html_nodes(".activityMetaContainer p") |>
      html_text()
    return(height)
  }, error = function(e) {
    return(NA)
  })
})

###RIDE TYPES (again not all of them have, i can filter out "types: ")
ride_types <- sapply(links, function(link) {
  tryCatch({
    page <- read_html(link)
    type <- page |>
      html_nodes(".col-md-12.activityMetaContainer .mr-3") |>
      html_text()
    return(type)
  }, error = function(e) {
    return(NA)
  })
})

###RIDE SAFETY
ride_safety <- sapply(links, function(link) {
  tryCatch({
    page <- read_html(link)
    safety <- page |>
      html_nodes(".mt-5 p") |>
      html_text()
    return(safety)
  }, error = function(e) {
    return(NA)
  })
})

###OTHER RECOMMENDED RIDES, still need to figure out the regex and how to do it in a quoted phrase
rec_rides <- sapply(links, function(link) {
  tryCatch({
    page <- read_html(link)
    recs <- page |>
      html_nodes("#rAct_4^\\d+$ h4") |>
      html_text()
    return(recs)
  }, error = function(e) {
    return(NA)
  })
})

###CREATING RIDE INFO DATAFRAME
rides_df <- tibble(
  name = ride_names,
  location = ride_locations_filtered,
  description = ride_descriptions,
  image = images,
  height = ride_height,
  type = ride_types,
  safety = ride_safety,
)
rides_df

###REPLACES "CHARACTER(O)" VALUES WITH NULL
rides_df[rides_df == "character(0)"] <- NA

#want to filter out the "" blanks
remove_blanks <- rides_df[!str_detect(rides_df$description,  ""), ]


