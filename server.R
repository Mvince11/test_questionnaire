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
    page <- as.character(current_page())
    theme_questions <- filter(questions_list, Theme == page)
    
    fluidRow(
      column(12,
             h3(paste("Thème :", page)),
             lapply(seq_len(nrow(theme_questions)), function(i) {
               q <- theme_questions[i, ]
               numero     <- as.character(q$Numero)
               question   <- q$Questions
               style      <- ifelse(is.na(q$Style), "radio", q$Style)
               condition  <- if ("Condition" %in% names(q)) q$Condition else NA
               parent_col <- if ("Parent" %in% names(q)) q$Parent else NA
               reponses   <- unlist(strsplit(q$reponses, ";"))
               
               # --- attributs conditionnels ---
               condition_attr <- if (!is.na(parent_col) && nzchar(parent_col)) {
                 cond_safe <- ifelse(is.na(condition), "", gsub("'", "&#39;", condition))
                 paste0("question-block conditional",
                        "' data-parent-question='q", parent_col,
                        "' data-condition='", cond_safe,
                        "' style='display:none; margin:20px 0; padding:15px; margin-left:4%; margin-right:4%;'")
               } else {
                 "question-block' style='margin:20px 0; padding:15px; margin-left:4%; margin-right:4%;'"
               }
               
               # --- style commun pour les labels ---
               label_style <- "display:inline-block; margin:4px 15px 4px 0; border-color:rgba(239,119,87,1); color:#293574; font-weight:bold; opacity:0.9;"
               
               # --- bloc UI stylisé ---
               div(
                 id = paste0("q", numero),
                 `class` = condition_attr,
                 tags$p(HTML(sprintf("<strong style='font-size:1rem; color:#293574;'>%s</strong><span style='color:red;'>*</span>", question))),
                 switch(style,
                        "radio" = tagList(
                          lapply(seq_along(reponses), function(j) {
                            id <- paste0("q", numero, "_", j)
                            val <- reponses[j]
                            tags$div(
                              tags$input(type = "radio", id = id, name = paste0("q", numero), value = val, required = if (j == 1) NA else NULL),
                              tags$label(`for` = id, style = label_style, val)
                            )
                          })
                        ),
                        "checkbox" = tagList(
                          lapply(seq_along(reponses), function(j) {
                            id <- paste0("q", numero, "_", j)
                            val <- reponses[j]
                            tags$div(
                              tags$input(type = "checkbox", id = id, name = paste0("q", numero), value = val),
                              tags$label(`for` = id, style = label_style, val)
                            )
                          })
                        ),
                        "textarea" = tags$textarea(name = paste0("q", numero), rows = 4, cols = 50, required = NA,
                                                   style = "width:100%; margin-top:6px; color:#293574; font-weight:bold; opacity:0.9;"
                        ),
                        "select" = tags$select(name = paste0("q", numero), required = NA,
                                               style = "width:100%; margin-top:6px; border-color:rgba(239,119,87,1); border-radius:6px; height:35px; color:#293574; font-weight:bold; opacity:0.9;",
                                               lapply(reponses, function(r) {
                                                 tags$option(value = r, r)
                                               })
                        )
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