import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['log', 'download', 'cancel'];

  connect() {
    this.timer = setInterval(() => {
      this.refresh();
    }, 1000);
  }

  refresh() {
    fetch(this.data.get('url'))
      .then(blob => blob.json())
      .then(status => {
        this.logTarget.innerText = status.log;
        this.logTarget.scrollTop = this.logTarget.scrollHeight;

        if (status.retry) {
          this.cancelTarget.classList.remove('d-none');
        } else {
          this.cancelTarget.classList.add('d-none');
          this.stopRefresh();

          if (status.document) {
            this.downloadTarget.href = status.document;
            this.downloadTarget.classList.remove('d-none');
          }
        }
      });
  }

  stopRefresh() {
    if (this.timer) {
      clearInterval(this.timer);
    }
  }

  disconnect() {
    this.stopRefresh();
  }

  cancel() {
    return fetch(`${this.cancelUrl}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': Rails.csrfToken(),
      },
    }).then(response => response.json());
  }

  get cancelUrl() {
    return this.data.get('cancel-url');
  }
}
