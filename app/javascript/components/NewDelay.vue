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
        @selectBranchesEvent="branch = $event"
        />

        <div class="form-group col-sm-12 col-md-4">
          <label>Tipo de prórroga</label>
          <div class="vertical-align">
            <div class="input-group">
              <select v-select2 id="restructure_type_new_delay" required="true" class="form-control" :disabled="isEditable" @changeSelect="delayType = $event.target.value">
                    <option value="">Selecciona un cuenta bancaria</option>
                    <option v-for="delayConcepts in delayConcepts" :key="delayConcepts.delay_type" :value="delayConcepts.delay_type">{{delayConcepts.label}}</option>
                </select>
              <div class="invalid-feedback">
                Ingresa el tipo de abono a capital
              </div>
            </div>
          </div>
        </div>

        <div class="form-group col-sm-12 col-md-4" id="delay_container">
          <label>Meses a prorrogar</label>
          <div class="vertical-align">
            <div class="input-group" :class="{'is-invalid': invalidDelay}">
              <input type="number" value="" min="0" :max="maxDelayPayments" @blur="delayMonths = $event.target.value" class="form-control" required="true"/>
              <div class="input-group-append">
                <div class="input-group-text input-text-right">MESES</div>
              </div>
              <div v-if="invalidDelay" class="invalid-feedback">
                La prórroga máxima es de {{maxDelayPayments}} mes(es)
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
import {paymentTabsSettings, restructureInstallments, submitForm, generalData, restructureUrlParams, oldLoading, oldComplete, requestError} from '../packs/payment-mixins'
let urlParams = new URLSearchParams()

export default {
components: { GeneralInputs, PendingPayments },
props:["folderId","restructureType"],
data() {
  return {
    generalData: {...generalData},
    client: '',
    branch: '',
    delayType: '',
    delayConcepts: [],
    installments: [],
    isEditable: false,
    maxDelayPayments: 0,
    delayMonths: 0,
    isLoaded: false,
    invalidDelay: false
  }
},
created: async function () {
  try {
    oldLoading()
    const tab_data = await paymentTabsSettings(this.folderId,this.restructureType,this)
    this.capitalPaymentConcepts = tab_data.capital_payment_concepts
    this.maxDelayPayments = tab_data.max_delay_payments
    this.delayConcepts = tab_data.delay_concepts
    restructureUrlParams(urlParams,tab_data,this.restructureType)
    urlParams.set('delay_months',this.delayMonths)
    const installments_data = await restructureInstallments(this.folderId,urlParams)
    this.invalidDelay = installments_data.invalid_delay
    this.installments = installments_data.installments
    this.isLoaded = true
    oldComplete()
  } catch (error) {
    requestError()
  }
},
mounted(){
  this.$emit('loadTab')
  initSelect2("#restructure_type_new_delay")
},
watch: {
    delayMonths: function () {
      if(this.isLoaded){
        this.updateAmortizationTable()
      }
    },
    delayType: function () {
      if(this.isLoaded){
        this.updateAmortizationTable()
      }
    }
},
methods: {
  submitForm,
  updateAmortizationTable: async function(){
    oldLoading()
    urlParams.set('restructure_type',this.delayType)
    urlParams.set('delay_months',this.delayMonths)
    try {
      const installments_data = await restructureInstallments(this.folderId,urlParams)
      this.invalidDelay = installments_data.invalid_delay
      this.installments = installments_data.installments
      this.isLoaded = true
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
    restructure_type: this.delayType,
    branch: this.branch,
    adjust: this.generalData.adjust,
    delay_months: this.delayMonths}
  }
}
}


</script>