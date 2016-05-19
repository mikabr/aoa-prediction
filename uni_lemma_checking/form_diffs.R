library(wordbankr)
library(dplyr)
library(tidyr)
library(purrr)

languages <- c("Croatian", "Danish", "English", "French (Quebec)", "Italian",
               "Norwegian", "Russian", "Spanish", "Swedish", "Turkish")

words <- get_item_data(mode = "local") %>%
  filter(type == "word", language %in% languages)

# duplicate/ambiguous definitions within WG
words %>%
  group_by(language, form, definition) %>%
  filter(n() > 1) %>%
  group_by(language, definition) %>%
  filter("WG" %in% form)

# words %>%
#   filter(form == "WS", !is.na(uni_lemma)) %>%
#   select(definition, uni_lemma)

# WG missing uni_lemma
words %>%
  filter(form == "WG") %>%
  filter(is.na(uni_lemma))

# inconsistent uni_lemmas between forms
words %>%
  select(language, form, definition, uni_lemma) %>%
  filter(!is.na(uni_lemma)) %>%
  distinct() %>%
  group_by(language, definition) %>%
  filter(length(unique(uni_lemma)) > 1, length(unique(form)) > 1)

# definition maps to multiple uni_lemmas
words %>%
  select(language, definition, uni_lemma) %>%
  filter(!is.na(uni_lemma)) %>%
  distinct() %>%
  group_by(language, definition) %>%
  filter(n() > 1)

# definition maps to multiple uni_lemmas within lexical_class
words %>%
  select(language, lexical_class, definition, uni_lemma) %>%
  filter(!is.na(uni_lemma)) %>%
  distinct() %>%
  group_by(language, definition) %>%
  filter(length(unique(uni_lemma)) > 1,
         length(unique(lexical_class)) == 1)

# uni_lemmas that have items from multiple different non-"other" lexical classes
# mapped to them
words %>%
  filter(lexical_class != "other", !is.na(uni_lemma)) %>%
  group_by(uni_lemma) %>%
  filter(length(unique(lexical_class)) > 1) %>%
  select(language, form, lexical_class, category, uni_lemma, definition) %>%
  arrange(language, uni_lemma) %>%
  View()
  #readr::write_csv("unilemma_discrepancies.csv")

# uni_lemmas that have category modifiers inconsistently
moded_uni <- words$uni_lemma %>%
  unique() %>%
  keep(~grepl(".* \\(.*\\)", .x)) %>%
  sort() %>%
  keep()
words %>%
  select(language, form, definition, uni_lemma) %>%
  filter(uni_lemma %in% c(moded_uni %>% map_chr(~gsub(" \\(.*\\)", "", .x)),
                          moded_uni))

# map definitions to uni_lemmas across forms
uni_lemma_map <- words %>%
  select(language, uni_lemma, definition) %>%
  distinct() %>%
  filter(!is.na(uni_lemma))
words_filled <- words %>%
  select(-uni_lemma) %>%
  left_join(uni_lemma_map)

# determine which WG items don't have a corresponding WS item
missing_ws <- words_filled %>%
  select(language, form, uni_lemma, definition) %>%
  group_by(language, uni_lemma) %>%
  filter("WG" %in% form & !("WS" %in% form))
missing_ws %>% group_by(language) %>% summarise(n = n()) %>% arrange(n)
