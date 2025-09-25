document.addEventListener("DOMContentLoaded", function () {
  function normalize(s) {
    return String(s || "").replace(/\u00A0/g, " ").trim().toLowerCase();
  }

  function updateBlock(block) {
    const expectedValues = block.dataset.condition.split(",").map(normalize);
    const parentName = block.dataset.parentQuestion;
    const selected = [];

    document.querySelectorAll(`[name='${parentName}']`).forEach(el => {
      if (el.tagName === "SELECT" && el.value) {
        selected.push(normalize(el.value));
      }
    });

    const show = expectedValues.some(val => selected.includes(val));
    block.style.display = show ? "block" : "none";
  }

  function updateAllBlocks() {
    document.querySelectorAll(".conditional").forEach(updateBlock);
  }

  document.querySelectorAll("select[name]").forEach(ctrl => {
    ctrl.addEventListener("change", updateAllBlocks);
  });

  updateAllBlocks();
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

