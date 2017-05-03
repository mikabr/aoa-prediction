library(tidyverse)
library(directlabels)
library(wordbankr)
library(langcog)
theme_set(theme_mikabr())

aoa <- feather::read_feather("app/aoas.feather")

aoa_summary <- aoa %>%
  group_by(uni_lemma) %>%
  summarise(n_lang = n(), mean_aoa = mean(aoa))

data_mode <- "local"

#demo_lemmas <- c("uh oh", "tiger", "tomorrow")
demo_lemmas <- c("dog", "play", "night")

languages <- c("Croatian", "Danish", "English", "French (Quebec)", "Italian",
               "Norwegian", "Russian", "Spanish", "Swedish", "Turkish")

admins <- get_administration_data(mode = data_mode) %>%
  select(language, form, sex, age, data_id) %>%
  filter(language %in% languages)

get_inst_data <- function(lang, frm, items) {
  get_instrument_data(instrument_language = lang,
                      instrument_form = frm,
                      administrations = admins,
                      iteminfo = items,
                      items = filter(items, form == frm)$item_id,
                      mode = data_mode) %>%
    filter(!is.na(age)) %>%
    mutate(produces = !is.na(value) & value == "produces",
           understands = !is.na(value) &
             (value == "understands" | value == "produces")) %>%
    select(-value) %>%
    gather(measure, value, produces, understands)
}

get_lang_data <- function(lang) {
  print(lang)

  items <- get_item_data(language = lang, mode = data_mode) %>%
    filter(uni_lemma %in% demo_lemmas)

  get_inst_data(lang, "WG", items)

  # if ("WS" %in% items$form & "WG" %in% items$form) {
  #   bind_rows(get_inst_data(lang, "WS", items), get_inst_data(lang, "WG", items))
  # }

}

crossling <- map_df(languages, get_lang_data)

crossling_summary <- crossling %>%
  filter(measure == "understands", age >= 8, age <= 18) %>%
  group_by(language, age, uni_lemma, definition) %>%
  summarise(n = n(), true = sum(value), prop = true / n) %>%
  ungroup() %>%
  mutate(definition = strsplit(definition, " \\(") %>% map_chr(~.x[[1]]),
         uni_lemma = parse_factor(uni_lemma, demo_lemmas))

ggplot(crossling_summary %>% filter(language != "Swedish"),
       aes(x = age, y = prop, colour = uni_lemma)) +
  facet_wrap(~language, ncol = 3) +
  #geom_point(size = 0.5) +
  geom_smooth(method = "loess", se = FALSE, span = 1) +
  geom_dl(aes(label = definition),
          method = list(dl.trans(x = x + 0.1, y = y - 0.1), "last.qp", cex = 0.9,
                        fontfamily = "Open Sans")) +
  scale_colour_solarized(guide = FALSE) +
  scale_x_continuous(limits = c(8, 22), breaks = seq(8, 18, 2)) +
  labs(x = "Age (months)", y = "Proportion of children understanding")
ggsave("crossling_demo.png", width = 7, height = 6)

ggplot(crossling_summary %>% filter(language == "English"),
       aes(x = age, y = prop, colour = uni_lemma)) +
  facet_wrap(~language, nrow = 2) +
  #geom_point(size = 0.5) +
  geom_smooth(method = "loess", se = FALSE, span = 1) +
  geom_dl(aes(label = definition),
          method = list(dl.trans(x = x + 0.1, y = y - 0.1), "last.qp", cex = 0.9,
                        fontfamily = "Open Sans")) +
  scale_colour_solarized(guide = FALSE) +
  scale_x_continuous(limits = c(8, 19), breaks = seq(8, 18, 2)) +
  labs(x = "Age (months)", y = "Proportion of children understanding")
ggsave("eng_demo.png", width = 5, height = 4)
