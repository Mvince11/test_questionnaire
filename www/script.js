document.addEventListener("DOMContentLoaded", function() {
  // Fonction pour mettre à jour l'affichage des conditionnels
  function updateConditionalBlocks() {
    document.querySelectorAll(".conditional").forEach(function(block) {
      const parentId = block.getAttribute("data-parent-question");
      const condition = block.getAttribute("data-condition");
      const parent = document.getElementById(parentId);

      if (!parent) return;

      let show = false;

      // Vérifier si le parent est un ensemble de radios
      const radios = parent.querySelectorAll("input[type=radio]");
      if (radios.length > 0) {
        radios.forEach(r => {
          if (r.checked && r.value.trim() === condition) {
            show = true;
          }
        });
      }

      // Vérifier si le parent est un ensemble de checkboxes
      const checkboxes = parent.querySelectorAll("input[type=checkbox]");
      if (checkboxes.length > 0) {
        checkboxes.forEach(c => {
          if (c.checked && c.value.trim() === condition) {
            show = true;
          }
        });
      }

      // Vérifier si le parent est un <select>
      const select = parent.querySelector("select");
      if (select) {
        if (select.value.trim() === condition) {
          show = true;
        }
      }

      // Vérifier si le parent est un <textarea> (rare)
      const textarea = parent.querySelector("textarea");
      if (textarea) {
        if (textarea.value.trim() === condition) {
          show = true;
        }
      }

      // Appliquer l’affichage
      block.style.display = show ? "block" : "none";
    });
  }

  // Attacher les écouteurs à tous les inputs
  document.addEventListener("change", updateConditionalBlocks);
  document.addEventListener("keyup", updateConditionalBlocks);

  // Initialiser au chargement
  updateConditionalBlocks();
});

document.addEventListener("DOMContentLoaded", function () {
  const normalize = s => String(s || "")
    .replace(/\u00A0/g, " ") // supprime &nbsp;
    .replace(/\s+/g, " ")
    .trim()
    .toLowerCase();

  function getAnswer(qid) {
    const container = document.getElementById(qid);
    if (container) {
      // radios
      const radios = container.querySelectorAll(`input[type="radio"][name="${qid}"]`);
      if (radios.length) {
        const checked = Array.from(radios).find(r => r.checked);
        return checked ? normalize(checked.value) : "";
      }
      // checkboxes
      const checks = container.querySelectorAll(`input[type="checkbox"][name="${qid}"]`);
      if (checks.length) {
        return Array.from(checks).filter(c => c.checked).map(c => normalize(c.value));
      }
      // select
      const select = container.querySelector(`select[name="${qid}"]`);
      if (select) return normalize(select.value);
      // textarea
      const ta = container.querySelector(`textarea[name="${qid}"]`);
      if (ta) return normalize(ta.value);
    }
    // fallback localStorage
    const raw = localStorage.getItem(qid);
    if (!raw) return "";
    try {
      const parsed = JSON.parse(raw);
      if (Array.isArray(parsed)) return parsed.map(normalize);
      return normalize(parsed);
    } catch {
      return normalize(raw);
    }
  }

  function matches(answer, expected) {
    if (Array.isArray(answer)) {
      return answer.includes(normalize(expected));
    } else {
      return normalize(answer) === normalize(expected);
    }
  }

  function updateConditionals() {
    document.querySelectorAll(".conditional").forEach(block => {
      const parents = (block.getAttribute("data-parent-question") || "")
        .split(/[;,]+/) // accepte séparateurs ";" ou ","
        .map(s => s.trim())
        .filter(Boolean);
      const condition = normalize(block.getAttribute("data-condition") || "");

      // la question s'affiche si AU MOINS UN parent correspond
      let show = false;
      parents.forEach(pid => {
        const answer = getAnswer(pid);
        if (matches(answer, condition)) {
          show = true;
        }
      });

      block.style.display = show ? "block" : "none";
      block.classList.toggle("visible", show);
    });
  }

  // initialisation
  updateConditionals();
  // mise à jour lors des changements
  document.addEventListener("change", updateConditionals);
  document.addEventListener("keyup", updateConditionals);
});

