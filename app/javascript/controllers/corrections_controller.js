import { Controller } from 'stimulus';

export default class extends Controller {
  phasesChange() {
    this.populatePhasesField(
      this.element.value,
      this.element.getAttribute('data-targetbox')
    );
  }
  populatePhasesField(phase_id, target_box) {
    const state_box = document.getElementById(target_box);
    state_box.innerHTML = '';

    let option = document.createElement('option');
    option.value = '';
    option.innerHTML = 'seleciona una fase';
    state_box.appendChild(option);
    state_box.disabled = false;

    fetch('/imports/phases?id=' + phase_id, {
      credentials: 'same-origin',
    })
      .then(response => response.json())
      .then(data => {
        data.forEach(item => {
          let option = document.createElement('option');
          option.value = item[0];
          option.innerHTML = item[1];
          state_box.appendChild(option);
        });
      });
  }

  stagesChange() {
    this.populateStagesField(
      this.element.value,
      this.element.getAttribute('data-targetbox')
    );
  }
  populateStagesField(state_id, target_box) {
    const state_box = document.getElementById(target_box);
    state_box.innerHTML = '';

    let option = document.createElement('option');
    option.value = '';
    option.innerHTML = 'seleciona una estado';
    state_box.appendChild(option);
    state_box.disabled = false;

    fetch('/imports/stages?id=' + state_id, {
      credentials: 'same-origin',
    })
      .then(response => response.json())
      .then(data => {
        data.forEach(item => {
          let option = document.createElement('option');
          option.value = item[0];
          option.innerHTML = item[1];
          state_box.appendChild(option);
        });
      });
  }
}
