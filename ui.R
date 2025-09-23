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

ui <- fluidPage(
  tags$head(tags$script(HTML("
  setTimeout(function () {
    console.log('✅ Script JS lancé après délai');

    const normalize = s => String(s || '').trim().toLowerCase().replace(/\\u00a0/g, ' ');

    function parseExpected(cond) {
      if (!cond) return [];
      return cond.split(',').map(s => normalize(s)).filter(Boolean);
    }

    function getSelectedValues(parentName) {
      const selected = [];
      const parentEls = document.querySelectorAll(`[name='${parentName}']`);
      parentEls.forEach(el => {
        if ((el.type === 'radio' || el.type === 'checkbox') && el.checked) {
          selected.push(normalize(el.value));
        } else if (el.tagName === 'SELECT' && el.value) {
          selected.push(normalize(el.value));
        } else if ((el.tagName === 'TEXTAREA' || el.type === 'text') && el.value) {
          selected.push(normalize(el.value));
        }
      });
      return selected;
    }

    function updateBlock(block) {
      const expectedValues = parseExpected(block.dataset.condition);
      const parentNames = block.dataset.parentQuestion?.split(';').map(normalize) || [];

      let show = false;
      parentNames.forEach(parent => {
        const selected = getSelectedValues(parent);
        if (expectedValues.some(val => selected.includes(val))) {
          show = true;
        }
      });

      block.style.display = show ? 'block' : 'none';
      block.classList.toggle('visible', show);
    }

    function updateBlocksForParent(parentName) {
      document.querySelectorAll('.conditional').forEach(block => {
        const parentNames = block.dataset.parentQuestion?.split(';').map(normalize) || [];
        const parentField = document.querySelector(`[name='${parentName}']`);
        if (parentField && block.contains(parentField)) return;
        if (parentNames.includes(normalize(parentName))) {
          updateBlock(block);
        }
      });
    }

    const controls = document.querySelectorAll('input[name], select[name], textarea[name]');
    controls.forEach(ctrl => {
      ctrl.addEventListener('change', function (e) {
        updateBlocksForParent(e.target.name);
      });
    });

    document.querySelectorAll('.conditional').forEach(updateBlock);
  }, 500);
"))),
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
  )
)