<template>
<div>
  <form ref="form" class="background-white pt-3">
    <section class="new-additional-concept-payment">
        <div class="row">
            <general-inputs 
            :folder-id="folderId" 
            :tab-type="'new_additional_concept_payment'" 
            :general-data="generalData"
            @inputCashFlowDateEvent="generalData.date = $event"
            @selectClientEvent="client = $event" 
            @selectPaymentMethodEvent="paymentMethod = $event" 
            @selectBankAccountsEvent="bankAccount = $event"
            @selectBranchesEvent="branch = $event"

            
            />
            <div class="form-group col-sm-12 col-md-4">
                <label>Servicio</label>
                <div class="vertical-align">
                    <select id="additional_concept" v-select2 class="form-control" @changeSelect="additionalConcept = $event.target.value" required="true">
                        <option></option>
                        <option v-for="additionalConceptOption in additionalConceptOptions" :key="additionalConceptOption.id" :value="additionalConceptOption.id">{{additionalConceptOption.name}}</option>
                    </select>
                    <div class="invalid-feedback">
                        Debes seleccionar un servicio
                    </div>
                </div>
            </div>
            <div class="form-group col-sm-12 col-md-4">
                <label>Cantidad</label>
                <div class="input-group">
                    <div class="input-group-prepend">
                        <span class="input-group-text">$</span>
                    </div>
                    <input type="number" :value="amount" min="0" step="0.01" @blur="amount = $event.target.value" class="form-control input-with-error-message"/>
                </div>
                <p class="m-2" id="amount-legend"><em>Monto sugerido:</em> <strong><em>{{numberToCurrency(suggestedAmount)}}</em></strong></p>
            </div>
        </div>
    </section>
  </form>

  <pending-concepts :additional-concept-payments="additionalConceptsPayments" /> 
</div>
</template>
<script>
import GeneralInputs from './GeneralInputs.vue'
import PendingConcepts from './PendingConcepts.vue'
import {paymentTabsSettings, additionalConcepts, submitForm,generalData,oldLoading, oldComplete, numberToCurrency} from '../packs/payment-mixins'

let urlParams = new URLSearchParams()

export default {
components: { GeneralInputs, PendingConcepts },
props:["folderId"],
data() {
  return {
    generalData: {...generalData},
    client:"",
    paymentMethod: "",
    bankAccount: "",
    branch: "",
    isEditable: false,
    additionalConcept: '',
    suggestedAmount: 0,
    amount: 0,
    additionalConceptOptions: [],
    additionalConceptsPayments: [],
    isLoaded: false
  }
},
created: async function() {
  try {
    oldLoading()
    const tab_data = await paymentTabsSettings(this.folderId,"new_additional_concept_payment",this)
    this.additionalConceptOptions = tab_data.additional_concept_options
    const additional_concepts_data = await additionalConcepts(this.folderId)
    this.additionalConceptsPayments = additional_concepts_data.additional_concepts_payments
    this.isLoaded = true
    oldComplete()
  } catch (error) {
    requestError()
  }
},
mounted(){
  this.$emit('loadTab')
  initSelect2("#additional_concept")
},
watch: {
    additionalConcept: function (val) {
      if(this.isLoaded){
        const selected_amount = this.additionalConceptOptions.find(concept => concept.id === parseInt(val))
        if(selected_amount){
          this.suggestedAmount = parseFloat(selected_amount.amount)
          this.amount = parseFloat(selected_amount.amount)
        }else{
          this.suggestedAmount = 0
          this.amount = 0
        }

      }
    }
},
methods: {
  submitForm,
  numberToCurrency,
  getPayload(){
    return {
    date: this.generalData.date,
    next: this.generalData.next, 
    next_date: this.generalData.nextDate, 
    is_down_payment: this.generalData.isDownPayment , 
    next_down_payment: this.generalData.nextDownPayment, 
    down_payment_count: this.generalData.downPaymentCount , 
    date: this.generalData.date, 
    client: this.client, 
    payment_method: this.paymentMethod, 
    bank_account: this.bankAccount,
    branch: this.branch,
    additional_concept: this.additionalConcept, 
    amount:this.amount}
  }
}
}

</script>