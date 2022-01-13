/* eslint no-console: 0 */
// Run this example by adding <%= javascript_pack_tag 'hello_vue' %> (and
// <%= stylesheet_pack_tag 'hello_vue' %> if you have styles in your component)

import Vue from 'vue/dist/vue.esm';
import { BootstrapVue } from 'bootstrap-vue';
import VueCurrencyInput from 'vue-currency-input';
import VueCookies from 'vue-cookies';
import Select2 from 'v-select2-component-reloaded';
import VueClipboard from 'vue-clipboard2';
import vueAwesomeCountdown from 'vue-awesome-countdown';

// Import Components
import Notifications from '../components/notifications';
import PipelineColumn from '../components/pipeline-column';
import FolderCard from '../components/folder-card';
import CommissionSchemesRole from '../components/commission-schemes-role';
import Avatar from 'vue-avatar';
import Payments from '../components/Payments';
import CustomInstallments from '../components/installments/custom-installments';
import TableInstallments from '../components/installments/table-installments';
import RowInstallment from '../components/installments/row-installment';
import PaymentGateways from '../components/payment-gateways';
import ClientUsers from '../components/client-users';
import ReferenceContacts from '../components/reference-contacts';

import ReferredCustomers from '../components/ReferredCustomers';
import SignLinks from '../components/sign-links';

// Middleware
VueClipboard.config.autoSetContainer = true; // add this line

Vue.use(VueCookies);
Vue.use(VueClipboard);
Vue.use(vueAwesomeCountdown, 'vac');

// Include Components
Vue.component('notifications', Notifications);
Vue.component('pipeline-column', PipelineColumn);
Vue.component('folder-card', FolderCard);
Vue.component('custom-installments', CustomInstallments);
Vue.component('table-installments', TableInstallments);
Vue.component('row-installment', RowInstallment);
Vue.component('avatar', Avatar);
Vue.component('commission-schemes-role', CommissionSchemesRole);
Vue.component('payments', Payments);
Vue.component('payment-gateways', PaymentGateways);
Vue.component('client-users', ClientUsers);
Vue.component('reference-contacts', ReferenceContacts);

Vue.component('referred-customers', ReferredCustomers);
Vue.component('select-2', Select2);
Vue.component('sign-links', SignLinks);

Vue.directive('select2', {
  inserted(el) {
    $(el).on('change', () => {
      const event = new Event('changeSelect');
      el.dispatchEvent(event);
    });
  },
});

Vue.directive('date-picker', {
  inserted(el) {
    $(el).on('change', () => {
      const event = new Event('changeDatepicker');
      el.dispatchEvent(event);
    });
  },
});

Vue.use(BootstrapVue);
Vue.use(VueCurrencyInput);

Vue.mixin({
  methods: {
    validEmail: function(email) {
      const email_exp = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      return email_exp.test(email);
    },
    openModal: function(modalId, data) {
      this.$root.$emit(modalId, data);
    },
  },
});

document.addEventListener('turbolinks:load', () => {
  const app = new Vue({
    el: '[data-behavior="vue"]',
    mounted: () => {
      document.dispatchEvent(new CustomEvent('vue:mounted', {}));
    },
  });
});
