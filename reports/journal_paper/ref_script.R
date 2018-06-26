cites <- read_file("aoapred.Rmd") %>% str_extract_all("@[a-z0-9]+") %>%
  .[[1]] %>% str_sub(2, str_length(.))

bibs <- read_file("aoapred.bib") %>% str_match_all("@.*\\{(.*),") %>%
  .[[1]] %>% .[,2]

unused <- setdiff(bibs, cites) %>% sort()
missing <- setdiff(cites, bibs) %>% sort()
