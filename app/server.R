library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(langcog)
theme_set(theme_bw(base_size = 14))
font <- "Open Sans"

all_prop_data <- read_csv("all_prop_data.csv")
uni_lemmas <- sort(unique(all_prop_data$uni_lemma))
start_lemma <- "dog"

input <- list(uni_lemma = "cat")

shinyServer(function(input, output) {

  input_uni_lemma <- reactive({
    ifelse(is.null(input$uni_lemma), start_lemma, input$uni_lemma)
  })

  output$uni_lemma <- renderUI({
    selectInput("uni_lemma", label = h4("uni lemma"), choices = uni_lemmas,
                selected = start_lemma)
  })

  output$by_language <- renderPlot({
    ggplot(filter(all_prop_data, uni_lemma == input_uni_lemma()),
           aes(x = age, group = definition)) +
      facet_grid(measure ~ language) +
      geom_line(aes(y = prop, colour = language)) +
      geom_point(aes(y = prop, colour = language)) +
      geom_line(aes(y = fit_prop, colour = language), size = 1.5) +
      scale_colour_solarized(guide = FALSE) +
      scale_y_continuous(name = "Proportion of children\n", limits = c(0, 1)) +
      scale_x_continuous(name = "\nAge (months)", limits = c(8, 18),
                         breaks = seq(8, 18, 2)) +
      theme(text = element_text(family = font))
  })

})
