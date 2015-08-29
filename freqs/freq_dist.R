library(readr)
library(ggplot2)
library(dplyr)
library(langcog)

languages <- c("Danish", "German", "Italian", "Norwegian",
               "Russian", "Spanish", "Swedish", "Turkish")

freqs <- map(languages, function(language) {
  read_csv(sprintf("freqs_%s.csv", tolower(language))) %>%
    arrange(desc(frequency)) %>%
    mutate(rank = 1:nrow(.),
           language = language)
}) %>%
  bind_rows

ggplot(freqs, aes(x = rank, y = frequency, colour = language)) +
  facet_wrap(~ language, scales = "free_x") +
  geom_point() +
  scale_y_log10(name = "log probability") +
  scale_colour_solarized(guide = FALSE) +
  theme_bw()
