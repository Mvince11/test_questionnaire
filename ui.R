library(shiny)
library(readxl)
library(dplyr)
library(stringr)
library(shinyjs)
library(gtools)

questions_list <- read_excel("data/questions_combinees.xlsx") %>%
  rename_with(~ gsub("é", "e", .x)) %>%
  rename_with(trimws) %>%
  mutate(
    Theme     = as.character(Theme),
    Numero    = as.character(Numero),
    Questions = as.character(Questions),
    Style     = as.character(Style),
    reponses  = as.character(Reponses),
    
    # Séparer la partie numérique et la partie suffixe
    Numero_num = as.numeric(str_extract(Numero, "^\\d+")),
    Numero_suffix = str_extract(Numero, "[a-zA-Z]+$")
  ) %>%
  filter(!is.na(Questions), !is.na(Theme)) %>%
  arrange(Numero_num, Numero_suffix)

themes <- questions_list %>%
  pull(Theme) %>%
  unique()


ui <- fluidPage(tags$script(type = "text/javascript", src="script.js"),
                useShinyjs(),
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
    mainPanel(width = 12,id = "main_content", uiOutput("main_ui"))
  ), tags$br(), tags$br(),tags$br(),tags$br(),uiOutput("footer_conditional")#,uiOutput("footer")
)