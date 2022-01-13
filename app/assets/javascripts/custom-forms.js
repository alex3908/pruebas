// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
document.addEventListener('vue:mounted', () => {
  $('[data-color]').colorpicker({
    format: 'hex',
  });

  $('[data-color-rgba]').colorpicker({
    format: 'rgba',
  });

  $('[data-activate]').bootstrapToggle();

  const defaultDatePickerSettings = {
    todayHighlight: true,
    orientation: 'auto top',
    format: 'dd/mm/yyyy',
  };

  const datePicker = $('.datepicker');
  if (datePicker.length) {
    datePicker.datepicker({
      ...defaultDatePickerSettings,
      endDate: new Date(),
    });
  }
  const datePickerFuture = $('.datepicker-future');
  if (datePickerFuture.length) {
    $('.datepicker-future').datepicker({
      ...defaultDatePickerSettings,
      startDate: new Date(),
    });
  }

  const datePickerUnlimited = $('.datepicker-unlimited');
  if (datePickerUnlimited.length) {
    $('.datepicker-unlimited').datepicker({
      todayHighlight: true,
      orientation: 'auto top',
      format: 'yyyy-mm-dd',
    });
  }

  const from_date = $('#from_date');
  const to_date = $('#to_date');
  const dateValidation = () => {
    if (from_date[0].value != '') {
      to_date.removeClass('disabled');
    } else {
      to_date.addClass('disabled');
    }
  };
  if (from_date.length && to_date.length) {
    $(document).on('ready', function() {
      dateValidation();
    });
    from_date.on('change', function() {
      dateValidation();
    });
  }

  const pipelineReportDate = $('#pipeline-report-date');
  if (pipelineReportDate.length) {
    pipelineReportDate.datetimepicker({
      format: 'd-m-Y H:i',
      step: 5,
    });
  }
  // Used in quote view
  const folderStartDate = $('#folder-start-date');
  if (folderStartDate.length) {
    folderStartDate.datetimepicker({
      format: 'd/m/Y H:i',
      step: 1,
    });
  }
  const folderApprovedDate = $('#folder-approved-date');
  if (folderApprovedDate.length) {
    folderApprovedDate.datepicker({
      format: 'dd/mm/yyyy',
    });
  }

  $('.datetime-picker').datetimepicker({
    format: 'd/m/Y H:i',
    step: 1,
  });
});
