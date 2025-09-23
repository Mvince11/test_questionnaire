
try {
document.addEventListener('DOMContentLoaded', function () {
      const normalize = s => String(s || '').trim().toLowerCase();

      function parseExpected(cond) {
        if (!cond) return [];
        return cond.split(',').map(s => s.trim()).filter(Boolean).map(normalize);
      }

      function getSelectedValues(parentName) {
        const selected = [];
        const parentEls = document.querySelectorAll(`[name='${parentName}']`);
        parentEls.forEach(el => {
          if ((el.type === 'radio' || el.type === 'checkbox') && el.checked) {
            selected.push(normalize(el.value));
          } else if (el.tagName === 'SELECT' && el.value) {
            selected.push(normalize(el.value));
          } else if ((el.tagName === 'TEXTAREA' || el.type === 'text') && el.value) {
            selected.push(normalize(el.value));
          }
        });
        return selected;
      }

      function updateBlock(block) {
        const expectedValues = parseExpected(block.dataset.condition);
        const parentNames = block.dataset.parentQuestion?.split(';').map(normalize) || [];

        let show = false;
        parentNames.forEach(parent => {
          const selected = getSelectedValues(parent);
          if (expectedValues.some(val => selected.includes(val))) {
            show = true;
          }
        });

        block.style.display = show ? 'block' : 'none';
        block.classList.toggle('visible', show);
      }

      function updateBlocksForParent(parentName) {
        document.querySelectorAll('.conditional').forEach(block => {
          const parentNames = block.dataset.parentQuestion?.split(';').map(normalize) || [];
          const parentField = document.querySelector(`[name='${parentName}']`);
          if (parentField && block.contains(parentField)) return;
          if (parentNames.includes(normalize(parentName))) {
            updateBlock(block);
          }
        });
      }

      const controls = document.querySelectorAll('input[name], select[name], textarea[name]');
      controls.forEach(ctrl => {
        ctrl.addEventListener('change', function (e) {
          updateBlocksForParent(e.target.name);
        });
      });

      document.querySelectorAll('.conditional').forEach(updateBlock);
    });
} catch (e) {
  console.error('Erreur JS :', e);
}