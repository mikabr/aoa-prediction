lang_words <- filter(words, language == "English", form == "WG")
lang_items <- read_csv("predictors/frequency/data/english/english_cdi_items.txt",
                       col_names = c("item"))

setdiff(lang_words$definition, tolower(lang_items$item))
