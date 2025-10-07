document.addEventListener("DOMContentLoaded", function () {
  console.log("✅ Script conditionnels chargé");

  // 🔧 Normalisation des chaînes
  const normalize = s => String(s || "")
    .replace(/\u00A0/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .toLowerCase();

  // 🔍 Lecture des réponses
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
      if (select) {
        if (select.multiple) {
          return Array.from(select.selectedOptions).map(opt => normalize(opt.value));
        }
        return normalize(select.value);
      }

      const ta = container.querySelector(`textarea[name="${qid}"]`);
      if (ta) return normalize(ta.value);
    }

    const raw = localStorage.getItem(qid);
    if (!raw) return "";
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed)
        ? parsed.map(normalize)
        : normalize(parsed);
    } catch {
      return normalize(raw);
    }
  }

  // 🔁 Évaluation des blocs conditionnels
  function updateConditionals() {
    document.querySelectorAll(".conditional").forEach(block => {
      const parents = (block.dataset.parentQuestion || "")
        .split(/[;,|]+/)
        .map(s => s.trim())
        .filter(Boolean);

      const conditions = (block.dataset.condition || "")
        .split(/[;,|]+/)
        .map(s => normalize(s))
        .filter(Boolean);

      const replaceId = block.dataset.replace;
      let show = false;

      parents.forEach(pid => {
        const answer = getAnswer(pid);
        const parentElement = document.getElementById(pid);

        const parentVisible = parentElement
          ? (parentElement.clientHeight > 0 || parentElement.offsetParent !== null)
          : answer !== "";

        if (parentVisible) {
          conditions.forEach(cond => {
            const isNegation = cond.startsWith("!");
            const expected = isNegation ? cond.slice(1) : cond;

            const check = Array.isArray(answer)
              ? (isNegation ? answer.every(a => a !== expected) : answer.includes(expected))
              : (isNegation ? answer !== expected : answer === expected);

            if (check) show = true;
          });
        }
      });

      if (replaceId) {
        const replaced = document.getElementById(replaceId);
        if (replaced && !block.isConnected) {
          replaced.before(block);
        }

        if (replaced) {
          replaced.style.display = show ? "none" : "block";
          replaced.classList.toggle("visible", !show);
        }

        block.style.display = show ? "block" : "none";
        block.classList.toggle("visible", show);
      } else {
        block.style.display = show ? "block" : "none";
        block.classList.toggle("visible", show);
      }
    });

    // ✅ Logique spécifique q5 / q5.1
    const q2Answers = getAnswer("q2");
    const hasSyndicat = Array.isArray(q2Answers)
      ? q2Answers.includes("un syndicat mixte")
      : q2Answers === "un syndicat mixte";

    const q5 = document.getElementById("q5");
    const q51 = document.getElementById("q5.1");

    if (q5) q5.style.display = hasSyndicat ? "none" : "block";
    if (q51) q51.style.display = hasSyndicat ? "block" : "none";
  }

  // 🎨 Initialisation visuelle
  function initializeVisualState() {
    document.querySelectorAll(".question-block").forEach(block => {
      block.style.display = "block";
    });

    document.querySelectorAll(".conditional").forEach(block => {
      block.style.display = "none";
    });
  }

  // 📦 Injection des blocs .include
  const includes = document.querySelectorAll(".include");
  let loadedCount = 0;

  includes.forEach(el => {
    const url = el.dataset.include;
    fetch(url)
      .then(res => res.text())
      .then(html => {
        el.innerHTML = html;
        loadedCount++;
        if (loadedCount === includes.length) {
          console.log("✅ Tous les blocs .include injectés");
          updateConditionals();
        }
      });
  });

  // 💾 Synchronisation initiale des réponses
  document.querySelectorAll("input, select, textarea").forEach(el => {
    if (!el.name) return;
    let value;
    if (el.type === "checkbox") {
      const all = document.querySelectorAll(`input[type="checkbox"][name="${el.name}"]`);
      value = Array.from(all).filter(c => c.checked).map(c => c.value);
    } else if (el.type === "radio") {
      const checked = document.querySelector(`input[type="radio"][name="${el.name}"]:checked`);
      value = checked ? checked.value : "";
    } else {
      value = el.value;
    }
    localStorage.setItem(el.name, JSON.stringify(value));
  });

  // 🔄 Mise à jour à chaque changement
  document.addEventListener("change", function (e) {
    if (!e.target.name) return;
    let value;
    if (e.target.type === "checkbox") {
      const all = document.querySelectorAll(`input[type="checkbox"][name="${e.target.name}"]`);
      value = Array.from(all).filter(c => c.checked).map(c => c.value);
    } else {
      value = e.target.value;
    }
    localStorage.setItem(e.target.name, JSON.stringify(value));
    updateConditionals();
  });

  // 🚀 Initialisation
  initializeVisualState();
  updateConditionals();
  setTimeout(updateConditionals, 300);
});
