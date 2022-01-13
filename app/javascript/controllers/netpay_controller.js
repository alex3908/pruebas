import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['paymentForm', 'tokenField'];

  connect() {
    if (this.data.has('redirect-url')) {
      Swal.fire({
        title: 'Revisión 3ds',
        type: 'warning',
        text:
          'Serás redirigido al sitio de Netpay para realizar la revisión 3ds de tus datos',
        confirmButtonText: 'Continuar',
        customClass: {
          confirmButton: 'btn btn-warning',
        },
        buttonsStyling: false,
      }).then(() => {
        location.replace(this.redirectUrl);
      });
    } else if (
      this.isSubscriptionResponse &&
      this.subscriptionResponse == 'success'
    ) {
      Swal.fire({
        title: '¡Domiciliación creada exitosamente!',
        type: 'success',
        confirmButtonText: 'Continuar',
        customClass: {
          confirmButton: 'btn btn-success',
          cancelButton: 'btn btn-danger',
        },
        buttonsStyling: false,
      });
    } else if (
      this.isSubscriptionResponse &&
      this.subscriptionResponse == 'rejected'
    ) {
      Swal.fire({
        title: 'Error',
        text: 'La tarjeta fue rechazada',
        type: 'error',
        confirmButtonText: 'Continuar',
        footer: 'Revisa el estado de tu tarjeta para verificar su validez.',
      });
    } else if (
      this.isSubscriptionResponse &&
      this.subscriptionResponse == 'error'
    ) {
      Swal.fire({
        title: 'Error',
        text: 'Hubo un problema al procesar el pago.',
        type: 'error',
        confirmButtonText: 'Continuar',
        footer:
          'Si el problema persiste, por favor comunícate con atención al cliente.',
      });
    } else {
      NetPay.setApiKey(this.apiKey);
      if (this.data.get('env') == 'test') {
        NetPay.setSandboxMode(true);
      }

      let netpaySuccessResponseHandler = response => {
        const token = JSON.parse(response.message.data).token;
        this.tokenFieldTarget.value = token;
        this.paymentFormTarget.submit();
      };

      let netpayErrorResponseHandler = response => {
        Swal.fire({
          title: 'ERROR [' + response.status + ']',
          text: response.message,
          type: 'error',
          confirmButtonText: 'Ok',
        });
      };

      NetPay.form.generate(
        'netpay-form',
        netpaySuccessResponseHandler,
        netpayErrorResponseHandler,
        { title: '', submitText: 'Pagar' }
      );
    }
  }

  get isSubscriptionResponse() {
    return this.data.has('subscription-response');
  }

  get subscriptionResponse() {
    return this.data.get('subscription-response');
  }

  get apiKey() {
    return this.data.get('api-key');
  }

  get redirectUrl() {
    return this.data.get('redirect-url');
  }
}
