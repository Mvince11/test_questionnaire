library(shiny)
library(readxl)
library(dplyr)
library(stringr)
library(shinyjs)
library(gtools)
library(rsconnect)
library(purrr)
library(writexl)

questions_list <- read_excel("data/questions_combinees.xlsx") %>%
  rename_with(~ gsub("é", "e", .x)) %>%      
  rename_with(trimws) %>%                   
  mutate(
    Theme      = as.character(Theme),
    Numero     = as.character(Numero),
    Questions  = as.character(Questions),
    Style      = as.character(Style),
    Reponses   = as.character(Reponses),
    Parent     = as.character(Parent),
    Condition  = as.character(Condition),
    TexteTheme = as.character(TexteTheme),
    Affichage  = as.character(Affichage),
    Remplace  = as.character(Remplace)
  ) %>%
  filter(!is.na(Questions), !is.na(Theme), !is.na(Numero)) %>%
  
  # on regroupe mais on garde les réponses "plates"
  group_by(Theme, Numero, Parent, Questions, Style, Condition, TexteTheme, Affichage, Remplace) %>%
  summarise(Reponses = paste(Reponses, collapse = ";"), .groups = "drop") %>%
  
  # on transforme en vecteurs propres
  mutate(
    reponses = strsplit(Reponses, ";"),
    reponses = lapply(reponses, trimws),   # nettoyer espaces
    Numero_num    = as.numeric(str_extract(Numero, "^\\d+")),
    Numero_suffix = str_extract(Numero, "[a-zA-Z]+$")
  ) %>%
  filter(!is.na(Numero_num)) %>%
  mutate(
    Numero_order = paste0(sprintf("%03d", Numero_num), Numero_suffix)
  ) %>%
  arrange(Numero_order)

themes <- questions_list %>%
  pull(Theme) %>%
  unique()



ui <- fluidPage(
   tags$head( useShinyjs(),
              includeCSS("www/styles.css"),
              tags$script(src = "normalize.js"),
              tags$script(src = "getAnswer.js"),
              tags$script(src = "updateConditionals.js"),
              tags$script(src = "initConditionals.js")
   ),

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
  ), tags$br(), tags$br(),tags$br(),tags$br(),uiOutput("footer_conditional")
)