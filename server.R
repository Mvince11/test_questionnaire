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
             h3(paste(page), style = "color:#293574;"),
             lapply(seq_len(nrow(theme_questions)), function(i) {
               q <- theme_questions[i, ]
               numero     <- as.character(q$Numero)
               question   <- q$Questions
               style      <- ifelse(is.na(q$Style), "radio", q$Style)
               condition  <- if ("Condition" %in% names(q)) q$Condition else NA
               parent_col <- if ("Parent" %in% names(q)) q$Parent else NA
               reponses   <- unlist(strsplit(q$Reponses, ";"))
               
               # --- attributs HTML séparés ---
               is_conditional <- !is.na(parent_col) && nzchar(parent_col)
               
               # Nettoyage de la condition
               cond_clean <- if (!is.na(condition)) {
                 trimws(gsub("&nbsp;", "", condition))
               } else {
                 ""
               }
               
               div(
                 id = paste0("q", numero),
                 class = if (is_conditional) c("question-block", "conditional") else "question-block",
                 `data-parent-question` = if (is_conditional) paste0("q", parent_col) else NULL,
                 `data-condition` = if (is_conditional) cond_clean else NULL,
                 style = if (is_conditional) {
                   "display:none; margin:20px 0; padding:15px; margin-left:4%; margin-right:4%;"
                 } else {
                   "margin:20px 0; padding:15px; margin-left:4%; margin-right:4%;"
                 },
                 tags$p(HTML(sprintf("<strong style='font-size:1.6rem; color:#293574;'>%s</strong><span style='color:red;'>*</span>", question))),
                 switch(style,
                        "radio" = tagList(
                          lapply(seq_along(reponses), function(j) {
                            id <- paste0("q", numero, "_", j)
                            val <- trimws(gsub("&nbsp;", "", reponses[j]))
                            tags$div(class = "custom-radio", style = "display:inline-block;",
                                     tags$input(type = "radio", id = id, name = paste0("q", numero), value = val, required = if (j == 1) NA else NULL),
                                     tags$label(`for` = id, val)
                            )
                          })
                        ),
                        "checkbox" = tagList(
                          lapply(seq_along(reponses), function(j) {
                            id <- paste0("q", numero, "_", j)
                            val <- trimws(gsub("&nbsp;", "", reponses[j]))
                            tags$div(style = "display:inline-block; margin:4px 15px 4px 0; color:#293574; font-weight:bold; opacity:0.9;",
                                     tags$input(type = "checkbox", id = id, name = paste0("q", numero), value = val),
                                     tags$label(`for` = id, val)
                            )
                          })
                        ),
                        "textarea" = tags$textarea(name = paste0("q", numero), rows = 4, cols = 50, required = NA,
                                                   style = "width:100%; margin-top:6px; color:#293574; font-weight:bold; opacity:0.9;"
                        ),
                        "select" = tags$select(name = paste0("q", numero), required = NA,
                                               style = "width:100%; margin-top:6px; border-color:rgba(239,119,87,1); border-radius:6px; height:35px; color:#293574; font-weight:bold; opacity:0.9;",
                                               lapply(reponses, function(r) {
                                                 val <- trimws(gsub("&nbsp;", "", r))
                                                 tags$option(value = val, val)
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