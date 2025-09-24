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
