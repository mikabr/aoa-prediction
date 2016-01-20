eng <- read.csv("predictors/frequency/mlus/mlus_english.csv")
swe <- read.csv("predictors/frequency/mlus/mlus_swedish.csv")
ita <- read.csv("predictors/frequency/mlus/mlus_italian.csv")
nor <- read.csv("predictors/frequency/mlus/mlus_norwegian.csv")
rus <- read.csv("predictors/frequency/mlus/mlus_russian.csv")
spa <- read.csv("predictors/frequency/mlus/mlus_spanish.csv")
tur <- read.csv("predictors/frequency/mlus/mlus_turkish.csv")

mlus <- bind_rows(
  mutate(swe, language = "Swedish"),
  mutate(ita, language = "Italian"),
  mutate(nor, language = "Norwegian"),
#  mutate(rus, language = "Russian"),
  mutate(spa, language = "Spanish"),
  mutate(tur, language = "Turkish")
)

ggplot(mlus, aes(x = mlu)) +
  facet_wrap(~language) +
  geom_histogram()

ggplot(eng, aes(x = mlu)) +
  geom_histogram()

nrow(eng)
setdiff(eng$item, eng_words$uni_lemma)

View(eng_words)
pott
