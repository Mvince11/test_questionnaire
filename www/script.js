function updateConditionalBlocks() {
  document.querySelectorAll(".conditional").forEach(function(block) {
    const parentId = block.getAttribute("data-parent-question");
    const conditionRaw = block.getAttribute("data-condition");
    const parent = document.getElementById(parentId);

    if (!parent || !conditionRaw) {
      console.warn("Parent not found or condition missing for block:", block);
      return;
    }

    const conditions = conditionRaw.split(/[,|]/).map(c =>
      c.replace(/\u00A0/g, " ").trim().toLowerCase()
    );

    let show = false;

    parent.querySelectorAll("input[type=radio], input[type=checkbox]").forEach(input => {
      const val = input.value.replace(/\u00A0/g, " ").trim().toLowerCase();
      if (input.checked && conditions.includes(val)) {
        show = true;
      }
    });

    const select = parent.querySelector("select");
    if (select) {
      const val = select.value.replace(/\u00A0/g, " ").trim().toLowerCase();
      if (conditions.includes(val)) {
        show = true;
      }
    }

    const textarea = parent.querySelector("textarea");
    if (textarea) {
      const val = textarea.value.replace(/\u00A0/g, " ").trim().toLowerCase();
      if (conditions.includes(val)) {
        show = true;
      }
    }

    block.style.display = show ? "block" : "none";
    console.log(`Block ${block.id} display: ${show}`);
  });
}


document.addEventListener("DOMContentLoaded", function() {
  updateConditionalBlocks();
  document.addEventListener("change", updateConditionalBlocks);
  document.addEventListener("keyup", updateConditionalBlocks);
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

