$(document).ready(function () {
  // Fonction d'affichage conditionnel
  function updateConditionalVisibility(questionId, selectedValue) {
    $('[data-parent-question="' + questionId + '"]').each(function () {
      var condition = $(this).data('condition');
      if (selectedValue === condition) {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  }

  // Écouteur pour les radios
  $('body').on('change', 'input[type="radio"]', function () {
    var questionId = $(this).attr('name');
    var selectedValue = $(this).val();
    updateConditionalVisibility(questionId, selectedValue);
  });

  // Écouteur pour les selects
  $('body').on('change', 'select', function () {
    var questionId = $(this).attr('name');
    var selectedValue = $(this).val();
    updateConditionalVisibility(questionId, selectedValue);
  });
});

