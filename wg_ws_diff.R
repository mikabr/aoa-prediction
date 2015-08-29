library(wordbankr)
library(purrr)
library(dplyr)

words <- get_item_data(mode = "local") %>%
  filter(form %in% c("WG", "WS"),
         type == "word")

word_sets <- words %>%
  split(.$language) %>%
  keep(function(language_words) length(unique(language_words$form)) == 2) %>%
  map(function(language_words) {
    by_form <- language_words %>% split(.$form)
    setdiff(by_form$WG$definition, by_form$WS$definition)
  })
