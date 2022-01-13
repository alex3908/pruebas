const generalData = {
  date: '',
  clients: [],
  paymentMethods: [],
  bankAccounts: [],
  branches: [],
  actualDate: '',
  isEditable: false,
  user: '',
  showAmount: true,
  canSetDate: true,
  canNotAddCapitalPayments: false,
  hasActiveSuscriptions: false,
  restructureMessage: '',
  isDownPaymentDiffer: false,
  canCreateOrUpdatePenalty: false,
};

const dateFormat = date_to_format => {
  const date = date_to_format;
  const newdate = date
    .split('/')
    .reverse()
    .join('-');
  return newdate;
};

const redirectBack = url => {
  window.location = url;
};

const initSelect2ForVue = element_id => {
  $(element_id).select2({
    placeholder: 'Seleccione un elemento',
    width: '100%',
  });
};

const oldLoading = (is_modal = false) => {
  const $body = $('body'),
    $backdrop = $(
      `<div id='backdrop-loader' class='modal-backdrop' style='${
        is_modal ? 'z-index:5000;' : ''
      }'></div>`
    ),
    $loader = $(`<div id="loader" class="modal fade" style="display: block;${
      is_modal ? 'z-index:6000;' : ''
    }">
    <div class="modal-loader">
    <div class="spinner-border text-light">
    <span class="sr-only">Cargando...</span>
    </div>
    </div>
    </div>`);

  $body.append($backdrop);
  $body.append($loader);
  $backdrop.addClass('show');
  $loader.addClass('show');
  $body.addClass('modal-open');
};

const oldComplete = () => {
  const $body = $('body'),
    $backdrop = $('#backdrop-loader'),
    $loader = $('#loader');
  $backdrop.remove();
  $loader.remove();
  if (!$body.hasClass('ignore-modal-close')) {
    $body.removeClass('modal-open');
  }
};

const setCurrentDatepicker = actual_date => {
  const date_in_parts = actual_date.split('/');
  const date = new Date(
    date_in_parts[2],
    date_in_parts[1] - 1,
    date_in_parts[0]
  );

  $('.future-datepicker').datepicker({
    todayHighlight: true,
    orientation: 'auto top',
    format: 'dd/mm/yyyy',
    startDate: new Date(date.getFullYear(), date.getMonth(), 1),
  });
};

const getRemoteData = async url => {
  try {
    const fetchedData = await fetch(url);
    const data = await fetchedData.json();
    return data;
  } catch (error) {
    throw error;
  }
};

const paymentTabsSettings = async (folderId, tabType, component_state) => {
  try {
    const data = await getRemoteData(
      `/folders/${folderId}/installments/payment_tabs_settings.json?tab_type=${tabType}`
    );
    component_state.generalData.date = data.actual_date;
    component_state.generalData.clients = data.clients;
    component_state.generalData.paymentMethods = data.payment_methods;
    component_state.generalData.bankAccounts = data.bank_accounts;
    component_state.generalData.branches = data.branches;
    component_state.generalData.actualDate = data.actual_date;
    component_state.generalData.isEditable = data.disabled;
    component_state.generalData.user = data.user;
    component_state.generalData.showAmount = data.show_amount;
    component_state.generalData.canSetDate = data.set_date;
    component_state.generalData.canNotAddCapitalPayments =
      data.cannot_add_capital_payments;
    component_state.generalData.restructureMessage = data.restructure_message;
    component_state.generalData.isDownPaymentDiffer =
      data.is_down_payment_differ;
    component_state.generalData.canCreateOrUpdatePenalty =
      data.can_create_or_update_penalty;
    component_state.generalData.next = data.next;
    component_state.generalData.concept = data.concept;
    component_state.generalData.nextDate = data.next_date;
    component_state.generalData.isDownPayment = data.is_down_payment;
    component_state.generalData.nextDownPayment = data.next_down_payment;
    component_state.generalData.downPaymentCount = data.down_payment_count;
    component_state.generalData.date = data.actual_date;
    component_state.generalData.adjust = data.total_payments;
    component_state.generalData.clientLabel = data.client.label;
    component_state.client = data.client.id;
    component_state.generalData.canShowForm = data.can_show_form;

    return data;
  } catch (error) {
    throw error;
  }
};

const paymentInstallments = async (folderId, urlParams) => {
  try {
    const data = await getRemoteData(
      `/folders/${folderId}/installments/new_payment.json?${urlParams}`
    );
    return data;
  } catch (error) {
    throw error;
  }
};

const restructureInstallments = async (folderId, urlParams) => {
  try {
    const data = await getRemoteData(
      `/folders/${folderId}/installments/new_restructure.json?${urlParams}`
    );
    return data;
  } catch (error) {
    throw error;
  }
};

const additionalConcepts = async folderId => {
  try {
    const data = await getRemoteData(
      `/folders/${folderId}/installments/new_additional_concept_payment.json`
    );
    return data;
  } catch (error) {
    throw error;
  }
};

const restructureUrlParams = (urlParams, data, tabType) => {
  urlParams.append('tab_type', tabType);
  urlParams.append('next', data.next);
  urlParams.append('next_date', data.next_date);
  urlParams.append('is_down_payment', data.is_down_payment);
  urlParams.append('next_down_payment', data.next_down_payment);
  urlParams.append('down_payment_count', data.down_payment_count);
  urlParams.append('date', data.actual_date);
  urlParams.append('client', data.client.id);
  urlParams.append('payment_method', data.payment_method);
  urlParams.append('bank_account', data.bank_account);
  urlParams.append('branch', data.branch);
  urlParams.append('restructure_type', '');
  urlParams.append('adjust', data.total_payments);
  return urlParams;
};

const validateForm = form => {
  let can_submit = true;
  $(form)
    .find('input, select')
    .each(function(index) {
      const select = $(this);
      if (!select[0].checkValidity()) {
        can_submit = false;
        select.parent().addClass('is-invalid');
      } else {
        if (
          select[0].hasAttribute('data-invalid') &&
          select[0].getAttribute('data-invalid') == 'true'
        ) {
          can_submit = false;
        } else {
          select.parent().removeClass('is-invalid');
        }
      }
    });
  return can_submit;
};

const sendFormData = async (folderId, payload) => {
  oldLoading();
  try {
    const headers = {
      'X-CSRF-Token': Rails.csrfToken(),
      'Content-Type': 'application/json',
    };
    const fetchedData = await fetch(
      `/folders/${folderId}/installments/payment.json`,
      { method: 'POST', body: JSON.stringify(payload), headers }
    );
    const responseData = await fetchedData.json();

    if (responseData.has_warnings) {
      warningMessage(responseData.warning_message);
    } else if (responseData.has_errors) {
      errorMessage(responseData.error_message);
    } else {
      successMessage(responseData.payment_pdf_url, responseData.redirect_url);
    }
  } catch (error) {
    requestError();
  }
};

const warningMessage = message => {
  Swal.fire({
    title: 'Alerta',
    text: message,
    type: 'warning',
    confirmButtonText: 'Continuar',
    footer: 'Verifica nuevamente la información y vuelve a intentarlo..',
  }).then(function() {
    oldComplete();
  });
};

const errorMessage = message => {
  Swal.fire({
    title: 'Error',
    text: message,
    type: 'error',
    confirmButtonText: 'Continuar',
    footer:
      'Espera un momento y vuelve a intentarlo. \n Si el problema persiste comunícate con tu responsable.',
  }).then(function() {
    oldComplete();
  });
};

const successMessage = (payment_pdf_url, redirect_url) => {
  Swal.fire({
    title: '¡Pago guardado con éxito!',
    text: 'Recuerda que el recibo no se podrá generar posteriormente',
    type: 'success',
    showCancelButton: true,
    closeOnCancel: false,
    allowOutsideClick: false,
    cancelButtonText: 'Omitir Descarga',
    confirmButtonText: 'Descargar Recibo',
    customClass: {
      confirmButton: 'btn btn-success',
      cancelButton: 'btn btn-danger ml-2',
    },
    buttonsStyling: false,
  })
    .then(function(isConfirm) {
      if (isConfirm.value) {
        window.location.href = payment_pdf_url;
        return true;
      } else {
        redirectBack(redirect_url);
        return false;
      }
    })
    .then(function(is_downloading) {
      if (is_downloading) {
        Swal.fire({
          title: 'Espera un momento, estamos descargando tu recibo.',
          text: 'Revisa tus descargas antes de continuar',
          type: 'info',
          confirmButtonText: 'Ya guardé mi recibo, continuar.',
        }).then(function() {
          redirectBack(redirect_url);
        });
      }
    });
};

const requestError = () => {
  Swal.fire({
    icon: 'error',
    title: 'Oops...',
    text: 'Hubo un error, por favor inténtalo de nuevo.',
    customClass: {
      confirmButton: 'btn btn-success',
      cancelButton: 'btn btn-danger',
    },
    buttonsStyling: false,
  });
};

const numberToCurrency = number => {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2,
  }).format(number);
};

//Functions with component context
function submitForm(form, payload) {
  if (typeof form === 'undefined') {
    warningMessage('No puede realizar acciones en esta pestaña');
    return;
  }
  if (!validateForm(form)) {
    return;
  }

  if (typeof this.customValidations !== 'function') {
    sendFormData(this.folderId, payload);
    return;
  }

  if (typeof this.customValidations == 'function' && this.customValidations()) {
    sendFormData(this.folderId, payload);
    return;
  }

  return;
}

export {
  initSelect2ForVue,
  oldLoading,
  oldComplete,
  dateFormat,
  setCurrentDatepicker,
  paymentTabsSettings,
  paymentInstallments,
  restructureInstallments,
  restructureUrlParams,
  additionalConcepts,
  submitForm,
  numberToCurrency,
  requestError,
  generalData,
};
