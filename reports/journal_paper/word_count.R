library(tidyverse)

word_count <- function(filename) {
  st <- read_file(filename) %>%
    str_replace_all("\\\n", " ") %>%
    str_replace_all("---.*---", "") %>%
    str_replace_all("```\\{r.*?```", "") %>%
    str_replace_all("`r .*?`", "") %>%
    str_replace_all("\\$.*?\\$", "") %>%
    str_replace_all("@[a-zA-Z0-9]*", "") %>%
    str_replace_all("\\\\ \\\\", " \\\\") %>%
    str_replace_all("\\\\.*? ", "") %>%
    str_replace_all("\\^\\[.*?\\]", "") %>%
    str_replace_all("#+", "") %>%
    str_replace_all("Acknowledgements.*", "") %>%
    str_replace_all("[^A-Za-z ]", "") %>%
    str_replace_all("[ \t]{2,}", " ") %>%
    str_replace_all("^[ \t]", "")

  write_file(st, "aoapred_words.txt")
  st %>%
    str_split(" ") %>%
    .[[1]] %>%
    length()
}
