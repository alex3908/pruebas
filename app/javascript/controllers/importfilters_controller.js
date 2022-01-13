import { Controller } from 'stimulus';
import { DirectUpload } from '@rails/activestorage';

const TIMEOUT = 7500;

export default class extends Controller {
  static targets = ['input', 'filter'];

  showLoading() {
    return new Promise(resolve => {
      Swal.fire({
        title: 'Cargando archivo',
        text: 'En cuanto este disponible, se te confirmará...',
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

  showError(error = '') {
    if (error.length == 0) {
      Swal.fire({
        icon: 'error',
        title: 'Oops...',
        text:
          'Hubo un error al procesar tu archivo, por favor inténtalo de nuevo.',
        customClass: {
          confirmButton: 'btn btn-success',
          cancelButton: 'btn btn-danger',
        },
        confirmButton: false,
        cancelButton: true,
        buttonsStyling: false,
      });
    } else {
      Swal.fire({
        icon: 'error',
        title: 'Error',
        text: error,
        customClass: {
          confirmButton: 'btn btn-success',
          cancelButton: 'btn btn-danger',
        },
        confirmButton: false,
        cancelButton: true,
        buttonsStyling: false,
      });
    }
  }

  async finish(url = '') {
    const message = `Hemos terminado de preparar tu archivo. 
            ${
              url.length == 0
                ? ''
                : 'Se detectaron algunas inconsistencias en la información.'
            }`;

    const confirm_button = url.length > 0 ? 'Descargar' : 'OK';
    await Swal.fire({
      title: 'Archivo listo',
      text: message,
      confirmButtonText: confirm_button,
      customClass: {
        confirmButton: 'btn btn-success',
        cancelButton: 'btn btn-danger',
      },
      allowOutsideClick: false,
    }).then(async result => {
      const { value = false } = result;
      if (value) {
        this.inputTarget.value = '';
      }
    });

    if (url.length > 0) {
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
  }

  async directUpload() {
    const upload = new DirectUpload(
      this.inputTarget.files[0],
      '/rails/active_storage/direct_uploads'
    );

    return new Promise((resolve, reject) => {
      upload.create((err, blob) => {
        if (err) {
          return reject(err);
        }
        resolve(blob.signed_id);
      });
    });
  }

  async createJobStatus() {
    const filter_id = this.filterTarget.value;
    const file_id = await this.directUpload();
    const response = await fetch(this.data.get('url'), {
      method: 'POST',
      body: JSON.stringify({
        file: file_id,
        filter: filter_id,
      }),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': Rails.csrfToken(),
      },
    });

    if (response.ok) {
      return await response.json();
    }
    const data = await Promise.reject(response);
  }

  async upload() {
    const { files } = this.inputTarget;
    const [file] = files;

    if (!files || !file) {
      return;
    }

    await Swal.fire({
      title: '¿Estás seguro que deseas importar el archivo?',
      text: `Archivo: ${file.name}`,
      showCancelButton: true,
      customClass: {
        confirmButton: 'btn btn-success',
        cancelButton: 'btn btn-danger',
      },
      confirmButtonText: 'Sí, Continuar.',
      cancelButtonText: 'No, Cancelar.',
    }).then(async result => {
      const { value = false } = result;
      if (value) {
        await this.startProcess();
      } else {
        this.inputTarget.value = '';
      }
    });
  }

  async startProcess() {
    await this.showLoading();
    try {
      const job_status = await this.createJobStatus();
      const { document = '' } = await this.verifyJobStatusUntilReady(
        job_status.url
      );
      this.closeLoading();
      await this.finish(document);
    } catch (error) {
      console.warn(error);
      if (error.message) {
        this.showError(error.message);
      } else {
        this.showError();
      }
    }
  }

  async wait(time) {
    return await new Promise(resolve => setTimeout(resolve, time));
  }

  async verifyJobStatus(url) {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(response.statusText);
    }

    const job_status = await response.json();

    const { retry = false, document = '' } = job_status;

    if (job_status.status == 'error') {
      throw new Error(job_status.error_message);
    } else if (retry) {
      throw new Error('Retry');
    } else {
      return { status: true, document };
    }
  }

  async verifyJobStatusUntilReady(url) {
    try {
      return await this.verifyJobStatus(url);
    } catch (err) {
      if (err.message && err.message === 'Retry') {
        await this.wait(TIMEOUT);
        return await this.verifyJobStatusUntilReady(url);
      }
      throw err;
    }
  }
}
