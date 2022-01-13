import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['spinner', 'responseContainer'];

  submit(e) {
    e.preventDefault();
    const form = e.target;
    fetch(form.getAttribute('action'), {
      method: form.getAttribute('method'),
      body: new FormData(form),
      headers: {
        'X-CSRF-Token': Rails.csrfToken(),
      },
    })
      .then(response => response.text())
      .then(html => {
        e.target.parentNode.parentNode.innerHTML = html;
      });
  }

  submitThenToast(e) {
    const form = e.target.closest('form');
    fetch(form.getAttribute('action'), {
      method: form.getAttribute('method'),
      body: new FormData(form),
      headers: {
        'X-CSRF-Token': Rails.csrfToken(),
      },
    }).then(response => {
      Swal.fire({
        toast: true,
        type: 'success',
        position: 'top-end',
        timer: 4000,
        icon: 'success',
        title: this.element.getAttribute('data-toast'),
        showConfirmButton: false,
      });
    });
  }

  submitGet(e) {
    fetch(this.url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/js',
        Accept: 'application/js',
      },
    });
  }

  get url() {
    return this.element.getAttribute('action');
  }

  get method() {
    return this.element.getAttribute('method');
  }
}
