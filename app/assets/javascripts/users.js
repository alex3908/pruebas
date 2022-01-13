document.addEventListener('vue:mounted', () => {
  $('#user_phone').inputmask({ mask: '(999) 999 9999' });

  const user_file_upload = (button, input) => {
    button.click(() => input.click());
    input.on('change', () => button.addClass('icon-file-uploaded'));
  };
  user_file_upload(
    $('#user_profile .official_identification'),
    $('#user_profile input[name="user[official_identification]"]')
  );
  user_file_upload(
    $('#user_profile .curp'),
    $('#user_profile input[name="user[curp]"]')
  );
  user_file_upload(
    $('#user_profile .address_proof'),
    $('#user_profile input[name="user[address_proof]"]')
  );
  user_file_upload(
    $('#user_profile .rfc'),
    $('#user_profile input[name="user[rfc]"]')
  );
  user_file_upload(
    $('#user_profile .birth_certificate'),
    $('#user_profile input[name="user[birth_certificate]"]')
  );
  user_file_upload(
    $('#user_profile .non_criminal_record'),
    $('#user_profile input[name="user[non_criminal_record]"]')
  );
  user_file_upload(
    $('#user_profile .job_reference'),
    $('#user_profile input[name="user[job_reference]"]')
  );
  user_file_upload(
    $('#user_profile .recommendation_letter_1'),
    $('#user_profile input[name="user[recommendation_letter_1]"]')
  );
  user_file_upload(
    $('#user_profile .recommendation_letter_2'),
    $('#user_profile input[name="user[recommendation_letter_2]"]')
  );

  $('#user_role').on('change', function() {
    const role = $('option:selected', $(this)).val();
    const url = `/roles/${role}/verify_reserve_status`;

    if (role !== '') {
      $.ajax({
        type: 'GET',
        contentType: 'application/json',
        url: url,
        success: function(can_reserve) {
          if (can_reserve) $('#referent_container').removeClass('d-none');
          else $('#referent_container').addClass('d-none');
        },
        error: function() {
          $('#referent_container').addClass('d-none');
        },
      });
    } else {
      $('#referent_container').addClass('d-none');
    }
  });

  $('#user_avatar').on('change', function() {
    readURL(this);
  });
});

function create_structure(structure) {
  const role_select = $('#user_role');
  const role = $('option:selected', role_select).val();
  const level = Number($('option:selected', role_select).data('level'));
  const actual_leader = $('#leader').val();
  const role_type = $('option:selected', role_select).data('type');
  const leader_url = `/users/${role}/leaders`;
  const level_section = $('.level-section');
  const select_leader = $('#user_level');

  if (structure && role === 'salesman') {
    level_section.addClass('d-none');
    select_leader.prop('disabled', true);
  } else {
    level_section.removeClass('d-none');
    select_leader.prop('disabled', false);
  }

  if (role_type === 'evo' && level !== 0) {
    if (actual_leader === '') {
      select_leader.prop('required', false);
    } else {
      select_leader.prop('required', true);
    }

    $.ajax({
      type: 'GET',
      contentType: 'application/json',
      url: leader_url,
      success: function(response) {
        const { levels = [], leader = '' } = response;

        $('label', level_section).text(leader);

        $('#user_level option')
          .remove()
          .trigger('change');

        levels.forEach(level => {
          const leader = new Option(
            `${level.label} (${level.email})`,
            level.id,
            false,
            level.id === parseInt(actual_leader)
          );

          $('#user_level')
            .append(leader)
            .trigger('change');
        });

        if (actual_leader === '') {
          $('#user_level')
            .val(null)
            .trigger('change');
        }
      },
      error: function(data) {},
    });
  } else {
    level_section.addClass('d-none');
    select_leader.prop('disabled', true);
    select_leader.prop('required', false);
  }
}

function select_classifiers() {
  const role_select = $('#user_role');
  const role = $('option:selected', role_select).val();
  const classifier_section = $('.classifier-section');
  const select_classifiers = $('#user_classifier_ids');
  const role_classifiers_url = `/roles/${role}/classifiers`;
  classifier_section.removeClass('d-none');
  select_classifiers.prop('disabled', false);

  $.ajax({
    type: 'GET',
    contentType: 'application/json',
    url: role_classifiers_url,
    success: function(response) {
      $('#user_classifier_ids option')
        .remove()
        .trigger('change');
      const { classifiers = [] } = response;

      classifiers.forEach(c => {
        const classifier = new Option(c.name, c.id, false, false);

        $('#user_classifier_ids')
          .append(classifier)
          .trigger('change');
      });

      $('#user_classifier_ids')
        .val(null)
        .trigger('change');
    },
    error: function(data) {},
  });
}

function readURL(input) {
  if (input.files && input.files[0]) {
    reader = new FileReader();
    reader.onload = e => {
      $('.avatar_preview').css('background-image', `url('${e.target.result}')`);
      $('.child-image').css(
        'background-image',
        `linear-gradient(rgba(255,255,255,0.5), rgba(255,255,255,0.5)), url('${e.target.result}')`
      );
    };

    reader.readAsDataURL(input.files[0]);
  }
}
