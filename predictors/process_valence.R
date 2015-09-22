# clear all previous variables
rm(list=ls())

#load libraries for data manipulation and graphing
library(dplyr)
library(tidyr)
library(readr)
library(purrr)

uni_lemmas <- get_item_data(mode = "remote") %>%
  filter(type == "word", !is.na(uni_lemma)) %>%
  distinct(lexical_class, uni_lemma) %>%
  select(lexical_class, uni_lemma)

ratings <- read_csv('predictors/data/BRM-emot-submit.csv')

rated_lemmas <- left_join(uni_lemmas, ratings, by = c("uni_lemma" = "Word")) %>%
  select(uni_lemma, V.Mean.Sum, A.Mean.Sum, D.Mean.Sum) %>%
  filter(!is.na(V.Mean.Sum))

missing_lemmas <- filter(uni_lemmas, !uni_lemma %in% rated_lemmas$uni_lemma)
write_csv(missing_lemmas,'missing_lemmas.csv')

fixed_lemmas <- read_csv('predictors/data/fixed_lemmas.csv')

updated_lemmas <- left_join(uni_lemmas,fixed_lemmas) %>%
  rowwise() %>%
  mutate(new_lemma = ifelse(is.na(replace), uni_lemma, replace)) %>%
  left_join(ratings,by = c("new_lemma" = "Word")) %>%
  select(lexical_class,new_lemma, uni_lemma,V.Mean.Sum, A.Mean.Sum, D.Mean.Sum) %>%
  rename(valence = V.Mean.Sum,
         arousal = A.Mean.Sum,
         dominance = D.Mean.Sum) %>%
  arrange(uni_lemma,lexical_class)

still_missing_lemmas <- updated_lemmas %>%
  filter(is.na(valence)) %>%
  select(uni_lemma)

write_csv(select(updated_lemmas, -new_lemma), 'predictors/uni_lemma_valence.csv')

