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

dolly_search <- function(col_name, input) {
  user_input <- grepl(input, rides_df[[col_name]])
  if (user_input == TRUE) {
    return (user_input)
  } else {
    stop("Could not find a match. Check for typos and try again!")
  }
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

ride_pic <- function(ride) {
  img_type <- tools::file_ext(ride$image)
  tmp <- httr::GET(url = rides_df$image)

  if (img_type == "jpeg") {
    image <- jpeg::readJPEG(tmp$content)
  } else {
    image <- png::readPNG(tmp$content)
  }
  graphics::plot.new()
  grid::grid.raster(image)
}
