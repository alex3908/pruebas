<template>
  <section>
    <div class="container">
      <div class="row">
        <div class="col-md-12">
          <div class="d-flex flex-wrap justify-content-between">
            <h3 class="text-left vertical-align m-0 py-3">Por Pagar</h3>
          </div>
        </div>
      </div>
      <div class="row mb-3">
        <div class="col-4 pr-0">
          <hr class="marker-bar-green" />
        </div>
        <div class="col-8 pl-0">
          <hr class="marker-bar-gray" />
        </div>
      </div>
      <div class="row">
        <div class="form-group col-sm-12 col-md-6">
          <label>Costo de venta</label>
          <div class="font-bold">
            {{ formatMoney(totalSale) }}
          </div>
        </div>
        <div class="col-md-6 col-sm-12">
          <div class="actions text-right pt-3">
            <button
              class="btn btn-info btn-sm"
              @click="addCustomInstallment"
              :disabled="has_no_custom_payments"
              type="button"
            >
              Agregar nueva letra <i class="fa fa-plus"></i>
            </button>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="col-md-12" v-if="has_no_custom_payments">
          <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <h6 class="text-center m-0">Existen letras con pagos activos, para hacer uso de este módulo es necesario que el expediente no cuente con pagos de financimiento activos.</h6>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
        </div>
        <div class="col-md-12" v-if="is_payments_limit && Number(capital_residue) > 0 && add_item">
          <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <h6 class="text-center m-0">Has alcanzado la cantidad máxima de cuotas a crear y el saldo a capital aun es mayor a 0. Por favor realiza los ajustes correspondientes.</h6>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
        </div>
        <div class="col-md-12" v-else-if="is_payments_limit && Number(capital_residue) == 0 && add_item">
          <div class="alert alert-warning alert-dismissible fade show" role="alert">
            <h6 class="text-center m-0">Has alcanzado la cantidad máxima de cuotas a crear.</h6>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
        </div>
        <div class="col-md-12">
          <form action="POST" class="sticky-top background-white pt-3" @submit.prevent="handleSubmit">
            <table-installments @updateInstallments="processInstallments" @removeInstallment="removeInstallment" :installments="installments"></table-installments>
            <div class="container">
                <div class="actions text-right py-3">
                  <a :href="urlCancel" class="btn btn-secondary">Cancelar</a>
                  <button type="submit" :disabled="((installments.length === 0) || has_no_custom_payments || Number(capital_residue) !== 0 )" class="btn btn-primary">Guardar</button>
                </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </section>
</template>
<script>
import Utilities from '../../mixins/utilities';

export default {
  props: ["urlProcessInstallments", "urlCancel", "urlSaveInstallments"],
  mixins: [Utilities],
  data() {
    return {
      totalSale: 0,
      installments: [],
      is_payments_limit: false,
      capital_residue: 0,
      add_item: false,
      has_custom_payments: false,
      has_no_custom_payments: false
    };
  },
  methods: {
    addCustomInstallment: async function (event) {
      const button = event.currentTarget;
      button.disabled = true;
      const installments = this.getInstallments();
      await this.requestProcessCustomInstallments(true, installments);
      button.disabled = false;
    },
    handleSubmit: async function () {
      const installments = this.getInstallments();
      if (!this.validateForm(installments)) return;

      await Swal.fire({
        title: '¿Seguro que deseas guardar las cuotas personalizadas?',
        text:
          'Recuerda que al confirmar esta acción la fórmula de cálculo dejará de ser la de pagos iguales y perderás acceso a los siguientes módulos: Abonos a capital, reestructuras de saldo, cambios de fechas y prórrogas de pagos.',
        type: 'warning',
        showCancelButton: true,
        closeOnCancel: true,
        allowOutsideClick: false,
        cancelButtonText: 'No, Cancelar.',
        confirmButtonText: 'Sí, Continuar.',
        customClass: {
          confirmButton: 'btn btn-success',
          cancelButton: 'btn btn-danger ml-2',
        },
        buttonsStyling: false,
      }).then(isConfirm => {
        const { value = false } = isConfirm;
        if (value) { this.saveInstallments(installments); } 
      });     
    },
    validateForm: function(installments = []){
      let valid_form = true;
      installments.forEach((installment, idx) => {
        if(installment.date === null){
          valid_form = false;
          this.installments[idx].valid_date = false;
        }

        if(Number(installment.capital) === 0){
          valid_form = false;
          this.installments[idx].valid_capital = false;
        }
      });
      return valid_form;
    },
    saveInstallments: async function(installments = []){
      try {
        showHideLoading(true);
        const ctx = this;
        const response = await fetch(this.urlSaveInstallments, 
          { 
            method: "POST", 
            body: JSON.stringify({ installments: installments}),
            headers: {
              'X-CSRF-Token': Rails.csrfToken(),
              'Content-Type': 'application/json',
            },
          }
        );
        if (!response.ok) throw response.message;
        const result = await response.json();
        showHideLoading(false);
        Swal.fire({
          title: '¡ÉXITO!',
          text: result.message,
          type: 'success',
          confirmButtonText: 'Continuar',
          customClass: {
            confirmButton: 'btn btn-success',
            cancelButton: 'btn btn-danger'
          },
          buttonsStyling: false
        }).then(function() {
          ctx.requestProcessCustomInstallments(false, [], true)
        });
        
      } catch (error) {
        showHideLoading(false);
        console.error(error);
        Swal.fire({
        icon: 'error',
        title: 'Oops...',
        text:
          'Hubo un error al procesar la información, por favor inténtalo de nuevo.',
        customClass: {
          confirmButton: 'btn btn-success',
          cancelButton: 'btn btn-danger',
        },
        confirmButton: false,
        cancelButton: true,
        buttonsStyling: false,
      });
      }

    },
    processInstallments: function (installment){
      const installments = this.getInstallments();
      installments[installment.index].capital = installment.capital;
      installments[installment.index].date = installment.date;
      this.requestProcessCustomInstallments(false, installments);
    },
    requestProcessCustomInstallments: async function(add_item = false, installments = [], only_load = false){
      try {
        showHideLoading(true);
        this.installments = [];
        const response = await fetch(this.urlProcessInstallments, 
          { 
            method: "PATCH", 
            body: JSON.stringify({ installments: installments, add_item, only_load}),
            headers: {
              'X-CSRF-Token': Rails.csrfToken(),
              'Content-Type': 'application/json',
            },
          }
        );
        const result = await response.json();
        this.installments = result.installments;
        this.is_payments_limit =  result.is_payments_limit;
        this.capital_residue = result.capital_residue;
        this.add_item = result.add_item;
        this.has_custom_payments = result.has_custom_payments;
        this.has_no_custom_payments = result.has_no_custom_payments;  
        this.totalSale = result.totalSale;
      } catch (error) {
        console.error(error)
      }
      finally{
        showHideLoading(false);
      }
    },
    removeInstallment: function(index){
      const installments = this.getInstallments().filter(function(el, idx) { return idx  != index });
      this.requestProcessCustomInstallments(false, installments);
    },
    getInstallments: function (){
      const installments = this.installments.map(function(item) {
        return {
          id: item.id,
          date: item.date,
          capital: item.capital
        }
      });
      return installments;
    }

  },
  created: async function () {
    this.requestProcessCustomInstallments(false, [], true)
  }
};
</script>