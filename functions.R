readData <- function(path) {
  x <- list.files(path = path)
  csvFiles <- x[tools::file_ext(x) == "csv"]
  zipFiles <- x[tools::file_ext(x) == "zip"]
  tempfolder <- tempdir()
  data <- readFiles(file.path(path, csvFiles))
  for (file in zipFiles) {
    file <- file.path(path, file)
    fname = unzip(file, list = TRUE)$Name
    fname <- fname[tools::file_ext(fname) == "csv"]
    unzip(file, files = fname, exdir = tempfolder, overwrite = TRUE)
    files <- file.path(tempfolder, fname)
    data <- c(data, readFiles(files))
  }
  return(data)
}

readFiles <- function(files) {
  data <- list()
  for (file in files) {
    data[[file]] <- readr::read_csv(file, col_types = readr::cols(.default = readr::col_character()))
  }
  names(data) <- basename(tools::file_path_sans_ext(names(data)))
  return(data)
}

mergeData <- function(data, patterns) {
  x <- list()
  for (pat in patterns) {
    x[[pat]] <- data[grepl(pat, names(data))] %>% dplyr::bind_rows() %>% distinct()
  }
  return(x)
}
