<template>
<section class="payments w-100">
  <div class="d-flex flex-wrap justify-content-between">
    <h3 class="text-left vertical-align m-0 py-3">Por Pagar</h3>
  </div>
  <div class="row mb-3">
    <div class="col-4 pr-0">
      <hr class="marker-bar-green">
    </div>
    <div class="col-8 pl-0">
      <hr class="marker-bar-gray">
    </div>
  </div>

  <div class="table-container">
    <table class="table table-striped tablesaw tablesaw-stack" data-tablesaw-mode="stack">
      <thead>
      <tr>
        <th scope="col"></th>
        <th scope="col">Número de pago</th>
        <th scope="col">Fecha</th>
        <th scope="col">Capital</th>
        <th scope="col">Actualización</th>
        <th v-if="isDownPaymentDiffer" scope="col">Enganche</th>
        <th scope="col">Total a pagar</th>
        <th scope="col">Saldo pendiente</th>
        <th scope="col">Saldo Capital</th>
        <th v-if="canCreateOrUpdatePenalty"></th>
      </tr>
      </thead>

      <tbody>
        <tr v-for="(installment,index) in installments" :key="index">
          <td :class="`align-middle ${installment.row_color}`">
            <div class="text-center" style="white-space: pre-line;" :data-tooltip="`${installment.status_message} \n ${installment.overdue_days}`">
              <i class="fa fa-info-circle"></i>
            </div>
          </td>
          <td class="align-middle">{{installment.number}}</td>
          <td class="align-middle">{{installment.date}}</td>
          <td class="align-middle">{{numberToCurrency(installment.capital)}}</td>
          <td class="align-middle">{{numberToCurrency(installment.interest)}}</td>
          <td v-if="isDownPaymentDiffer" class="align-middle">{{numberToCurrency(installment.down_payment)}}</td>
          <td class="align-middle">{{numberToCurrency(installment.payment)}}
            <small v-if="installment.has_penalty" class="text-danger"><br>{{numberToCurrency(installment.penalty)}}</small>
          </td>
          <td class="align-middle">{{numberToCurrency(installment.residue)}}</td>
          <td class="align-middle">{{installment.amount == null ? "" : numberToCurrency(installment.amount)}}</td>
          <td class="align-middle">
            <a v-if="installment.can_show_new_folder_installment && installment.can_add_penalty && canCreateOrUpdatePenalty" class="table-link" data-remote="true" data-method="get" :href="installment.add_penalty_url">
              <i class="fa fa-plus"></i>
            </a>
            
            <a v-if="installment.can_show_folder_installment_penalties && installment.can_add_penalty && canCreateOrUpdatePenalty" 
            class="table-link" 
            :data-confirm="`¿Deseas remover la penalización del pago ${installment.number}?`" 
            data-remote="true" 
            rel="nofollow" 
            data-method="patch"
            :href="installment.remove_penalty_url">
              <i class="fa fa-ban"></i>
            </a>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</section>
</template>
<script>
import {oldComplete} from '../packs/payment-mixins'

export default {
props:["installments","isDownPaymentDiffer","canCreateOrUpdatePenalty"],
methods: {
  numberToCurrency(number){
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN',
      minimumFractionDigits: 2
    }).format(number)
  }
}
}
</script>