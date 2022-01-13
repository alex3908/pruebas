import { Controller } from 'stimulus';

const TIMEOUT = 7500;

export default class extends Controller {
  static targets = ['form'];

  showLoading() {
    return new Promise(resolve => {
      Swal.fire({
        title: 'Preparando archivo',
        text: 'En cuanto este disponible, veras el botón de descarga...',
        allowOutsideClick: false,
        onBeforeOpen: () => {
          Swal.showLoading();
          resolve();
        },
      });
    });
  }

  closeLoading() {
    Swal.close();
  }

  showError() {
    Swal.fire({
      icon: 'error',
      title: 'Oops...',
      text:
        'Hubo un error al generar tu archivo, por favor inténtalo de nuevo.',
      customClass: {
        confirmButton: 'btn btn-success',
        cancelButton: 'btn btn-danger',
      },
      confirmButton: false,
      cancelButton: true,
      buttonsStyling: false,
    });
  }

  showQuantity() {
    Swal.fire({
      icon: 'error',
      title: 'Oops...',
      text:
        'Has superado la cantidad de descarga permitida, por favor inténtalo de nuevo usando los filtros.',
      customClass: {
        confirmButton: 'btn btn-success',
        cancelButton: 'btn btn-danger',
      },
      confirmButton: false,
      cancelButton: true,
      buttonsStyling: false,
    });
  }

  async openFile(url) {
    await Swal.fire({
      title: 'Archivo listo',
      text: 'Hemos terminado de preparar tu archivo...',
      confirmButtonText: 'Descargar',
      customClass: {
        confirmButton: 'btn btn-success',
        cancelButton: 'btn btn-danger',
      },
      allowOutsideClick: false,
    });

    const link = document.createElement('a');
    link.href = url;
    link.download = url
      .split('#')
      .shift()
      .split('?')
      .shift()
      .split('/')
      .pop();
    link.dispatchEvent(new MouseEvent('click'));
  }

  body() {
    return new FormData(this.formTarget);
  }

  async getReport() {
    const response = await fetch(this.data.get('url'), {
      method: 'POST',
      body: this.body(),
      headers: {
        'X-CSRF-Token': Rails.csrfToken(),
      },
    });

    if (response.ok) {
      return await response.json();
    }
    const data = await Promise.reject(response);
  }

  async generate() {
    await this.showLoading();
    try {
      const job_status = await this.getReport();
      if (job_status.error == 'limit_reached') {
        this.showQuantity();
      } else {
        const file_url = await this.downloadItemWithTimeout(job_status.url);
        this.closeLoading();
        await this.openFile(file_url);
      }
    } catch (error) {
      console.warn(error);
      this.showError();
    } finally {
      const template_param = document.getElementById('template');

      if (template_param) {
        template_param.remove();
      }
    }
  }

  async downloadTemplate() {
    let input = document.createElement('input');
    input.setAttribute('type', 'hidden');
    input.setAttribute('name', 'template');
    input.setAttribute('id', 'template');
    input.setAttribute('value', true);
    document.getElementsByTagName('form')[0].appendChild(input);

    await this.generate();
  }

  async wait(time) {
    return await new Promise(resolve => setTimeout(resolve, time));
  }

  async downloadItem(url) {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(response.statusText);
    }

    const job_status = await response.json();
    if (job_status.document) {
      return job_status.document;
    } else if (job_status.retry) {
      throw new Error('Retry');
    } else {
      throw new Error('Intentalo de nuevo');
    }
  }

  async downloadItemWithTimeout(url) {
    try {
      return await this.downloadItem(url);
    } catch (err) {
      if (err.message && err.message === 'Retry') {
        await this.wait(TIMEOUT);
        return await this.downloadItemWithTimeout(url);
      }
      throw err;
    }
  }
}
