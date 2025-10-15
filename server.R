server <- function(input, output, session) {
  current_page <- reactiveVal("intro")
  completed_themes <- reactiveVal(character())  # stocke les noms des thèmes complétés
  answers <- reactiveValues()
  
  generateProgressBar <- function(all_themes, current_theme, completed_themes) {
    tags$div(
      id = "progress-bar",
      class = "progress-bar",
      lapply(seq_along(all_themes), function(i) {
        theme <- all_themes[i]
        label <- theme  # ou un vecteur parallèle si tu veux des noms plus lisibles
        
        state_class <- if (theme == current_theme) {
          "active"
        } else if (theme %in% completed_themes) {
          "completed"
        } else {
          "pending"
        }
        
        tags$div(
          class = paste("progress-item", state_class),
          `data-step` = theme,
          style = "display: flex; align-items: center; gap: 5px; margin-right: 15px;",
          tags$div(class = "circle", i),  # numéro du thème
          tags$span(class = "label", HTML(label))  # nom du thème
        )
      })
    )
  }
  
  ##### Page principale #####
  output$main_ui <- renderUI({
    page <- as.character(current_page())
    theme_questions <<- filter(questions_list, Theme == page)
    
    
    ##### Page d'accueil #####
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
            "next_btn", "Commencer",
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
        }
      }
      
      # Traitement du texte avec || comme séparateur
      texte_blocs <- if (!is.null(texte_theme) && is.character(texte_theme) && !is.na(texte_theme)) {
        unlist(strsplit(texte_theme, "\\|\\|")) |> trimws()
      } else {
        character(0)
      }
      
      
      # Le premier bloc est affiché comme paragraphe, les suivants comme liste
      texte_intro <- if (length(texte_blocs) > 0) {
        tags$p(HTML(gsub("\n", "<br>", texte_blocs[1])),
               style = "font-size:1.9rem;")
      }
      
      texte_liste <- if (length(texte_blocs) > 1) {
        tags$ul(
          lapply(texte_blocs[-1], function(item) {
            tags$li(item)
          }),
          style = "margin-left:20px; font-size:1.9rem;"
        )
      }
      
      ##### Pages questions #####
      tagList(
        tags$div(
          fluidRow(
            column(12,
          id = "progress-bar",
          class = "progress-bar",
          style = "margin-left: 10.2%; margin-right: 3.3%; padding: 0 2%; padding-bottom:14px;", # ou 0 si tu veux pleine largeur
          generateProgressBar(
            all_themes = themes,  # liste complète
            current_theme = current_page(),
            completed_themes = completed_themes()
          )
          
                  )
                  )
          ),
    div(class = "mise_en_page",
        fluidRow(id="mise_en_page",
          column(12,
            # --- Mention obligatoire ---
            div(
              style="color: red; font-size:1.2rem; margin-top: 15px; margin-bottom: 40px; margin-left: -2vw;",
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
                  
                  texte_intro,
                  texte_liste
                ,style = "margin-left:5%; font-size:1.7rem; color:#293574; margin-bottom:44px; margin-top:40px;font-weight: bold;
                          font-family: Source Sans Pro;"
                )
              }
            ),
            
            ###### Génération dynamique des questions #####
            lapply(seq_len(nrow(theme_questions)), function(i) {
              q <- theme_questions[i, ]
              numero     <- as.character(q$Numero)
              question   <- q$Questions
              style      <- ifelse(is.na(q$Style), "radio", q$Style)
              condition  <- if ("Condition" %in% names(q)) q$Condition else NA
              parent_col <- if ("Parent" %in% names(q)) q$Parent else NA
              remplace <- if ("Remplace" %in% names(q)) q$Remplace else NA
              is_replacement <<- !is.na(remplace) && nzchar(remplace)
              reponses <- q$reponses[[1]]
              has_parent <- !is.na(parent_col) && parent_col != "" && parent_col != "NA"
              is_replaced <- numero %in% theme_questions$Remplace
              is_conditional <- has_parent
              is_required <- tolower(q$Observation) == "obligatoire"
              is_required <- if (!is.na(is_required)) is_required else FALSE
              
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
                # Important : 'conditional' reste pour la SÉLECTION JS
                class = if (is_conditional) c("question-block", "conditional") else "question-block",
                `data-parent-question` = if (is_conditional) paste0("q", parent_col) else NULL,
                `data-condition` = if (is_conditional && !is.na(condition) && nzchar(condition)) condition else NULL,
                `data-replace` = if (is_replacement) paste0("q", remplace) else NULL,
                
                # MODIFICATION CLÉ : Le style initial est UNIFORME et SANS 'display:none'
                style = "margin:20px 0; padding:15px; margin-left:4%; margin-right:4%;",
              
                
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
                               type = "radio", id = id, name = paste0("q", numero),is_required = is_required,
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
                           
                           # Récupérer StyleDetail si présent
                           style_detail <- ifelse("Affichage" %in% names(q), q$Affichage, NA)
                           
                           tags$div(
                             class = "custom-checkbox",
                             style = if (!is.na(style_detail) && style_detail == "inline-block") {
                               # Cas particulier → inline-block
                               "display: inline-block; margin-right:15px; margin-top:10px; color: #293574; font-weight: bold; opacity: 0.95;"
                             } else {
                               # Cas général → flex
                               "display: flex; align-items: flex-start; gap: 12px; margin: 10px 0; color: #293574; font-weight: bold; opacity: 0.95;"
                             },
                             
                             tags$input(
                               type = "checkbox",
                               id = id,
                               is_required = is_required,
                               name = paste0("q", numero),
                               value = val,
                               style = "transform: scale(1.3); margin-top: 4px; cursor: pointer; border-color: rgba(239,119,87,1);"
                             ),
                             tags$label(
                               `for` = id,
                               val,
                               style = "font-size: 1.6rem; font-weight: bold; margin-left: 8px; line-height: 1.4; max-width: 90%; word-break: break-word;"
                             )
                           )
                         })
                       ),
                       "textarea" = tags$textarea(
                         name = paste0("q", numero),id = paste0("q", numero), rows = 4, cols = 50, required = NA,is_required = is_required,
                         style = "width:100%; margin-top:6px; color:#293574; font-weight:bold; opacity:0.9;border:2px solid rgba(239,119,87,1);"
                       ),
                       "textarea-alt" = tags$textarea(
                         name = paste0("q", numero),id = paste0("q", numero), rows = 4, cols = 50, required = NA,is_required = is_required,
                         style = "width:100%; margin-top:6px; color:#293574; font-weight:bold; opacity:0.9;border:2px solid rgba(239,119,87,1);
                                  height:35px;"
                       ),
                       "select" = tags$select(
                         name = paste0("q", numero), required = NA,
                         is_required = is_required,
                         style = "width:100%; margin-top:6px; border:2px solid rgba(239,119,87,1); border-radius:6px; height:35px; color:#293574; font-weight:bold; opacity:0.9;
                         font-size: 1.9rem;font-family: Apple Chancery;padding-left:10px;",
                         lapply(reponses, function(r) {
                           val <- trimws(gsub("&nbsp;", "", r))
                           tags$option(value = val, val)
                                                      }
                                )
                                            )
                          )
                      )
                  })
                )
              )
        )
      )
            }
    })
  
  ##### Footer commun #####
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
  
  ##### Footer pages questions #####
  output$footer <- renderUI({
    p <- current_page()
    pos <- match(p, themes)
    
    tagList(
    div(
      id = "footer",
      style = "position:fixed; bottom:0; left:0; width:100%;
             background:white; border-top:2px solid #EF7757; 
             padding:10px 20px; z-index:1000;",
      
      # ligne dots + bouton
      div(
        id = "footer-dots-container",
        style = "display:flex; align-items:center; justify-content:space-between;",
        
        # bouton précédent à gauche (si applicable)
        if (!is.null(pos) && pos > 1) {
          div(
            class = "left-btn",
            actionButton(
              "prev_btn", "< Précédent",
              style = "background-color:#ef7757;color:white;border:none;
                     padding:10px 20px;border-radius:6px;font-size:1.6rem;"
            )
          )
        },
        
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
              "submit", "Soumettre",
              style = "background-color:#ef7757;color:white;border:none;
                     padding:10px 20px;border-radius:6px;font-size:1;6rem;"
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
    ),tags$script(
      HTML(
        sprintf("window.currentProgressStep = %d;", which(themes == current_page()))
          )
                )
    )
  })
  
  validate_choix <- function(questions_list) {
    questions_list %>%
      rowwise() %>%
      mutate(
        Reponses = list(input[[paste0("q", Numero)]]),
        nb_reponses = if (is.null(Reponses)) 0 else length(Reponses),
        limite = case_when(
          Choix == "Mono" ~ 1,
          Choix == "Multichoix 2 MAX" ~ 2,
          Choix == "Multichoix 3 MAX" ~ 3,
          Choix == "Multichoix" ~ Inf,
          TRUE ~ Inf
        ),
        trop_de_reponses = nb_reponses > limite
      ) %>%
      ungroup() %>%
      filter(trop_de_reponses)
  }
  
  
  ##### Vérification questions obligatoire #####
  validate_theme <- function(th) {
    questions_theme <- questions_list %>% filter(Theme == th)%>%
      mutate(Observation = trimws(tolower(gsub("\u00A0", " ", Observation))))
    
    obligatoires <- questions_theme %>% filter(Observation == "obligatoire")
    
    non_remplies <- obligatoires %>%
      mutate(Reponse = sapply(Numero, function(id) {
        val <- input[[paste0("q", id)]]
        if (is.null(val) || val == "" || val %in% c("Sélectionner…", "Sélectionner...")) return(NA)
        return(val)
      })) %>%
      filter(is.na(Reponse))
    
    
    trop_de_reponses <- validate_choix(questions_theme)
    
    if (nrow(trop_de_reponses) > 0) {
      showModal(modalDialog(
        title = div(icon("exclamation-triangle", style="color:rgba(239,119,87,1)"), span("Trop de réponses", style = "color:#D32F2F; font-weight:bold; font-size:1.4rem;")),
        div(
          style = "font-size:1.5rem; color:#293574; margin-top:50px;",
          HTML(paste0(
            "Vous avez sélectionné trop de réponses pour les questions suivantes :<br><ul>",
            paste0("<li><strong>", trop_de_reponses$Questions, "</strong> (max ", trop_de_reponses$limite, ")</li>", collapse = ""),
            "</ul>"
          ))
        ),
        easyClose = TRUE,
        footer = modalButton("Corriger")
      ))
      return(FALSE)
    }
    
    if (nrow(non_remplies) > 0) {
      showModal(modalDialog(
        title = div(icon("exclamation-triangle"), span("Champs obligatoires manquants", style = "color:#D32F2F; font-weight:bold; font-size:1.4rem;")),
        div(
          style = "font-size:1.5rem; color:#293574; margin-top:50px;",
          HTML(paste0(
            "⚠️ Vous devez remplir les champs suivants avant de continuer :<br><ul>",
            paste0("<li><strong>", non_remplies$Questions, "</strong></li>", collapse = ""),
            "</ul>"
          ))
        ),
        easyClose = TRUE,
        footer = modalButton("Corriger")
      ))
      return(FALSE)
    }
    
    return(TRUE)
  }
  
  
  ##### Partie ObserveEvent ####
  observe({
    lapply(themes, function(th) {
      observeEvent(input[[paste0("next_", th)]], {
         #current_index <- which(themes == th)
        
        # ✅ Vérifier les champs obligatoires du thème courant
        if (!validate_theme(th)) return()
        
        current_index <- which(themes == th)
        
        # 🔵 Marquer le thème comme complété
        old <- completed_themes()
        if (!(th %in% old)) {
          completed_themes(c(old, th))
        }
        
        # 🔶 Passer au thème suivant si possible
        if (current_index < length(themes)) {
          current_page(themes[current_index + 1])
        }
      })
    })
  })
  
  
  
  
  observeEvent(input$prev_btn, {
    pos <- match(current_page(), themes)
    if (!is.null(pos) && pos > 1) {
      prev_theme <- themes[pos - 1]
      current_page(prev_theme)
      
      # 🔄 Optionnel : retirer le thème actuel de completed
      current_theme <- themes[pos]
      completed_themes(setdiff(completed_themes(), current_theme))
    }
  })
  
  
  # 🔄 Navigation
  observeEvent(input$next_btn, current_page(themes[1]))
  for (i in seq_along(themes[-length(themes)])) {
    observeEvent(input[[paste0("next_", themes[i])]], current_page(themes[i + 1]))
  }
  # observeEvent(input$next_submit, current_page("submit"))
  # observeEvent(input$back_submit, current_page(themes[length(themes)]))
  
###### Permet d'enregister les réponses evec answer reactivevalue ##### 
  observe({
    lapply(questions_list$Numero, function(id) {
      inputId <- paste0("q", id)
      observeEvent(input[[inputId]], {
        answers[[inputId]] <- input[[inputId]]
      }, ignoreInit = TRUE)
    })
  })
  
##### Enregistre toutes les Questions et réponses dans un fichier xlsx ######  
  observeEvent(input$submit, {
    th <- "Formulaire de contact"  # ou le nom réel du dernier thème
    if (!validate_theme(th)) return()
    
    completed_themes(c(completed_themes(), th))
    
    reponses_df <- questions_list %>%
      mutate(Reponse = sapply(Numero, function(id) {
        val <- input[[paste0("q", id)]]
        if (is.null(val)) return("")
        if (is.atomic(val)) return(paste(val, collapse = ", "))
        return(as.character(val))
      })) %>%
      select(Numero, Questions, Reponse)%>%
      filter(!(Reponse %in% c("", "Sélectionner…", "Sélectionner...")))
    
    
    genre <- reponses_df$Reponse[reponses_df$Questions == "Civilité"]
    nom <- reponses_df$Reponse[reponses_df$Questions == "Nom"]
    prenom <- reponses_df$Reponse[reponses_df$Questions == "Prénom"]
    raison_sociale <- reponses_df$Reponse[reponses_df$Questions == "Raison sociale de la collectivité (nom exact)"]
    adresse_mail <- reponses_df$Reponse[reponses_df$Questions == "Email"]
    
    genre          <- if (length(genre) == 0) NA else genre
    nom            <- if (length(nom) == 0) NA else nom
    prenom         <- if (length(prenom) == 0) NA else prenom
    raison_sociale <- if (length(raison_sociale) == 0) NA else raison_sociale
    adresse_mail   <- if (length(adresse_mail) == 0) NA else adresse_mail
    
    Identite <- data.frame(
      "Civilité"        = genre,
      Nom             = nom,
      "Prénom"          = prenom,
      `Raison sociale` = raison_sociale,
      `Adresse mail`   = adresse_mail,
      stringsAsFactors = FALSE
    )
    
    horodatage <- format(Sys.time(), "%Y-%m-%d-%H-%M")
    
    writexl::write_xlsx(
      list(
        Identite = Identite,
        Reponses = reponses_df
      ),
      path = paste0("Reponses/reponses_", nom, "_", prenom, "_", horodatage, ".xlsx")
    )
    
    showModal(modalDialog(
      title = div(
        icon("check-circle"), 
        span("Réponses enregistrées", style = "color:#2E7D32; font-weight:bold; font-size:1.4rem;")
      ),
      div(
        style = "font-size:1.2rem; color:#293574; margin-top:10px;",
        HTML(paste0( "Merci <strong>", genre, " ", nom, " ", prenom, "</strong>, vos réponses ont bien été enregistrées.<br><br>",
                     "Nous allons passer à la fiche de synthèse." ))
      ),
      easyClose = TRUE,
      footer = tagList(
        modalButton("Fermer"),
        actionButton("continuer", "Continuer", class = "btn-success")
      )
    ))
  })
}