<template>
<div>
  <h3 class="text-center" v-if="!hasPendingInstallments">Pagos finalizados</h3>
  <form v-else-if="generalData.canShowForm" ref="form" class="background-white pt-3" >
    <section class="new-payment">
      <div class="row">
        
        <general-inputs 
        :folder-id="folderId"
        :tab-type="'new_payment'" 
        :general-data="generalData"
        @inputCashFlowDateEvent="generalData.date = $event"
        @selectClientEvent="client = $event" 
        @selectPaymentMethodEvent="paymentMethod = $event" 
        @selectBankAccountsEvent="bankAccount = $event"
        @selectBranchesEvent="branch = $event"
        />

        <div class="form-group col-sm-6 col-md-3">
          <label>Cantidad</label>
          <div class="input-group">
            <div class="input-group-prepend">
              <span class="input-group-text">$</span>
            </div>
            <input type="number" min="0.01" :max="hasBonusResidue ? bonusResidue : totalResidue" step="0.01" @input="amount = $event.target.value" class="form-control input-with-error-message" required="true"/>
            <div class="invalid-feedback">
              El saldo pendiente es de {{numberToCurrency(hasBonusResidue ? bonusResidue : totalResidue)}}
            </div>
          </div>
        </div>

        <div class="form-group col-sm-6 col-md-3">
          <p>Próxima letra</p>
          <div class="vertical-align">
            <b class="text-capitalize">{{nextInstallmentIsDownPayment ? "enganche" : "parcialidad" }} {{nexInstallmentNumber}}</b>
          </div>
        </div>

        <div class="form-group col-sm-6 col-md-3">
          <p>Saldo Total</p>
          <div class="vertical-align">
            <b>{{numberToCurrency(totalResidue)}}</b>
          </div>
        </div>

        <div v-if="amountOverdue > 0" class="form-group col-sm-6 col-md-3">
          <p>Saldo Vencido</p>
          <div class="vertical-align">
          <b>{{numberToCurrency(amountOverdue)}}</b>
          </div>
        </div>

        <div v-if="hasBonusResidue" class="form-group col-sm-6 col-md-3">
          <p class="m-0">Bonificación Disponible<br><em>{{generalData.clientLabel}}</em></p>
          <div class="vertical-align"><b>{{numberToCurrency(cashBackAvailable)}}</b></div>
        </div>
      </div>
    </section>
  </form>

  <pending-payments 
    :installments="installments" 
    :is-down-payment-differ="generalData.isDownPaymentDiffer" 
    :can-create-or-update-penalty="generalData.canCreateOrUpdatePenalty && hasPendingInstallments"
    />
</div>
</template>
<script>
import GeneralInputs from './GeneralInputs.vue'
import PendingPayments from './PendingPayments.vue'
import {paymentTabsSettings, paymentInstallments, submitForm, generalData, numberToCurrency, oldLoading, oldComplete, requestError} from '../packs/payment-mixins'

let urlParams = new URLSearchParams()

export default {
components: { GeneralInputs, PendingPayments },
props:["folderId", "hasPendingInstallments"],
data() {
  return {
    generalData:{...generalData},
    client: '',
    paymentMethod: '',
    bankAccount: '',
    branch: '',
    amount: 0,
    totalResidue: 0,
    nextInstallmentIsDownPayment: false,
    nexInstallmentNumber: 0,
    amountOverdue: 0,
    installments: [],
    hasBonusResidue: false,
    cashBackAvailable: 0,
    isLoaded: false,
    bonusResidue: 0
  }
},
created: async function(){
  oldLoading()
  try {
    const tab_data = await paymentTabsSettings(this.folderId,'new_payment',this)
    this.totalResidue = tab_data.total_residue
    this.nextInstallmentIsDownPayment = tab_data.next_installment_is_down_payment
    this.nexInstallmentNumber = tab_data.next_installment_number
    this.amountOverdue = tab_data.amount_overdue

    const installments_data = await paymentInstallments(this.folderId,urlParams)
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
    paymentMethod: function (){
      if(this.isLoaded){
        this.updateAmortizationTable()
      }
    }
},
methods: {
  numberToCurrency,
  submitForm,
  updateAmortizationTable: async function () {
    oldLoading()
    urlParams.set('payment_method',this.paymentMethod)
    try {      
      const installments_data = await paymentInstallments(this.folderId,urlParams)
      this.hasBonusResidue = installments_data.has_bonus_residue
      this.cashBackAvailable = installments_data.cash_back_available

      if(this.hasBonusResidue){
        this.bonusResidue = installments_data.bonus_residue
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
    next_date: this.generalData.nextDate, 
    is_down_payment: this.generalData.isDownPayment , 
    next_down_payment: this.generalData.nextDownPayment, 
    down_payment_count: this.generalData.downPaymentCount , 
    date: this.generalData.date, 
    client: this.client, 
    payment_method: this.paymentMethod, 
    bank_account: this.bankAccount,
    branch: this.branch,
    amount:this.amount,
    bonus_residue:this.hasBonusResidue ? this.bonusResidue : null }
  }
}
}


</script>