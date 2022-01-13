<template>
<div>
<section v-if="additionalConceptPayments.length > 0" class="concepts w-100">
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
    <div class="row">
        <div class="col-md-10 offset-md-1 col-sm-12 offset-sm-0">
            <div class="table-container">
                <table class="table table-striped tablesaw tablesaw-stack" data-tablesaw-mode="stack">
                    <thead>
                        <tr>
                            <th scope="col"></th>
                            <th scope="col">Concepto</th>
                            <th scope="col">Tipo</th>
                            <th scope="col">Total a Pagar</th>
                            <th scope="col">Fecha</th>
                            <th scope="col">Pago</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="additionalConceptPayment in additionalConceptPayments" :key="additionalConceptPayment.additional_concept_id">
                            <td :class="`aling-middle ${additionalConceptPayment.status_class}`">
                                <div class="text-center" :data-tooltip="additionalConceptPayment.status">
                                    <i class="fa fa-info-circle"></i>
                                </div>
                            </td>
                            <td>{{additionalConceptPayment.name}}</td>
                            <td>{{additionalConceptPayment.amount_type_label}}</td>
                            <td>{{numberToCurrency(additionalConceptPayment.amount)}}</td>
                            <td>{{additionalConceptPayment.date}}</td>
                            <td>{{numberToCurrency(additionalConceptPayment.payment_amount)}}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</section>

</div>
</template>
<script>
import {numberToCurrency} from '../packs/payment-mixins'

export default {
props:["additionalConceptPayments"],
data() {
    return {}
},
methods: {
  numberToCurrency
}
}

</script>