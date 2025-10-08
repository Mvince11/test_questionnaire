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
      if (replaced && !block.classList.contains("injected")) {
      replaced.before(block);
      block.classList.add("injected");
    }


      if (replaced) {
      replaced.style.setProperty("display", show ? "none" : "block", "important");
      block.style.setProperty("display", show ? "block" : "none", "important");
    
      replaced.classList.toggle("visible", !show);
      block.classList.toggle("visible", show);
    }


      block.style.display = show ? "block" : "none";
      block.classList.toggle("visible", show);
    } else {
      block.style.display = show ? "block" : "none";
      block.classList.toggle("visible", show);
    }
    
    console.log("🔍 Évaluation du bloc:", block.id || block.dataset.replace, {
  parents,
  conditions,
  answer: parents.map(getAnswer),
  show
});

console.log("🧪 Comparaison brute :", {
  condition: conditions,
  answer: parents.map(getAnswer)
});

  });
  

  console.log("🔁 updateConditionals triggered");

}
