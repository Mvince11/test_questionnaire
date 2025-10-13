$(document).on("change", "input[type='radio'], input[type='checkbox'], select, textarea", function() {
  const name = $(this).attr("name");
  const type = $(this).attr("type");
  
  if (type === "checkbox") {
    const values = $(`input[name='${name}']:checked`).map(function() {
      return $(this).val(); }).get(); Shiny.setInputValue(name, values); 
    
  } else {
    Shiny.setInputValue(name, $(this).val()); } });


