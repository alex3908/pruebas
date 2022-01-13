<template>
<div>
  <form ref="form" class="background-white pt-3">

    <h3 v-if="generalData.canNotAddCapitalPayments" class="text-center m-0">{{generalData.restructureMessage}}</h3>
    <h3 v-else-if="generalData.hasActiveSuscriptions" class="text-center">No puede realizar reestructuras con suscripciones activas.</h3>
    <section v-else class="restructure-payment">
      <div class="row">
        <general-inputs 
        :folder-id="folderId" 
        :tab-type="restructureType" 
        :general-data="generalData"
        @inputCashFlowDateEvent="generalData.date = $event"
        @selectClientEvent="client = $event" 
        @selectPaymentMethodEvent="paymentMethod = $event" 
        @selectBankAccountsEvent="bankAccount = $event"
        @selectBranchesEvent="branch = $event"

        />

        <div class="form-group col-sm-12 col-md-4">
          <label>Tipo de reestructuración</label>
          <div class="vertical-align">
            <div class="input-group">
                <select v-select2 id="restructure_type_new_capital" required="true" class="form-control" @changeSelect="restructureTypeField = $event.target.value">
                    <option></option>
                    <option v-for="capitalPaymentConcept in capitalPaymentConcepts" :key="capitalPaymentConcept.restructure_concept" :value="capitalPaymentConcept.restructure_concept">{{capitalPaymentConcept.label}}</option>
                </select>
                <div class="invalid-feedback">
                    Ingresa el tipo de abono a capital
                </div>
            </div>
          </div>
        </div>

        <div class="form-group col-sm-12 col-md-4" id="capital_amount_container">
          <label>Importe a aplicar</label>
          <div class="vertical-align">
            <div class="input-group" :class="{'is-invalid': invalidCapitalPayment}">
              <div class="input-group-prepend">
                <span class="input-group-text">$</span>
              </div>
              <input type="number" :value="amount" :min="0" :step="0.01" class="form-control input-with-error-message" required="true" :disabled="isDisabled" @blur="amount = $event.target.value">
              <div v-if="invalidCapitalPayment" class="invalid-feedback">
                El monto minimo de abono a capital es de {{numberToCurrency(minCapitalPayment)}}
              </div>
            </div>
          </div>
        </div>

      </div>
      
    </section>
  </form>
    <pending-payments 
    :installments="installments" 
    :is-down-payment-differ="generalData.isDownPaymentDiffer" 
    :can-create-or-update-penalty="generalData.canCreateOrUpdatePenalty"/>
</div>
</template>
<script>

import GeneralInputs from './GeneralInputs.vue'
import PendingPayments from './PendingPayments.vue'
import {paymentTabsSettings, restructureInstallments, restructureUrlParams, submitForm, generalData, numberToCurrency, oldLoading, oldComplete, requestError} from '../packs/payment-mixins'

let urlParams = new URLSearchParams()

export default {
components: { GeneralInputs, PendingPayments},
props:["folderId","restructureType"],
data() {
  return {
    generalData: {...generalData},
    client:"",
    paymentMethod: "",
    bankAccount: "",
    branch: "",
    amount:0,
    restructureTypeField: "",
    capitalPaymentConcepts: [],
    minCapitalPayment: 0,
    installments: [],
    isEditable: false,
    isLoaded: false,
    invalidCapitalPayment: false
  }
},
created: async function() {
  oldLoading()
  try {
    const tab_data = await paymentTabsSettings(this.folderId,this.restructureType,this)
    this.minCapitalPayment = tab_data.min_capital_payment
    urlParams.set('restructure_type','financing_monthly')
    const installments_data = await restructureInstallments(this.folderId,restructureUrlParams(urlParams,tab_data,this.restructureType))
    this.invalidCapitalPayment = installments_data.invalid_capital_payment
    this.capitalPaymentConcepts = installments_data.capital_payment_concepts
    this.installments = installments_data.installments
    this.isLoaded = true
    oldComplete()
  } catch (error) {
    requestError()
  }

},
mounted(){
  this.$emit('loadTab')
  initSelect2("#restructure_type_new_capital")
  $('#save').prop('disabled',false)
},
watch: {
    paymentMethod: function () {
      if(this.isLoaded){
        this.updateAmortizationTable()
      }
    },
    restructureTypeField: function (val) {
      if(this.isLoaded && val !== ""){
        this.updateAmortizationTable()
      }
    },
    amount: function () {
      if(this.isLoaded){
        this.updateAmortizationTable()
      }
    }
},
computed: {
  isDisabled: function(){
    return this.restructureTypeField == ""
  }
},
methods: {
  numberToCurrency,
  submitForm,
  updateAmortizationTable: async function(){
    oldLoading()
    urlParams.set('payment_method',this.paymentMethod)
    urlParams.set('bank_account',this.bankAccount)
    urlParams.set('branch',this.branch)
    urlParams.set('restructure_type',this.restructureTypeField)
    urlParams.set('amount',this.amount)
    try {
      const installments_data = await restructureInstallments(this.folderId,urlParams)
      this.invalidCapitalPayment = installments_data.invalid_capital_payment
      if(installments_data.has_multiple){
        this.generalData.next = installments_data.next_multiple_installment
        this.generalData.concept = installments_data.next_multiple_concept
      }
      this.installments = installments_data.installments
      oldComplete()
    } catch (error) {
      requestError()
    }
  },
  getPayload(){
    return {
    date: this.generalData.date,
    next: this.generalData.next, 
    concept: this.generalData.concept, 
    next_date: this.generalData.nextDate, 
    is_down_payment: this.generalData.isDownPayment , 
    next_down_payment: this.generalData.nextDownPayment, 
    down_payment_count: this.generalData.downPaymentCount , 
    date: this.generalData.date, 
    client: this.client, 
    payment_method: this.paymentMethod, 
    bank_account: this.bankAccount,
    branch: this.branch,
    restructure_type: this.restructureTypeField,
    adjust: this.generalData.adjust,
    amount:this.amount}
  }
}
}


</script>