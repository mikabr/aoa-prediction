library(shiny)
library(shinythemes)

shinyUI(
  fluidPage(
    theme = shinytheme("spacelab"),
    uiOutput("uni_lemma"),
    plotOutput("by_language")

  ))

