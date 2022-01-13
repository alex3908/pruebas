import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [];
  connect() {
    if (this.data.has('redirect-url')) {
      location.replace(this.redirectUrl);
    }
  }

  get redirectUrl() {
    return this.data.get('redirect-url');
  }
}
