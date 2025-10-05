document.addEventListener("DOMContentLoaded", function () {
    console.log("✅ Script conditionnels chargé");

    const normalize = s => String(s || "")
        .replace(/\u00A0/g, " ")
        .replace(/\s+/g, " ")
        .trim()
        .toLowerCase();

    // --- Fonction de lecture des réponses (inchangée, elle lit le localStorage si l'élément DOM est absent)
    function getAnswer(qid) {
        const container = document.getElementById(qid);
        if (container) {
            const radios = container.querySelectorAll(`input[type="radio"][name="${qid}"]`);
            if (radios.length) {
                const checked = Array.from(radios).find(r => r.checked);
                return checked ? normalize(checked.value) : "";
            }

            const checks = container.querySelectorAll(`input[type="checkbox"][name="${qid}"]`);
            if (checks.length) {
                return Array.from(checks).filter(c => c.checked).map(c => normalize(c.value));
            }

            const select = container.querySelector(`select[name="${qid}"]`);
            if (select) return normalize(select.value);

            const ta = container.querySelector(`textarea[name="${qid}"]`);
            if (ta) return normalize(ta.value);
        }

        const raw = localStorage.getItem(qid);
        if (!raw) return "";
        try {
            if (raw.startsWith("[") || raw.startsWith("{")) {
                const parsed = JSON.parse(raw);
                if (Array.isArray(parsed)) return parsed.map(normalize);
                return normalize(parsed);
            }
            return normalize(raw);
        } catch {
            return normalize(raw);
        }
    }

    // --- Fonction d'évaluation des conditions (MODIFIÉE)
    function updateConditionals() {
        // ... (Logique inchangée : elle gère le masquage/affichage en fonction des conditions) ...
        // Je ne réécris pas toute la fonction updateConditionals ici, elle est correcte.
        document.querySelectorAll(".conditional").forEach(block => {
            const parents = (block.getAttribute("data-parent-question") || "")
                .split(/[;,|]+/)
                .map(s => s.trim())
                .filter(Boolean);

            const conditions = (block.getAttribute("data-condition") || "")
                .split(/[;,|]+/)
                .map(s => normalize(s))
                .filter(Boolean);

            const replaceId = block.getAttribute("data-replace");
            let show = false;

            parents.forEach(pid => {
                const answer = getAnswer(pid);
                const parentElement = document.getElementById(pid);

                let parentIsAvailableForCheck = false;
                if (!parentElement) {
                    if (answer !== "") {
                        parentIsAvailableForCheck = true; 
                    }
                } else {
                    if (parentElement.clientHeight > 0 || parentElement.offsetParent !== null) {
                         parentIsAvailableForCheck = true;
                    }
                }

                if (parentIsAvailableForCheck) {
                    conditions.forEach(cond => {
                        const isNegation = cond.startsWith("!");
                        const expected = isNegation ? cond.slice(1) : cond;

                        const check = Array.isArray(answer) 
                            ? (isNegation ? answer.every(a => a !== expected) : answer.some(a => a === expected))
                            : (isNegation ? answer !== expected : answer === expected);

                        if (check) show = true;
                    });
                }
            });

            if (replaceId) {
                const replaced = document.getElementById(replaceId);
                if (replaced) {
                    replaced.style.display = show ? "none" : "block"; 
                    block.style.display = show ? "block" : "none"; 
                    block.classList.toggle("visible", show);
                    replaced.classList.toggle("visible", !show);
                }
            } else {
                block.style.display = show ? "block" : "none";
                block.classList.toggle("visible", show);
            }
        });
    }
    
   // --- MODIFICATION CLÉ DANS initializeVisualState() ---
   function initializeVisualState() {
        // Étape 1: Assurez-vous que TOUS les blocs de questions sont visibles par défaut (y compris q5).
        document.querySelectorAll(".question-block").forEach(block => {
            block.style.display = "block";
        });
        
        // Étape 2: Masque uniquement les conditionnels (q5a) pour prévenir le flash avant évaluation.
        // C'est nécessaire car le CSS a dû être retiré.
        document.querySelectorAll(".conditional").forEach(block => {
            block.style.display = "none";
        });
        
        // RÉSULTAT: q5 est visible. q5a est masqué. Le JavaScript prend le relais immédiatement.
    }
    
    
    // --- Synchronisation initiale des réponses (inchangée)
    document.querySelectorAll("input, select, textarea").forEach(el => {
      if (!el.name) return;
      if (el.type === "checkbox") {
        const all = document.querySelectorAll(`input[type="checkbox"][name="${el.name}"]`);
        const checked = Array.from(all).filter(c => c.checked).map(c => c.value);
        localStorage.setItem(el.name, JSON.stringify(checked));
      } else if (el.type === "radio") {
        const checked = document.querySelector(`input[type="radio"][name="${el.name}"]:checked`);
        if (checked) localStorage.setItem(el.name, checked.value);
      } else {
        localStorage.setItem(el.name, el.value);
      }
    });



    // --- Sur chaque changement de réponse → mise à jour (inchangée)
    document.addEventListener("change", function (e) {
        if (!e.target.name) return;

        if (e.target.type === "checkbox") {
            const all = document.querySelectorAll(`input[type="checkbox"][name="${e.target.name}"]`);
            const checked = Array.from(all).filter(c => c.checked).map(c => c.value);
            localStorage.setItem(e.target.name, JSON.stringify(checked));
        } else {
            localStorage.setItem(e.target.name, e.target.value);
        }
      const q2 = document.querySelector('input[name="q2"]:checked');
      if (q2) {
        localStorage.setItem("q2", q2.value);
      }

        updateConditionals();
    });

    // --- Évaluation INITIALE (Ordre des étapes critique)
    initializeVisualState(); 
    
    updateConditionals();    

    // --- Réévaluation différée (inchangée)
    setTimeout(() => {
        console.log("⏳ Réévaluation différée");
        updateConditionals();
    }, 300);

    // --- Fonctions d'attente (inchangées)
    function waitForAnswer(qid, expected, attempt = 0) {
        const val = getAnswer(qid);
        if (val === expected) {
            console.log("✅ Réponse détectée pour", qid, "→", val);
            updateConditionals();
        } else if (attempt < 10) {
            console.log("⏳ Attente réponse", qid, "tentative", attempt, "→", val);
            setTimeout(() => waitForAnswer(qid, expected, attempt + 1), 200);
        } else {
            console.warn("⚠️ Réponse non détectée pour", qid);
        }
    }

    waitForAnswer("q2", "un syndicat mixte");
    
    function waitForConditionals(attempt = 0) {
        const blocks = document.querySelectorAll(".conditional");
        if (blocks.length > 0) {
            console.log("✅ Blocs conditionnels détectés → relance updateConditionals");
            updateConditionals();
        } else if (attempt < 20) {
            console.log("⏳ Attente blocs conditionnels, tentative", attempt);
            setTimeout(() => waitForConditionals(attempt + 1), 200);
        } else {
            console.warn("⚠️ Aucun bloc conditionnel détecté après 20 tentatives");
        }
    }

    waitForConditionals();
    
    

});