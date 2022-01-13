import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['updateAll'];
  connect() {
    initToggle(this.updateAllTarget);
  }
}
