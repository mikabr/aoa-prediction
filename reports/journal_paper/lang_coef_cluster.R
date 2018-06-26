library(tidyverse)

lang_coefs <- feather::read_feather("../../saved_data_old/lang_coefs.feather")

pair_cors <- function(dataset_coefs) {
  by_lang <- dataset_coefs %>% split(.$language)
  map_df(cross2(by_lang, by_lang),
         ~data_frame(language1 = unique(.x[[1]][["language"]]),
                     language2 = unique(.x[[2]][["language"]]),
                     cor = cor(.x[[1]][["estimate"]], .x[[2]][["estimate"]])))
}

coef_cors <- function(coefs) {
  coefs %>%
    group_by(interaction, measure) %>%
    nest() %>%
    mutate(cors = map(data, pair_cors)) %>%
    select(-data) %>%
    unnest()
}

empirical_cors <- lang_coefs %>%
  coef_cors() #%>%
  #filter(language1 != language2)
  # group_by(measure, interaction) %>%
  # arrange(desc(cor)) %>%
  # mutate(language1 = fct_inorder(language1),
  #        language2 = fct_inorder(language2))

ggplot(empirical_cors, aes(x = language1, y = language2, fill = cor)) +
  facet_grid(measure ~ interaction) +
  geom_tile() +
  geom_text(aes(label = round(cor, 2)))

cor_clust <- function(meas) {
  empirical_cors %>%
    filter(interaction == "main effect", measure == meas) %>%
    select(language1, language2, cor) %>%
    spread(language2, cor) %>%
    as.data.frame() %>%
    `rownames<-`(.$language1) %>%
    select(-language1) %>%
    dist() %>%
    hclust()
}

ggdendro::ggdendrogram(cor_clust("understands"))
ggdendro::ggdendrogram(cor_clust("produces"))
