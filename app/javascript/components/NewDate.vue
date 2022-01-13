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

        <div class="form-group col-sm-12 col-md-4" id="date_container">
          <label>Nueva fecha</label>
          <div class="vertical-align">
            <div class="input-group" :class="{'is-invalid': invalidDayRestructure}">
                <input v-date-picker type="text" :value="nextDate" class="form-control future-datepicker" @changeDatepicker="newDate = $event.target.value" placeholder="dd/mm/yyyy"/>
              <div class="input-group-append">
                <span class="input-group-text">
                  <i class="fa fa-calendar-o" aria-hidden="true"></i>
                </span>
              </div>
              <div v-if="invalidDayRestructure" class="invalid-feedback">
                {{dayMessage}}
              </div>
              <div v-else class="invalid-feedback">
                Debes saldar la mensualidad actual para poder elegir una fecha menor

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
import {paymentTabsSettings, restructureInstallments, submitForm, generalData, restructureUrlParams, oldLoading, oldComplete, setCurrentDatepicker, requestError} from '../packs/payment-mixins'
let urlParams = new URLSearchParams()

export default {
components: { GeneralInputs, PendingPayments },
props:["folderId","restructureType"],
data() {
  return {
    generalData: {...generalData},
    client: '',
    branch: '',
    installments: [],
    isEditable: false,
    nextDate: null,
    newDate: null,
    isLoaded: false,
    invalidDayRestructure: false,
    dayMessage: ''
  }
},
created: async function () {
  oldLoading()
  const tab_data = await paymentTabsSettings(this.folderId,this.restructureType,this)
  this.nextDate = tab_data.next_date
  if(this.restructureType == "new_date"){
    setCurrentDatepicker(this.nextDate)
  }
  restructureUrlParams(urlParams,tab_data,this.restructureType)
  urlParams.set('restructure_type','day')
  urlParams.set('new_date',this.nextDate)
  try {
    const installments_data = await restructureInstallments(this.folderId,urlParams)
    this.dayMessage = installments_data.day_message
    this.invalidDayRestructure = installments_data.invalid_day_restructure
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
    newDate: function (value) {
      if(this.isLoaded){
        this.nextDate = value
        this.updateAmortizationTable()
      }
    }
},
methods: {
  submitForm,
  updateAmortizationTable: async function (){      
    oldLoading()
    urlParams.set('branch',this.branch)
    urlParams.set('new_date',this.newDate)
    try {
      const installments_data = await restructureInstallments(this.folderId,urlParams)
      this.dayMessage = installments_data.day_message
      this.invalidDayRestructure = installments_data.invalid_day_restructure
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
    restructure_type: 'day',
    branch: this.branch,
    new_date: this.newDate}
  }
}
}


</script>