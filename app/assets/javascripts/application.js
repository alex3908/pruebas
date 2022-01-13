// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require turbolinks
//= require activestorage
//= require jquery
//= require jquery_ujs
//= require jquery-ui-sortable-npm/jquery-ui-sortable.js
//= require rails_sortable
//= require popper
//= require bootstrap/dist/js/bootstrap.js
//= require bootstrap-datepicker
//= require bootstrap-datepicker/locales/bootstrap-datepicker.es.js
//= require bootstrap-colorpicker/dist/js/bootstrap-colorpicker.min.js
//= require bootstrap4-toggle/js/bootstrap4-toggle.js
//= require tablesaw/dist/tablesaw.jquery.js
//= require tablesaw/dist/tablesaw-init.js
//= require select2
//= require inputmask/dist/jquery.inputmask.js
//= require clabe-validator/dist/clabe.js
//= require intl-tel-input
//= require jquery-datetimepicker/build/jquery.datetimepicker.full.js
//= require chartkick
//= require Chart.bundle
//= require sweetalert2/dist/sweetalert2.js
//= require cocoon

//= require ./bank_accounts
//= require ./client
//= require ./commissions
//= require ./custom-forms
//= require ./data-confirm
//= require ./data-remote
//= require ./documents
//= require ./enterprises
//= require ./folders
//= require ./functions
//= require ./lots
//= require ./payment_gateway
//= require ./payment_methods
//= require ./payments
//= require ./promotions
//= require ./quotation
//= require ./quote
//= require ./settings
//= require ./stages
//= require ./steps
//= require ./users
//= require ./automated_emails
//= require ./credits
//= require ./digital_signature_services
//= require ./addresses
//= require ./reports
//= require ./credit_schemes
//= require ./file_approvals

document.addEventListener('vue:mounted', () => {
  jQuery.datetimepicker.setLocale('es');
  $('#show-sidebar').on('click', function() {
    $('.page-wrapper').toggleClass('toggled');
  });
  $('#close-sidebar').on('click', function() {
    $('.page-wrapper').toggleClass('toggled');
  });

  Tablesaw.init();
  $('[data-toggle="tooltip"]').tooltip();

  $('[data-provide="datepicker"]').datepicker({
    format: 'dd/mm/yyyy',
  });

  $('select:not(.not-select2)').each(function() {
    initSelect2(this);
  });

  $(() => $('.sortable').railsSortable());
});

$(document).on('turbolinks:before-cache', function() {
  $('select').each(function() {
    const $this = $(this);
    if ($this.data('select2') != undefined) {
      $this.select2('destroy');
    }
  });
});

const initSelect2 = element_id => {
  const parent = $(element_id).parent();

  var placeholder;
  if ($(element_id).attr('placeholder') !== undefined) {
    placeholder = $(element_id).attr('placeholder');
  } else {
    placeholder = 'Seleccione un elemento';
  }

  $(element_id).select2({
    placeholder: placeholder,
    allowClear: true,
    width: '100%',
    dropdownParent: parent,
  });
};

const initPhoneMask = element_id => {
  $(element_id).inputmask({
    mask: '(999) 999 9999',
  });
};

const initToggle = element_id => {
  $(element_id).bootstrapToggle();
};

const initDatePicker = element_id => {
  $(element_id).datepicker({
    todayHighlight: true,
    orientation: 'auto top',
    format: 'yyyy-mm-dd',
  });
};

const showHideLoading = (show = true) => {
  if (show) {
    const $body = $('body'),
      $backdrop = $("<div id='backdrop-loader' class='modal-backdrop'></div>"),
      $loader = $(`<div id="loader" class="modal fade" style="display: block;">
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
  } else {
    const $body = $('body'),
      $backdrop = $('#backdrop-loader'),
      $loader = $('#loader');
    $backdrop.remove();
    $loader.remove();
    if (!$body.hasClass('ignore-modal-close')) {
      $body.removeClass('modal-open');
    }
  }
};

function setCurrentDatepicker(actual_date) {
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
}
