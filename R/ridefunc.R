#'@title Search the Dollywood Data Frame
#'@description
#'Given the name of either a Dollywood ride or a criteria to filter by, the `dolly_search()` function will provide information about rides meeting the criteria. This data includes the name of the ride, its description, and its location in the park. If user input not found in data frame, will return an error message.
#'@param col_name The name of a column in the Dollywood data frame, the text you are searching for.
#'@param input The name of what the user is looking for in the specified column of the Dollywood data frame.
#'@importFrom jsonlite read_json?
#'@returns A list of 8 elements
#'*`name`: A scalar character vector
#'*`location`: A scalar character vector
#'*`name`: A scalar character vector
#'*`description`: A scalar character vector
#'*`height`: A scalar character vector, may be empty
#'*`type`: A scalar character vector, may be empty
#'*`safety`: A scalar character vector, may be empty
#'*`recommendations`: A scalar character vector, may be empty
#'@examples
#'
#'
#'@export

dolly_search <- function(data, col_name, input) {
  if(!(col_name %in% colnames(data))) {
    stop("Could not find a match. Chack for typos and try again!")
  }
  if (!any(grepl(input, data[[col_name]],
                 ignore.case = TRUE))) {
    stop("Could not find a match. Check for typos and try again!")
  }
  data[grepl(input, data[[col_name]],
             ignore.case = TRUE),]
}

#'@title Plot an image of a Dollywood ride
#'@description
#'Given the name of a Dollywood ride, will provide user an image of the ride. If ride not found in data frame, will return an error.
#'@param name The name of a ride present in the `name` column in the Dollywood data frame.
#'@importFrom tools file_ext
#'@importFrom httr GET
#'@importFrom png readPNG
#'@importFrom jpeg readJPEG
#'@importFrom graphics plot.new
#'@importFrom grid grid.raster
#'@returns A rastergrab grob.
#'@examples
#'
#'
#'@export
#'
ride_pic <- function(data, ride_names) {
  if (!(ride_names %in% data$name)) {
    stop("Could not find a match. Check for typos and try again!")
  }
  image_url <- data$image[data$name == ride_names]
  image_url_clean <- sub("\\?.*$", "", image_url)
  img_type <- tools::file_ext(image_url_clean)
  tmp <- httr::GET(image_url)

  if (img_type %in% c("jpeg", "jpg")) {
    img <- jpeg::readJPEG(tmp$content)
  } else if (img_type == "png") {
    img <- png::readPNG(tmp$content)
  } else {
    stop(paste("Unsupported image format:", img_type))
  }
  graphics::plot.new()
  grid::grid.raster(img)
  graphics::title(main = ride_names)
}

##New function to maybe to do both at the same time??
get_ride_info <- function(data, col_name, input) {
  result <- dolly_search(data, col_name, input)
  for (ride in result$name) {
    message(paste("Showing image for:", ride))
    ride_pic(data, ride)
  }
  return(result)
}
##usage: get_ride_info(rides_df, "name", "Barnstormer")



