
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

  // 🔄 Mise à jour à chaque changement
  function bindChangeListeners() {
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
  }

  // 📦 Injection des blocs .include
  function injectIncludes(callback) {
    const includes = document.querySelectorAll(".include");
    let loadedCount = 0;

    if (includes.length === 0) {
      callback();
      return;
    }

    includes.forEach(el => {
      const url = el.dataset.include;
      fetch(url)
        .then(res => res.text())
        .then(html => {
          el.innerHTML = html;
          loadedCount++;
          if (loadedCount === includes.length) {
            console.log("✅ Tous les blocs .include injectés");
            callback();
          }
        });
    });
  }

  // 🔗 Lier les parents aux écouteurs
  function bindParentListeners() {
    const parents = new Set();

    document.querySelectorAll(".conditional").forEach(block => {
      const parentList = (block.dataset.parentQuestion || "")
        .split(/[;,|]+/)
        .map(s => s.trim())
        .filter(Boolean);

      parentList.forEach(pid => parents.add(pid));
    });

    parents.forEach(pid => {
      const container = document.getElementById(pid);
      if (!container) return;

      container.querySelectorAll("input, select, textarea").forEach(el => {
        el.addEventListener("change", updateConditionals);
      });
    });
  }

  // ✅ DOM prêt
  document.addEventListener("DOMContentLoaded", function () {
    console.log("📦 DOMContentLoaded : DOM prêt");

    initializeVisualState();
    injectIncludes(() => {
      updateConditionals();
      bindParentListeners();
      bindChangeListeners();
      setTimeout(updateConditionals, 300);
    });
  });

  // ✅ Tout chargé (images, CSS, etc.)
  window.onload = function () {
    console.log("🎯 window.onload : ressources chargées");
    updateConditionals(); // sécurité visuelle
  };