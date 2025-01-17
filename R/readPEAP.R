#' Read Population Estimates And Projections from the World Bank
#' 
#' Read-in xlsx file from the World Bank's Population Estimates And Projections
#' 
#' @return magpie object 
#' @author Johannes Koch
#' 
readPEAP <- function() {
    file <- "Data_Extract_From_Population_estimates_and_projections.xlsx"
    x <- readxl::read_xlsx(file, sheet = 1, range = "B1:CQ260") %>% 
        tidyr::pivot_longer(cols = tidyselect::starts_with(c("1","2")), names_to = "year") %>% 
        dplyr::select("iso3c" = .data$`Country Code`, .data$year, .data$value) %>% 
        mutate(variable = "population",
               year = as.integer(str_extract(.data$year, "^....")),
               value = as.numeric(.data$value)) %>% 
        dplyr::relocate(.data$value, .after = tidyselect::last_col()) %>% 
        as.magpie(tidy = TRUE)    
    x
}
