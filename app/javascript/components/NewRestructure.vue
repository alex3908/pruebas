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
        <div class="form-group col-sm-12 col-md-4" id="restructure_container">
          <label>Plazo</label>
          <div class="vertical-align">
            <div class="input-group" :class="{'is-invalid': invalidRestructure}">
              <input type="number" ref="months_input" :value="totalPayments" :min="minimumTerm" :max="maximumTerm" @blur="totalPayments = $event.target.value" class="form-control" :data-invalid="invalidRestructure" required="true">
              <div class="input-group-append">
                <div class="input-group-text input-text-right">MESES</div>
              </div>
              <div v-if="invalidRestructure" class="invalid-feedback">
                El plazo mínimo es de {{minTotalPayments}} mensualidades
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
    totalPayments: 0,
    minimumTerm: 0,
    maximumTerm: 0,
    installments: [],
    isEditable: false,
    isLoaded: false,
    invalidRestructure: false,
    minTotalPayments: 0
  }
},
created: async function () {
  oldLoading()
  try {
    const tab_data = await paymentTabsSettings(this.folderId,this.restructureType,this)
    this.totalPayments = tab_data.total_payments
    this.minimumTerm = tab_data.minimum_term 
    this.maximumTerm = tab_data.maximum_term
    restructureUrlParams(urlParams,tab_data,this.restructureType)
    urlParams.set('restructure_type','restructure')
    const installments_data = await restructureInstallments(this.folderId,urlParams)
    this.minTotalPayments = installments_data.min_total_payments
    this.invalidRestructure = installments_data.invalid_restructure
    if(this.invalidRestructure){
      this.minimumTerm = this.totalPayments
    }
    this.installments = installments_data.installments
    this.isLoaded = true
    oldComplete()
  } catch (error) {
    requestError()
  }

},
mounted(){
  this.$emit('loadTab')
},
watch: {
    totalPayments: function (){
      if(this.isLoaded){
        this.updateAmortizationTable()
      }
    }
},
methods: {
  submitForm,
  updateAmortizationTable: async function () {
    oldLoading()
    urlParams.set('branch',this.branch)
    urlParams.set('adjust',this.totalPayments)
    try {      
      const installments_data = await restructureInstallments(this.folderId,urlParams)
      this.minTotalPayments = installments_data.min_total_payments
      this.invalidRestructure = installments_data.invalid_restructure
      this.installments = installments_data.installments
      oldComplete()
    } catch (error) {
      requestError()
    }
  },
  customValidations(){
    const valid_form = this.maximumTerm !== this.totalPayments
    return valid_form 
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
    restructure_type: 'restructure',
    branch: this.branch,
    adjust: this.totalPayments}
  }
}
}


</script>