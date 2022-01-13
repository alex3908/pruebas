import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['container', 'loadingWheel'];

  load(e) {
    e.preventDefault();
    if (this.hasLoadingWheelTarget) {
      this.loadingWheelTarget.classList.remove('d-none');
    }
    let url = e.target.href;

    if (this.url) {
      url = this.url;
    }

    fetch(url, {
      headers: {
        'Content-Type': 'text/javascript',
      },
    })
      .then(response => response.text())
      .then(html => {
        if (this.hasLoadingWheelTarget) {
          this.loadingWheelTarget.classList.add('d-none');
        }
        this.targetContainer.innerHTML = html;
      });
  }

  get targetContainer() {
    if (this.hasContainerTarget) {
      return this.containerTarget;
    } else if (this.data.has('container-selector')) {
      return document.querySelector(this.data.get('container-selector'));
    } else {
      return this.element;
    }
  }

  get url() {
    return this.data.get('url');
  }
}
