console.log = function () {};

console.log("🚀 initConditionals.js chargé");

function waitForUpdateConditionals(callback) {
  if (typeof updateConditionals === "function") {
    callback();
  } else {
    console.log("⏳ En attente de updateConditionals...");
    setTimeout(() => waitForUpdateConditionals(callback), 100);
  }
}

function bindLiveConditionalTriggers() {
  document.querySelectorAll("input, select, textarea").forEach(el => {
    el.addEventListener("change", updateConditionals);
    el.addEventListener("input", updateConditionals);
    el.addEventListener("blur", updateConditionals);
  });
}

function bindAnswerStorage() {
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

function watchUiContainer(id) {
  const tryAttachObserver = () => {
    const target = document.getElementById(id);
    if (!target) {
      console.log(`⏳ En attente de #${id}...`);
      setTimeout(tryAttachObserver, 100);
      return;
    }

    console.log(`📌 Observateur attaché à #${id}`);
    const observer = new MutationObserver(() => {
      console.log(`🔁 Mutation détectée sur #${id} → updateConditionals()`);
      setTimeout(updateConditionals, 100);
    });

    observer.observe(target, { childList: true, subtree: true });
  };

  tryAttachObserver();
}

document.addEventListener("DOMContentLoaded", function () {
  console.log("📦 DOMContentLoaded : DOM prêt");

  bindAnswerStorage();
  bindLiveConditionalTriggers();
  watchUiContainer("main_ui");

  updateConditionals();
  setTimeout(updateConditionals, 300);
});

window.onload = function () {
  console.log("🎯 window.onload : ressources chargées");
  updateConditionals();
};

// ✅ Réévaluation après mise à jour dynamique du UI
document.addEventListener("shiny:uiUpdated", function () {
  console.log("⚡ shiny:uiUpdated → updateConditionals()");
  setTimeout(updateConditionals, 100);
});
