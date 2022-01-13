<template>
  <tr>
    <td>
      {{ number }}
    </td>
    <td>
        <input type="date" :value="date" v-on:change="changeDate" placeholder="YYYY--MM-DD" name="date" class="form-control" :class="valid_date ? '' : 'is-invalid'"/>
        <small class="text-danger" v-if="!valid_date">
          Fecha requerida
        </small>  
    </td>
    <td>

        <input class="form-control" :value="formatMoney(capital)" :class="valid_capital ? '' : 'is-invalid'" v-on:change="changeAmount" v-currency="{
                locale: 'en',
                currency: 'USD',
                valueAsInteger: false,
                distractionFree: true,
                precision: 2,
                autoDecimalMode: false,
                valueRange: { min: 0 },
                allowNegative: false
              }"/>

      <small class="text-danger" v-if="!valid_capital">
        El valor debe ser mayor o igual a 1
      </small>  

    </td>
    <td>
      {{ formatMoney(interest) }}
    </td>
    <td>
      {{ formatMoney(total) }}
    </td>
    <td>
      {{ formatMoney(debt) }}
    </td>
    <td>
      <button type="button" class="button-icon" v-on:click="deleteInstallment(index)" title="Eliminar letra">
        <i class="fa fa-trash-o icon-red"></i>
      </button>
    </td>
  </tr>
</template>
<script>
import Utilities from '../../mixins/utilities';

export default {
  props: ["id", "number", "date", "capital", "interest", "total", "debt", "idx", "valid_date", "valid_capital"],
  mixins: [Utilities],
  data() {
    return {
      amountCapital: this.capital,
      newDate: this.date,
      index: this.idx
    }
  },
  methods: {
    deleteInstallment: function(index) {
      this.$emit('removeInstallment', this.index );
    },
    changeAmount: function(event) {
      const amount = this.removeFormatAmount(event.target.value);
      this.amountCapital = amount;
      this.$emit('installmentChanged', { capital: this.amountCapital, date: this.newDate, index: this.index}  );
    },
    changeDate: function(event) {
      const date = event.target.value;
      this.newDate = date;
      this.$emit('installmentChanged', { capital: this.amountCapital, date: this.newDate, index: this.index}  );
    },
    removeFormatAmount: function (value) {
      return Number(value.replace('$', '').replace(',', ''));
    }

  }  
};
</script>