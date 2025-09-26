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
    
    if (page == "intro") {
      # --- Page d'accueil / introduction ---
      tagList(
        # --- Bandeau orange ---
        div(
          class = "page-layout-custom",
          style = "
      background-color: #ef7757 !important;
      padding-top: 5%;
      margin-top: -2%;
      padding-bottom: 3%;
      font-family: 'Source Sans Pro', sans-serif;
    ",
          div(
            style = "color:white; margin-left:10%; font-size: 2.4em; margin-top: 1%; font-weight: bold;",
            "Diagnostic Flash"
          ),
          div(
            style = "color:white; margin-left:10%; font-size: 2.1em; font-weight: bold; margin-top:1%;",
            '"Transition et adaptation au changement climatique"'
          ),
          tags$br(),
          div(
            style = "color:white; margin-left:10%; font-size: 1.8em; font-weight: bold; margin-bottom: 0.5%; margin-top: 2%;",
            "Préparez l'entretien d'échanges avec votre référent Cerema en établissant un état des lieux"
          ),
          div(
            style = "color:white; margin-left:10%; font-size: 1.8em; font-weight: bold; margin-top: -9px;",
            "des forces et des besoins de votre territoire."
          ),
          actionButton(
            "next_intro", "Commencer",
            class = "btn btn-bounce",
            style = "
          margin-left: 10%;
          box-shadow: inset 1px 1px 3px #712929, inset -1px -1px 3px #ccc7c7;
          border-radius: 8px;
          font-weight: bold;
          font-size: 1.5em;
          margin-top: 40px;
          background-color: rgba(239,119,87,1);
          border: none;
        "
          )
        ),
        
        # --- Container avec colonnes ---
        div(
          class = "container",
          style = "display:flex; justify-content:space-between;width:auto; align-items:flex-start; margin:0 5%;margin-bottom:5%;",
          
          # Colonne gauche
          div(
            class = "left-column",
            style = "flex:1;margin-top:auto;",
            div(
              class = "info-block",
              tags$img(src = "main_pomme.png", alt = "Pomme", style = "width:120px; margin-right:15px;"),
              div(
                class = "info-text",
                tags$h3("Disposer d'un état des lieux"),
                tags$h4("Répondez à quelques questions et recevez votre rapport avec un premier niveau de recommandations du Cerema.")
              )
            ),
            div(
              class = "info-block",
              tags$img(src = "cible.png", alt = "Cible", style = "width:120px; margin-right:15px;"),
              div(
                class = "info-text",
                tags$h3("Déterminer vos priorités"),
                tags$h4("Sur la base de ce rapport, établissez vos priorités d'actions et définissez, avec votre référent Cerema, les solutions mobilisables.")
              )
            ),
            div(
              class = "info-block",
              tags$img(src = "ecran.png", alt = "Écran", style = "width:120px; margin-right:15px;"),
              div(
                class = "info-text",
                tags$h3("Faciliter le passage à l'action"),
                tags$h4("Bénéficiez, par thématique, d'une boîte à outils et de retours d'expériences inspirants.")
              )
            )
          ),
          
          # Colonne droite
          div(
            class = "right-column",
            style = "flex:1; text-align:center;",
            tags$img(src = "image_diag.png", alt = "Image droite", style = "max-width:100%; height:auto;")
          )
        ),tags$footer(
          style = "
                  position: fixed;
                  bottom: 0;
                  left: 0;
                  width: 100%;
                  padding: 10px 5%;
                  background: #f9f9f9;
                  border-top: 1px solid #ddd;
                  display: flex;
                  justify-content: space-between;
                  align-items: center;
                  font-size: 1.1rem;
                  color: #666;
                  z-index: 1000;
                ",
          div("Site créé avec ®RStudio"),
          div("© Cerema"),
          div(
            tags$a(href="https://fr.linkedin.com/company/cerema", target="_blank",
                   icon("linkedin", lib="font-awesome"), style="margin:0 8px; font-size:1.5rem; color:#0e76a8;"),
            tags$a(href="https://x.com/ceremacom", target="_blank",
                   icon("twitter", lib="font-awesome"), style="margin:0 8px; font-size:1.5rem; color:#000;"),
            tags$a(href="https://www.youtube.com/@cerema3139", target="_blank",
                   icon("youtube", lib="font-awesome"), style="margin:0 8px; font-size:1.5rem; color:#c4302b;")
          )
        )
        
      )
    } else {
      
        
      texte_theme <- NA_character_
      if ("TexteTheme" %in% names(theme_questions)) {
        tmp <- theme_questions$TexteTheme
        tmp <- tmp[!is.na(tmp)]
        if (length(tmp) > 0) {
          texte_theme <- as.character(tmp[1])
          texte_theme <- gsub("\n", "<br>", texte_theme)  # ✅ ici on écrase avec le texte formaté
        }
      }
      
    
    div(class = "mise_en_page",
        fluidRow(
          column(
            12,
            # --- Mention obligatoire ---
            div(
              style="color: red; font-size:1.2rem; margin-top: 15px; margin-bottom: 40px; margin-left: -58px;",
              "*Champs obligatoires",
              class="champs_obligatoires"
            ),
            
            # --- Thème et texte associé ---
            tagList(
              h3(
                paste(page),
                style = "color:#293574;margin-left:5%;font-weight: bold;"
              ),
              if (!is.null(texte_theme) && !is.na(texte_theme) && nzchar(texte_theme)) {
                tags$div(
                  HTML(
                  texte_theme
                ),style = "margin-left:5%; font-size:1.7rem; color:#293574; margin-bottom:44px; margin-top:40px;font-weight: bold;
                          font-family: Source Sans Pro;"
                )
              }
            ),
            
            # --- Génération dynamique des questions ---
            lapply(seq_len(nrow(theme_questions)), function(i) {
              q <- theme_questions[i, ]
              numero     <- as.character(q$Numero)
              question   <- q$Questions
              style      <- ifelse(is.na(q$Style), "radio", q$Style)
              condition  <- if ("Condition" %in% names(q)) q$Condition else NA
              parent_col <- if ("Parent" %in% names(q)) q$Parent else NA
              reponses <- q$reponses[[1]]
              
              # Question conditionnelle ?
              is_conditional <- !is.na(parent_col) && nzchar(parent_col)
              
              # --- Commentaire éventuel [ ... ] ---
              commentaire <- stringr::str_extract(question, "\\[.*?\\]")
              question_sans_commentaire <- stringr::str_replace(question, "\\[.*?\\]", "")
              if (!is.na(commentaire)) {
                commentaire <- stringr::str_replace_all(commentaire, "\\[|\\]", "")
                tooltip_html <- sprintf(
                  "<span class='tooltip'><span class='icon'>i</span><span class='tooltiptext'>%s</span></span>",
                  commentaire
                )
              } else {
                tooltip_html <- ""
              }
              
              div(
                id = paste0("q", numero),
                class = if (is_conditional) c("question-block", "conditional") else "question-block",
                `data-parent-question` = if (is_conditional) paste0("q", parent_col) else NULL,
                `data-condition` = if (is_conditional) condition else NULL,
                style = if (is_conditional) {
                  "display:none; margin:20px 0; padding:15px; margin-left:4%; margin-right:4%;"
                } else {
                  "margin:20px 0; padding:15px; margin-left:4%; margin-right:4%;"
                },
                
                tags$p(HTML(sprintf(
                  "<strong style='font-size:1.6rem; color:#293574;'>%s</strong> %s <span style='color:red;'>*</span>",
                  question_sans_commentaire, tooltip_html
                ))),
                
                switch(style,
                       "radio" = tagList(
                         lapply(seq_along(reponses), function(j) {
                           id <- paste0("q", numero, "_", j)
                           val <- trimws(gsub("&nbsp;", "", reponses[j]))
                           tags$div(
                             class = "custom-radio", style = "display:contents;",
                             tags$input(
                               type = "radio", id = id, name = paste0("q", numero),
                               value = val, required = if (j == 1) NA else NULL
                             ),
                             tags$label(`for` = id, val)
                           )
                         })
                       ),
                       "checkbox" = tagList(
                         lapply(seq_along(reponses), function(j) {
                           id <- paste0("q", numero, "_", j)
                           val <- trimws(gsub("&nbsp;", "", reponses[j]))
                           
                           tags$div(
                             class = "custom-checkbox",
                             style = if (is_conditional) {
                               "display:flex; align-items:center; margin:6px 0; color:#293574; font-weight:bold; opacity:0.9;"
                             } else {
                               "display:inline-block; margin:6px 12px 6px 0; color:#293574; font-weight:bold; opacity:0.9;"
                             },
                             tags$input(
                               type = "checkbox", id = id, name = paste0("q", numero), value = val,
                               style = "border-color:rgba(239,119,87,1);margin-right:8px; transform: scale(1.2); cursor:pointer;"
                             ),
                             tags$label(`for` = id, val,
                                        style = "font-size:1.6rem; font-weight:bold; margin-left:8px;")
                           )
                         })
                       ),
                       
                       "textarea" = tags$textarea(
                         name = paste0("q", numero), rows = 4, cols = 50, required = NA,
                         style = "width:100%; margin-top:6px; color:#293574; font-weight:bold; opacity:0.9;"
                       ),
                       "select" = tags$select(
                         name = paste0("q", numero), required = NA,
                         style = "width:100%; margin-top:6px; border:2px solid rgba(239,119,87,1); border-radius:6px; height:35px; color:#293574; font-weight:bold; opacity:0.9;
                         font-size: 1.9rem;font-family: Apple Chancery;padding-left:10px;",
                         lapply(reponses, function(r) {
                           val <- trimws(gsub("&nbsp;", "", r))
                           tags$option(value = val, val)
                         })
                       )
                )
              )
            })
          )
        )
    )
    
            }
    })
  
  output$footer_conditional <- renderUI({
    if (as.character(current_page()) != "intro") {
      tagList(
        tags$br(), tags$br(), tags$br(), tags$br(),
        uiOutput("footer")
      )
    } else {
      NULL  # rien affiché sur la page intro
    }
  })
  
  
  output$footer <- renderUI({
    p <- current_page()
    
    div(
      id = "footer",
      style = "position:fixed; bottom:0; left:0; width:100%;
             background:white; border-top:2px solid #EF7757; 
             padding:10px 20px; z-index:1000;",
      
      # ligne dots + bouton
      div(
        id = "footer-dots-container",
        style = "display:flex; align-items:center; justify-content:space-between;",
        
        # dots au centre
        div(
          style = "flex-grow:1; text-align:center;",
          includeHTML("www/custom_footer.html")
        ),
        
        # bouton à droite
        div(
          class = "right-btn",
          if (!is.null(p) && p == themes[length(themes)]) {
            actionButton(
              "next_submit", "Soumettre",
              style = "background-color:#ef7757;color:white;border:none;
                     padding:10px 20px;border-radius:6px;font-size:1rem;"
            )
          } else {
            actionButton(
              paste0("next_", p), "Suivant >",
              style = "background-color:#ef7757;color:white;border:none;
                     padding:10px 20px;border-radius:6px;font-size:1.6rem;"
            )
          }
        )
      ),
      
      # ligne texte en dessous
      # ligne texte + icônes en dessous
      div(
        style = "margin-top:15px;
           display:flex; 
           align-items:center; 
           justify-content:space-between;
           font-size:1.2rem; color:#666;",
        
        # gauche
        div("Site créé avec ®RStudio"),
        
        # centre
        div("©Cerema"),
        
        # droite
        div(
          class = "footer-social",
          
          tags$a(
            href = "https://fr.linkedin.com/company/cerema",
            target = "_blank",
            icon("linkedin", lib = "font-awesome"),
            style = "margin:0 10px; font-size:1.6rem; color:#0e76a8;"
          ),
          tags$a(
            href = "https://x.com/ceremacom",
            target = "_blank",
            icon("twitter", lib = "font-awesome"),
            style = "margin:0 10px; font-size:1.6rem; color:#000;"
          ),
          tags$a(
            href = "https://www.youtube.com/@cerema3139",
            target = "_blank",
            icon("youtube", lib = "font-awesome"),
            style = "margin:0 10px; font-size:1.6rem; color:#c4302b;"
          )
        )
      )
    )
  })
  
  observe({
    lapply(themes, function(th) {
      observeEvent(input[[paste0("next_", th)]], {
        current_index <- which(themes == th)
        if (current_index < length(themes)) {
          current_page(themes[current_index + 1])
        }
      })
    })
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