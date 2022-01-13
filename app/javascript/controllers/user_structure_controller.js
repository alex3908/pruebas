import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['user'];
  connect() {
    initSelect2(this.userTarget);
  }
}
