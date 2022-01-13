export default {
  methods: {
    formatMoney(number) {
      if (number == null) {
        return '';
      }
      if (typeof number == 'string') {
        number = parseFloat(number);
      }
      return number.toLocaleString('es-MX', {
        style: 'currency',
        currency: 'MXN',
      });
    },
  },
};
