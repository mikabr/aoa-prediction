library(readr)
library(wordbankr)

uni_lemmas <- get_item_data(mode = "local") %>%
  filter(type == "word", !is.na(uni_lemma), language == "English", form == "WG") %>%
  select(uni_lemma)

concreteness <- read_csv("predictors/concreteness/concreteness.csv")

missing_concreteness <- setdiff(uni_lemmas$uni_lemma, concreteness$Word)

# write_csv(data.frame(uni_lemma = missing_concreteness),
#           "predictors/concreteness/concreteness_replace.csv")

replacements_concreteness <- read_csv("predictors/concreteness/concreteness_replace.csv")
uni_concreteness <- uni_lemmas %>%
  left_join(replacements_concreteness) %>%
  rowwise() %>%
  mutate(Word = if (!is.na(replacement) & replacement != "") replacement else uni_lemma) %>%
  select(-replacement) %>%
  left_join(concreteness) %>%
  rename(concreteness = Conc.M) %>%
  select(uni_lemma, concreteness)


babiness <- read_csv("predictors/babiness_iconicity/english_iconicity.csv") %>%
  group_by(word) %>%
  summarise(iconicity = mean(rating),
            babiness = mean(babyAVG))

missing_babiness <- setdiff(uni_lemmas$uni_lemma, babiness$word)

# write_csv(data.frame(uni_lemma = missing_babiness),
#           "predictors/babiness_iconicity/babiness_iconicity_replace.csv")

replacements_babiness <- read_csv("predictors/babiness_iconicity/babiness_iconicity_replace.csv")

uni_babiness <- uni_lemmas %>%
  left_join(replacements_babiness) %>%
  rowwise() %>%
  mutate(word = if (!is.na(replacement) & replacement != "") replacement else uni_lemma) %>%
  select(-replacement) %>%
  left_join(babiness)


valence <- read_csv("predictors/valence/valence.csv") %>%
  select(Word, V.Mean.Sum, A.Mean.Sum, D.Mean.Sum) %>%
  rename(word = Word, valence = V.Mean.Sum, arousal = A.Mean.Sum,
         dominance = D.Mean.Sum)

missing_valence <- setdiff(uni_lemmas$uni_lemma, valence$word)

# write_csv(data.frame(uni_lemma = missing_babiness),
#           "predictors/valence/valence_replace.csv")

replacements_valence <- read_csv("predictors/valence/valence_replace.csv") %>%
  select(-lexical_class)

uni_valence <- uni_lemmas %>%
  left_join(replacements_valence) %>%
  rowwise() %>%
  mutate(word = if (!is.na(replacement) & replacement != "") replacement else uni_lemma) %>%
  select(-replacement) %>%
  left_join(valence)
