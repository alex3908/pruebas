<template>
<fragment>
  <div class="form-group col-sm-12 col-md-4">
    <p>Fecha</p>
    <div class="vertical-align">
      <input v-date-picker v-if="generalData.canSetDate" type="text" :value="generalData.actualDate" @changeDatepicker="$emit('inputCashFlowDateEvent',$event.target.value)" name="date" class="form-control datepicker" required="true" readonly="true" :disabled="generalData.isEditable" placeholder="dd/mm/yyyy">
      <b v-else >{{generalData.actualDate}}</b>
      <div class="invalid-feedback">
        Debes seleccionar una fecha
      </div>
    </div>
  </div>

  <div class="form-group col-sm-12 col-md-4">
    <p>Asesor</p>
    <div class="vertical-align">
      <b>{{generalData.user}}</b>
    </div>
  </div>

  <div class="form-group col-sm-12 col-md-4">
    <label>Cliente</label>
    <div class="vertical-align">
      <select v-select2 :id="`client_${tabType}`" class="form-control" required="true" @changeSelect="$emit('selectClientEvent',$event.target.value)" :disabled="generalData.isEditable">
        <option v-for="client in generalData.clients" :key="client.id" :value="client.id">{{client.name}}</option>
      </select>
      <div class="invalid-feedback">
        Debes seleccionar un cliente
      </div>
    </div>
  </div>

  <div v-if="generalData.showAmount" class="form-group col-sm-12 col-md-4">
    <label>Método de Pago</label>
    <div class="vertical-align">
      <select v-select2 :id="`payment_method_${tabType}`" class="form-control" required="true" @changeSelect="$emit('selectPaymentMethodEvent',$event.target.value)" :disabled="generalData.isEditable">
        <option value="">Selecciona un método de pago</option>
        <option v-for="paymentMethod in generalData.paymentMethods" :key="paymentMethod.id" :value="paymentMethod.id">{{paymentMethod.name}}</option>
      </select>
      <div class="invalid-feedback">
        Debes seleccionar un método de pago
      </div>
    </div>
  </div>

  <div v-if="generalData.showAmount" class="form-group col-sm-12 col-md-4">
    <label>Cuenta de Banco</label>
    <div class="vertical-align">
      <select v-select2 :id="`bank_account_${tabType}`" class="form-control" :disabled="generalData.isEditable" @changeSelect="$emit('selectBankAccountsEvent',$event.target.value)">
        <option></option>
        <option v-for="bankAccount in generalData.bankAccounts" :key="bankAccount.id" :value="bankAccount.id">{{bankAccount.name}}</option>
      </select>
      <div class="invalid-feedback">
        Debes seleccionar una cuenta bancaria
      </div>
    </div>
  </div>

  <div class="form-group col-sm-12 col-md-4">
    <label>Sucursal</label>
    <div class="vertical-align">
      <select v-select2 :id="`branch_${tabType}`" class="form-control" required="true" :disabled="generalData.isEditable" @changeSelect="$emit('selectBranchesEvent',$event.target.value)">
        <option value="">Selecciona una sucursal</option>
        <option v-for="branch in generalData.branches" :key="branch.id" :value="branch.id">{{branch.name}}</option>
      </select>
      <div class="invalid-feedback">
        Debes seleccionar una sucursal
      </div>
    </div>
  </div>
</fragment>
</template>
<script>
  import { Fragment } from 'vue-fragment'
  import {initSelect2ForVue} from '../packs/payment-mixins'

  export default {
    components: { Fragment },
    props: ['folderId','tabType','generalData'],
    mounted(){
      initSelect2ForVue(`#client_${this.tabType}`)
      initSelect2ForVue(`#payment_method_${this.tabType}`)
      initSelect2ForVue(`#bank_account_${this.tabType}`)
      initSelect2ForVue(`#branch_${this.tabType}`)
      $('.datepicker').datepicker({
          format: 'dd/mm/yyyy',
      })
    }

  }
</script>