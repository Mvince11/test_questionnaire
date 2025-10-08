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
    return Array.isArray(parsed) ? parsed.map(normalize) : normalize(parsed);
  } catch {
    return normalize(raw);
  }
}
