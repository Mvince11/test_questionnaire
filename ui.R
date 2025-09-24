library(shiny)
library(readxl)
library(dplyr)


questions_list <- read_excel("data/questions_combinees.xlsx") %>%
  rename_with(~ gsub("é", "e", .x)) %>%
  rename_with(trimws) %>%
  mutate(
    Theme     = as.character(Theme),
    Numero    = as.character(Numero),
    Questions = as.character(Questions),
    Style     = as.character(Style),
    reponses  = as.character(Reponses)
  ) %>%
  filter(!is.na(Questions), !is.na(Theme))

themes <- unique(questions_list$Theme)

ui <- fluidPage(tags$script(type = "text/javascript", src="script.js"),
  #tags$head(tags$script(src="script.js")),
  includeCSS("www/styles.css"),
  
  navbarPage(
    id = "tabs",
    fluid = TRUE,
    title = div(
      div(
        tags$a(href = "https://www.service-public.fr/", target = '_blank',
               tags$img(id = "img1", title = "Etat", src = "Republique-francaise.png", height = 80,
                        style = "top:20px;margin-left: 15px;  margin-right:5px;")),
        tags$a(href = "https://pqn-a.fr/fr", target = '_blank',
               tags$img(id = "img1", title = "PQNA", src = "logo_pqna.png", height = 80,
                        style = "top:20px; margin-left: 0;  margin-right:23px;")),
        tags$a(href = "https://www.nouvelle-aquitaine.fr/", target = '_blank',
               tags$img(id = "img1", title = "Région Nouvelle Aquitaine", src = "region-nouvelle-aquitaine_logo.jpg", height = 80,
                        style = "top:20px; margin-left: -15px;"))
      ),
      class = "conteneur_logo"
    ),
    windowTitle = "Questionnaire d'aide à la décision",
    collapsible = TRUE,
    header = tags$head(tags$link(rel = "shortcut icon", href = "favicon.ico")),
    mainPanel(width = 12, class="mise_en_page", uiOutput("main_ui"))
  ),uiOutput("footer")
)