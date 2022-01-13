import { Controller } from 'stimulus';
import autocomplete from 'autocomplete.js';
import { number, object } from 'yup';
import axios from 'axios';
import qs from 'qs';
export default class extends Controller {
  static targets = ['field', 'hidden'];

  source() {
    const url = this.data.get('url');
    return (query, callback) => {
      let qsg = '';
      const dynamic_params = this.jsonConvert(
        JSON.parse(this.data.get('dynamic-params'))
      );

      if (dynamic_params) {
        qsg = `${qs.stringify(dynamic_params)}&`;
      }

      axios
        .get(
          `${url}.json?${qsg}${this.data
            .get('search')
            .replace(/\=/g, `=${this.fieldTarget.value}`)}`
        )
        .then(response => {
          callback(response.data);
        });
    };
  }

  connect() {
    this.ac = autocomplete(this.fieldTarget, { hint: false }, [
      {
        source: this.source(),
        debounce: 200,
        templates: {
          suggestion: function(suggestion) {
            const { id, value } = suggestion;
            return value;
          },
        },
      },
    ]).on('autocomplete:selected', (event, suggestion, dataset, context) => {
      const { id, value } = suggestion;
      this.ac.autocomplete.setVal(`${value}`);
      this.hiddenTarget.value = id;
    });
  }

  async validateAutocomplete(event) {
    const hidden_value = parseInt(this.hiddenTarget.value);
    const schema = object().shape({
      client_id: number().required('El campo es requerido'),
    });

    try {
      let valid = await schema.validate({
        client_id: isNaN(hidden_value) ? undefined : hidden_value,
      });
      return valid;
    } catch (err) {
      event.preventDefault();
      event.stopImmediatePropagation();
      Swal.fire({
        title: '¡Advertencia!',
        text: `${err.errors}`,
        type: 'warning',
        confirmButtonText: 'Ok',
      });
      return false;
    }
  }

  jsonConvert(json_string) {
    try {
      return JSON.parse(json_string);
    } catch (error) {
      return '';
    }
  }
}
