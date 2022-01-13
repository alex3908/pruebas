module.exports = {
  methods: {
    addToArrayCookie: function(name, value) {
      if (this.$cookies.isKey(name)) {
        var cookieValue = this.$cookies.get(name);
        cookieValue = cookieValue.split(',');
        cookieValue.push(value);
        this.$cookies.set(name, cookieValue);
      } else {
        this.$cookies.set(name, [value]);
      }
    },
    getArrayCookie: function(name) {
      if (this.$cookies.isKey(name)) {
        return this.$cookies.get(name).split(',');
      } else {
        return [];
      }
    },
  },
};
