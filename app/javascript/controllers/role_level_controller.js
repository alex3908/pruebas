import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['role'];
  connect() {
    initSelect2(this.roleTarget);
  }
}
