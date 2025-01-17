#' Read IMF
#' 
#' Read-in data that are based on IMF
#' 
#' 
#' @param subtype Either "current_account" or "covid"
#' @return magpie object of the data
#' @author Lavinia Baumstark
#' @importFrom readxl read_xlsx
#' @importFrom dplyr %>% rename filter select mutate across
#' @importFrom tidyr pivot_longer pivot_wider unite
#' @importFrom tidyselect starts_with
#' @seealso \code{\link{readSource}}
#' @examples
#' 
#' \dontrun{ a <- readSource(type="IMF")
#' }
#' 
readIMF <- function(subtype = "current_account"){
  # Check function input
  if (!subtype %in% c("current_account", "GDPpc") ) stop('Unkown subtype.')
  
  # Define source file
  source_file <- "WEOApr2021all.xls"
  
  # Define what data, i.e.which "WEO subject codes", to keep
  my_WEO_codes <- if (subtype == "GDPpc") c("NGDPRPPPPC") else "BCA"  
  
  weo_data <- readr::read_tsv(source_file, 
                              col_types = list(.default = readr::col_character())) %>% 
    filter(.data$`WEO Subject Code` %in% my_WEO_codes) %>% 
    unite("tmp", .data$Scale, .data$Units, sep = " ") %>% 
    mutate(tmp = sub("NA ", "", .data$tmp), 
           tmp = paste0("[",.data$tmp,"]")) %>% 
    unite("Subject Descriptor", .data$`Subject Descriptor`, .data$tmp, sep = " ") %>% 
    select("iso3c" = .data$ISO, .data$`Subject Descriptor`, starts_with(c("1","2"))) %>% 
    pivot_longer(starts_with(c("1","2")), names_to = "year") %>% 
    mutate(value = gsub(",", "", .data$value),
           across(.cols = c(.data$year, .data$value), as.double),
           value = tidyr::replace_na(.data$value, 0)) %>%
    pivot_wider(names_from = .data$`Subject Descriptor`)  
  
  # Transform to magpie
  out <- as.magpie(weo_data)
  
  # TMP! Give names
  if (subtype == "current_account") {
    getNames(out) <- "current account [billion U.S. dollar]"
  } 
  
  return(out)
}
