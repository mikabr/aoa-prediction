#load libraries for data manipulation and graphing
library(dplyr)
library(tidyr)
library(readr)
library(purrr)

uni_lemmas <- get_item_data(mode = "remote") %>%
  filter(type == "word", !is.na(uni_lemma), language == "English") %>%
  distinct(lexical_class, uni_lemma) %>%
  select(lexical_class, uni_lemma)

ratings <- read_csv('predictors/data/iconicity/english_iconicity.csv') %>%
  filter(task == "written") %>%
  group_by(word) %>%
  summarise(iconicity = mean(rating),
            babiness = mean(babyAVG))

rated_lemmas <- ratings %>%
  right_join(uni_lemmas, by = c("word" = "uni_lemma"))

missing_lemmas <- filter(rated_lemmas, is.na(iconicity)) %>%
  select(word, lexical_class) 

fixed_lemmas <- read_csv('predictors/data/fixed_iconicity.csv') %>%
  select(-lexical_class)

updated_ratings <- ratings %>% 
  left_join(fixed_lemmas, by = c("word" = "lynn_word")) %>%
  rowwise() %>%
  mutate(uni_lemma = ifelse(is.na(uni_lemma), word, uni_lemma)) %>%
  right_join(uni_lemmas) %>%
  select(-word)

write_csv(updated_ratings, 'predictors/iconicity_and_babiness.csv')

