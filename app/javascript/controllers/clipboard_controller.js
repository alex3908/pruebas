import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['textToCopy'];
  copy() {
    let text = this.valueToCopy;
    let modal = this.Modal;

    Swal.fire({
      toast: true,
      type: 'success',
      position: 'top-end',
      timer: 4000,
      icon: 'success',
      title: this.element.dataset['message'],
      showConfirmButton: false,
    });

    if (window.clipboardData && window.clipboardData.setData) {
      return clipboardData.setData('Text', text);
    } else if (
      document.queryCommandSupported &&
      document.queryCommandSupported('copy')
    ) {
      var textarea = document.createElement('textarea');
      textarea.textContent = text;
      textarea.style.position = 'fixed'; // Prevent scrolling to bottom of page in MS Edge.
      const container = modal ? document.getElementById(modal) : document.body;
      container.appendChild(textarea);
      textarea.select();
      try {
        return document.execCommand('copy'); // Security exception may be thrown by some browsers.
      } catch (ex) {
        console.warn('Copy to clipboard failed.', ex);
        return false;
      } finally {
        container.removeChild(textarea);
      }
    }
  }

  get valueToCopy() {
    if (this.hasTextToCopyTarget) {
      return this.textToCopyTarget.value;
    } else {
      return this.element.innerHTML;
    }
  }

  get Modal() {
    if (this.hasTextToCopyTarget) {
      const {
        dataset: { modal = null },
      } = this.textToCopyTarget;
      return modal;
    } else {
      return null;
    }
  }
}
