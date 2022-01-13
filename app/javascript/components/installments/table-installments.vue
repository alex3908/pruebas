<style scoped>

</style>
<template>
  <div class="row">
    <div class="col-md-12">
      <div class="table-container">
        <table
          class="table table-striped tablesaw tablesaw-stack"
          data-tablesaw-mode="stack"
        >
          <thead>
            <tr>
              <th scope="col">Número de pago</th>
              <th scope="col">Fecha</th>
              <th scope="col">Capital</th>
              <th scope="col">Actualización</th>
              <th scope="col">Total a pagar</th>
              <th scope="col">Saldo Capital</th>
              <th scope="col"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="this.installments.length === 0">
              <td colspan="7" class="text-center">
                Sin cuotas personalizadas.
              </td>
            </tr>
            <row-installment @installmentChanged="updateInstallment" @removeInstallment="removeInstallment" v-else v-for="(installment, index) of this.installments" v-bind="installment" v-bind:key="index" :idx="index"></row-installment>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
import Utilities from '../../mixins/utilities';
export default {
  mixins: [Utilities],
  props: ["installments"],
  methods: {
    updateInstallment: function (installmment) {
     this.$emit('updateInstallments', installmment);
    },
    removeInstallment: function (index) {
      this.$emit('removeInstallment', index);
    }
  },
  
};
</script>