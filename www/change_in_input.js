$(document).on("input change", "input, select, textarea", function() {
  const id = $(this).attr("id");
  const name = $(this).attr("name");
  const type = $(this).attr("type");

  if (!id) return; // ignore si pas d'id

  if (type === "checkbox") {
    // ✅ récupérer toutes les cases cochées du même nom
    const values = $(`input[name='${name}']:checked`).map(function() {
      return $(this).val();
    }).get();
    Shiny.setInputValue(name, values, {priority: "event"});
  } else {
    // ✅ synchroniser la valeur unique
    Shiny.setInputValue(id, $(this).val(), {priority: "event"});
  }
});


