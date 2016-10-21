library(shiny)
library(shinythemes)
library(dplyr)
library(purrr)
library(tidyr)
library(ggplot2)
library(langcog)
theme_set(theme_mikabr())

ui <- shinyUI(
  fluidPage(
    theme = shinytheme("spacelab"),

    titlePanel("Cross-Linguistic AoA Comparison"),

    sidebarLayout(
      sidebarPanel(
        width = 2,
        uiOutput("language1"),
        uiOutput("language2")
      ),

      mainPanel(
        width = 10,
        align = "center",
          column(width = 6, plotOutput("all")),
          column(width = 6, plotOutput("lexcat")),
        br(), textOutput("r")
      )
    )
  )
)

server <- shinyServer(function(input, output) {

  aoas <- feather::read_feather("aoas.feather")

  languages <- unique(aoas$language)

  output$language1 <- renderUI({
    selectInput("language1", choices = languages, label = "Language 1",
                selected = "English")
  })

  output$language2 <- renderUI({
    selectInput("language2", choices = languages, label = "Language 2",
                selected = "Russian")
  })

  pair_aoas <- map_df(languages, function(l1) {
    map_df(setdiff(languages, l1), function(l2) {
      aoas %>%
        filter(language == l1 | language == l2) %>%
        spread(language, aoa) %>%
        mutate(language1 = l1, language2 = l2) %>%
        rename_(.dots = list("aoa1" = as.name(l1), "aoa2" = as.name(l2)))
    })
  })

  pair <- reactive({
    req(input$language1)
    req(input$language2)
    pair_aoas %>%
      filter(language1 == input$language1,
             language2 == input$language2)
  })

  output$all <- renderPlot({
    ggplot(pair(), aes(x = aoa1, y = aoa2, colour = lexical_class)) +
      coord_equal() +
      geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey") +
      geom_smooth(method = "lm", colour = "black") +
      geom_text(aes(label = uni_lemma)) +
      scale_x_continuous(limits = c(0, 40), name = "Language 1 AoA") +
      scale_y_continuous(limits = c(0, 40), name = "Language 2 AoA") +
      scale_colour_solarized(guide = FALSE)
  })

  output$lexcat <- renderPlot({
    ggplot(pair(), aes(x = aoa1, y = aoa2, colour = lexical_class)) +
      facet_wrap(~lexical_class, drop = TRUE) +
      coord_equal() +
      geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey") +
      geom_smooth(method = "lm", colour = "black") +
      #geom_text(aes(label = uni_lemma)) +
      geom_point(size = 0.7) +
      scale_x_continuous(limits = c(0, 40), name = "Language 1 AoA") +
      scale_y_continuous(limits = c(0, 40), name = "Language 2 AoA") +
      scale_colour_solarized(guide = FALSE)
  })

  output$r <- renderText({
    sprintf("correlation: %.2f",
            cor(pair()$aoa1, pair()$aoa2, use = "na.or.complete"))
  })

})

shinyApp(ui = ui, server = server)
