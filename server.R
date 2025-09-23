server <- function(input, output, session) {
  current_page <- reactiveVal("intro")
  
  
  # 🔄 Navigation
  observeEvent(input$next_intro, current_page(themes[1]))
  for (i in seq_along(themes[-length(themes)])) {
    observeEvent(input[[paste0("next_", themes[i])]], current_page(themes[i + 1]))
  }
  observeEvent(input$next_submit, current_page("submit"))
  observeEvent(input$back_submit, current_page(themes[length(themes)]))
  
  # 🧱 Affichage dynamique
  output$main_ui <- renderUI({
    page <- current_page()
    
    if (page == "intro") {
      fluidRow(
        column(12,
               h2("Bienvenue dans le questionnaire"),
               p("Ce questionnaire comporte plusieurs thèmes."),
               actionButton("next_intro", "Commencer")
        )
      )
    } else if (page %in% themes) {
      theme_questions <- filter(questions_list, Theme == page)
      fluidRow(
        column(12,
               h3(paste("Thème :", page)),
               lapply(seq_len(nrow(theme_questions)), function(j) {
                 q <- theme_questions[j, ]
                 numero <- q$Numero
                 style <- ifelse(is.na(q$Style), "radio", q$Style)
                 reponses <- unlist(strsplit(q$reponses, ";"))
                 tagList(
                   tags$h4(q$Questions),
                   switch(style,
                          "radio" = radioButtons(paste0("q", numero), NULL, choices = reponses),
                          "checkbox" = checkboxGroupInput(paste0("q", numero), NULL, choices = reponses),
                          "textarea" = textAreaInput(paste0("q", numero), NULL, width = "100%", resize = "none"),
                          "textarea-alt" = textAreaInput(paste0("q", numero), NULL, width = "100%", resize = "none", rows = 6),
                          "select" = selectInput(paste0("q", numero), NULL, choices = reponses)
                   )
                 )
               }),
               if (page == themes[length(themes)]) {
                 actionButton("next_submit", "Soumettre")
               } else {
                 actionButton(paste0("next_", page), "Page suivante")
               }
        )
      )
    } else if (page == "submit") {
      fluidRow(
        column(12,
               h2("Soumission"),
               p("Merci d’avoir complété le questionnaire."),
               actionButton("back_submit", "Retour"),
               actionButton("submit_btn", "Envoyer")
        )
      )
    }
  })
  
  # 📤 Traitement des réponses
  observeEvent(input$submit_btn, {
    responses <- lapply(questions_list$Numero, function(numero) {
      input[[paste0("q", numero)]]
    })
    print(responses)
    showModal(modalDialog("Réponses enregistrées. Merci !"))
  })
}