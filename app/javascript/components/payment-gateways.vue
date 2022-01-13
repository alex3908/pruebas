<template>
    <b-modal id="modal-window" size="lg" title="Pasarelas de cobro" :no-close-on-backdrop="true">
        <b-form-group content-cols-md="12" label="Cliente">
            <Select2 v-model="selectedClient" :options="clients" :settings="selectSettings" />
        </b-form-group>    
        <b-form-group content-cols-md="12">
            <h5 class="modal-title">Pasarelas</h5>
        </b-form-group>
        <b-form-group content-cols-md="12" label="Seleccione el tipo de pasarela">
            <Select2 v-model="selectedGatewayType" :options="gatewayTypes" :settings="selectSettings" />
        </b-form-group>
        <b-col v-if="canShowPaymentButtons" ref="buttonClipboard" cols="12" class="text-center">
            <b-button v-if="canSendByWhatsapp" variant="primary" class="btn-sm m-1" :data-url="whatsappUrl" @click="sendUrlByWhatsapp">
                <i class="fa fa-whatsapp" aria-hidden="true"></i> Whatsapp
            </b-button>
            <b-button v-if="canSendByEmail" variant="info" class="btn-sm m-1" @click="sendUrlByEmail">
                <i class="fa fa-envelope-o" aria-hidden="true"></i> Email
            </b-button>
            <b-button v-if="canCopyToClipboard"  variant="secondary" class="btn-sm m-1" @click="doCopy" >
                <i class="fa fa-clipboard" aria-hidden="true"></i> Copiar al portapapeles 
            </b-button>
        </b-col>
        <b-form-group v-if="canSuscribe && subscriptionItems.length > 0 && (canCancelSubscription || canUpdateSuscription)" content-cols-md="12">
            <h5 class="modal-title">Domiciliaciones</h5>
        </b-form-group>
        <b-col ref="suscriptionButtons" cols="12" v-if="canSuscribe && subscriptionItems.length > 0" class="text-center">
            <b-form-group content-cols-md="12">
                <b-button v-if="canUpdateSuscription" type="button" variant="dark" class="btn-sm m-1" @click="updateSuscription">Actualizar suscripción</b-button>
            </b-form-group>
        </b-col>
        <b-col cols="12" v-if="canSuscribe && canCancelSubscription" class="text-center">
             <b-table striped hover :items="subscriptionItems" :fields="fields">
                <template #cell(suscription_id)="data">
                    <p><small>{{data.subscription_id}}</small></p>
                </template>
                <template #cell(id)="row">
                    <b-button type="button" variant="warning" @click="cancelSubscription(row.value)" class="btn-sm m-1">Cancelar</b-button>
                </template>

             </b-table>
        </b-col>
        <template #modal-footer="{cancel}">
            <b-button size="sm" variant="secondary" @click="cancel()">
                Cancelar
            </b-button>

        </template>
    </b-modal>
</template>
<script>
import Select2 from 'v-select2-component-reloaded';
import axios from 'axios';
import qs from "qs";
import {oldLoading, oldComplete, requestError} from '../packs/payment-mixins'

axios.defaults.headers.common['X-CSRF-TOKEN'] = Rails.csrfToken();

const PAYMENT_TYPES = {downPayment: "down-payment", 
                       finance: "finance",
                       suscription: "suscription" }

export default {
props:[
"folderId"
],
components: {Select2},
data() {
  return {
    selectedClient: '',
    selectedGatewayType: '',
    gatewayTypes: [],
    clients:[],
    subscriptionItems:[],
    emailUrl:"",
    whatsappUrl:"",
    clipboardUrl: "",
    selectSettings: { width: '100%', placeholder: 'Seleccione un elemento', 'allowClear': true},
    fields: [
        { key: 'subscription_id', label: 'ID Suscripción Financiamiento', class: 'text-center'},
        { key: 'status', label: 'Estado', class: 'text-center' },
        { key: 'id', label: 'Acciones' }
    ],
    canSendByWhatsapp: false, 
    canSendByEmail: false, 
    canCopyToClipboard: false, 
    canSuscribe: false,
    cannotPerformSubscription: false,
    canCancelSubscription: false,
    canUpdateSuscription: false,
    activeSuscription: false,
    canShowPaymentButtons: true
  }
},
created: async function(){
  try {
    await this.getModalInfo()
  } catch (error) {
    requestError()
  }
},
mounted: async function(){
  try {
    this.$root.$on('bv::modal::show', (bvEvent, modalId) => {
      this.getModalInfo()
    })
  } catch (error) {
    requestError()
  }
},
watch: {
    selectedGatewayType: function (val) {
        this.emailUrl = Routes.send_email_payment_link_folder_url({id:this.folderId})
        this.checkSubscriptions()
        
        if(!this.selectedClient && this.isSubscriptionGateWay()){
            this.selectedGatewayType = ''
            this.fireWarning('cliente')
            return
        }

        switch (val) {
            case PAYMENT_TYPES["downPayment"]:
                this.whatsappUrl = Routes.folder_pay_online_url({id:this.folderId})
                this.clipboardUrl = Routes.folder_pay_online_url({id:this.folderId})
                break;
            case PAYMENT_TYPES["finance"]:
                this.whatsappUrl = Routes.new_online_payment_url({reference:this.folderId})
                this.clipboardUrl = Routes.new_online_payment_url({reference:this.folderId})
                break;
            case PAYMENT_TYPES["suscription"]:
                this.whatsappUrl = Routes.new_subscription_url(this.folderId,this.selectedClient)
                this.clipboardUrl = Routes.new_subscription_url(this.folderId,this.selectedClient)
                this.emailUrl = Routes.new_subscription_url(this.folderId,this.selectedClient)
                break;
        }
    }
},
methods: {
doCopy: function () {
    
    if (this.validateGatewayButtons()) {
        return;
    }
    this.$copyText(this.clipboardUrl,this.$refs.buttonClipboard).then(function (e) {
        Swal.fire({
            toast: true,
            type: 'success',
            position: 'top-end',
            timer: 4000,
            title: "La etiqueta se ha copiado al portapapeles",
            showConfirmButton: false,
        })
    }, function (e) {
         Swal.fire({
            toast: true,
            type: 'error',
            position: 'top-end',
            timer: 4000,
            title: "Error al copiar",
            showConfirmButton: false,
        });
    })
},
sendUrlByEmail:function () {

    if (this.validateGatewayButtons()) {
        return;
    }

    const options = this.clients.find(element => element.id == this.selectedClient);
    const {email} = options;

    if (email.length == 0) {
        Swal.fire(
            'Sin correo electrónico',
            'Por favor configure un correo electrónico del cliente para continuar con el proceso de pago',
            'warning'
        )
    return;
    }

    if(this.isSubscriptionGateWay()){
        this.createSubscription()
    }else{
        $.ajax({
            type: 'POST',
            url: `${this.emailUrl}?client=${this.selectedClient}&type=${this.selectedGatewayType}`,
        })
    }

},
sendUrlByWhatsapp: function() {

    if (this.validateGatewayButtons()) {
        return;
    }

    const options = this.clients.find(element => element.id == this.selectedClient);
    const {phone} = options;


    if (phone.length == 0) {
        Swal.fire(
            'Sin número telefónico',
            'Por favor configure un número telefonico del cliente para continuar con el proceso de pago',
            'warning'
        );
    return;
    }

    const whatsapp_message = this.isSubscriptionGateWay() ? "domiciliar tus pagos" : "realizar tu pago"
    const whatsapp_url = `https://wa.me/${phone}?text=Hola+te+comparto+el+enlace+para+${whatsapp_message.replace(' ','+')}:+${this.whatsappUrl}`;
    window.open(whatsapp_url);
},
createSubscription: function(){
    const qsg = qs.stringify({ invite: {client_id: this.selectedClient, folder_id: this.folderId} }); 
    axios
    .get(`${Routes.invite_folder_subscriptions_url({folder_id: this.folderId})}.json?${qsg}`)
    .then(response => {
        if(response.data){
            Swal.fire({
            toast: true,
            type: 'success',
            position: 'top-end',
            timer: 4000,
            icon: 'success',
            title: 'Se le ha enviado al cliente la invitación para domiciliar sus pagos',
            showConfirmButton: false,
            })
        }else{
            Swal.fire({
                title: 'Error',
                text: 'Hubo un error al intentar enviar la invitación.',
                type: 'error',
                confirmButtonText: 'Continuar',
                footer: 'Si tienes alguna duda, por favor comunícate con tu responsable.'
            })
        }
        
    })
},
updateSuscription(){
    Swal.fire(
    {title: '¡Atención!',
     text: '¿Estás seguro que deseas enviar la invitación para actualizar los datos de la suscripción?',
     type: 'warning',
     showCancelButton: true,
     cancelButtonText: 'Cancelar',
     confirmButtonText: 'Continuar',
     customClass: {
        confirmButton: 'btn btn-danger m-1',
        cancelButton: 'btn btn-secondary m-1'
     }}
    ).then((result) => {
        if (result.value) {
            axios
            .put(`${Routes.invite_update_folder_subscription_url(this.folderId,this.activeSuscription)}.json`)
            .then(response => {
                if(response.data){
                    Swal.fire({
                        title: '¡Correo enviado!',
                        text: 'Se ha enviado un correo al cliente para que pueda actualizar sus datos bancarios.',
                        type: 'success',
                        confirmButtonText: 'Continuar',
                        customClass: {
                            confirmButton: 'btn btn-success',
                            cancelButton: 'btn btn-danger'
                        },
                        buttonsStyling: false
                    })
                }else{
                    Swal.fire({
                        title: 'Error',
                        text: 'Hubo un error al enviar la invitación al correo del cliente',
                        type: 'error',
                        confirmButtonText: 'Continuar',
                        footer: 'Espera un momento y vuelve a intentarlo. \\n Si el problema persiste, por favor comunícate con tu responsable.\''
                    })
                }
                
            })

        }
    })
    
},
cancelSubscription(id){
    Swal.fire(
    {title: '¡Atención!',
        text: '¿Estás seguro que deseas cancelar la suscripción?',
        type: 'warning',
        showCancelButton: true,
        cancelButtonText: 'Cancelar',
        confirmButtonText: 'Continuar',
        customClass: {
        confirmButton: 'btn btn-danger m-1',
        cancelButton: 'btn btn-secondary m-1'
        }}
    ).then((result) => {
        if (result.value) {
            axios
            .delete(`${Routes.folder_subscription_url(this.folderId,id)}.json`)
            .then(response => {
                if (response.data.message == 'destroy_success')
                    Swal.fire({
                        title: '¡Suscripción cancelada!',
                        text: 'La domiciliación ha sido cancelada de manera correcta.',
                        type: 'success',
                        confirmButtonText: 'Continuar',
                        customClass: {
                            confirmButton: 'btn btn-success',
                            cancelButton: 'btn btn-danger'
                        },
                        buttonsStyling: false
                    }).then(()=> this.hideModal())
                else if (response.data.error == 'destroy_error'){
                    Swal.fire({
                        title: 'Error',
                        text: 'No se ha podido cancelar la suscripción',
                        type: 'error',
                        confirmButtonText: 'Continuar',
                        footer: 'Espera un momento y vuelve a intentarlo. Si el problema persiste, por favor comunícate con tu responsable.'
                    })
                }            
            })
        }
    })
},
getModalInfo: async function(){
    oldLoading(true)
    try {
      const result = await axios.get(`${Routes.payment_modal_info_folder_url(this.folderId)}.json`)

      const {canSendByWhatsapp, 
            canSendByEmail, 
            canCopyToClipboard, 
            canSuscribe, 
            cannotPerformSubscription, 
            canCancelSubscription,
            canUpdateSuscription,
            activeSuscription,
            clients,
            subscriptionItems,
            gatewayTypes} = result.data
        this.canSendByWhatsapp = canSendByWhatsapp
        this.canSendByEmail = canSendByEmail
        this.canCopyToClipboard = canCopyToClipboard
        this.canSuscribe = canSuscribe
        this.cannotPerformSubscription = cannotPerformSubscription
        this.canCancelSubscription = canCancelSubscription
        this.canUpdateSuscription = canUpdateSuscription
        this.activeSuscription = activeSuscription
        this.clients = clients
        this.subscriptionItems = subscriptionItems
        this.gatewayTypes = gatewayTypes
        this.checkSubscriptions()
        oldComplete()
    } catch (error) {
        throw new Error('Retry');
    }
},
hideModal(){
    this.$root.$emit('bv::hide::modal', 'modal-window')
},
isSubscriptionGateWay(){
    return this.selectedGatewayType == PAYMENT_TYPES["suscription"]
},
fireWarning(type){
    Swal.fire(
        `Por favor seleccione un ${type} para poder continuar con el proceso de ${this.isSubscriptionGateWay() ? 'domiciliación' : 'pago'}`,
        '',
        'warning'
    );
},
validateGatewayButtons(){

    if (!this.selectedClient) {
        this.fireWarning('cliente')
        return true;
    }

    if (!this.selectedGatewayType) {
        this.fireWarning('tipo de pago')
        return true;
    }


    if (this.cannotPerformSubscription && this.isSubscriptionGateWay()){
        Swal.fire({
        title: 'No se puede domiciliar',
        text: 'Este expediente presenta saldos vencidos, por lo que no es posible hacer una domiciliación.',
        icon: 'warning',
        showCancelButton: true,
        cancelButtonText: 'Cancelar',
        confirmButtonText: 'Pagar saldo vencido',
        customClass: {
            confirmButton: 'btn btn-warning btn-pay-overdue m-1',
            cancelButton: 'btn btn-secondary m-1'
        },
        buttonsStyling: false
        }).then((result) => {
            if (result.value) {
                this.$copyText(Routes.new_online_payment_url({id: this.folderId}),this.$refs.buttonClipboard).then(function (e) {
                        Swal.fire({
                            toast: true,
                            type: 'success',
                            position: 'top-end',
                            timer: 4000,
                            title: "El enlace se ha copiado al portapapeles",
                            showConfirmButton: false,
                        })
                    })
            }
        })
        return true
    }


    return false
},
checkSubscriptions(){
    if(this.subscriptionItems.length > 0 && this.isSubscriptionGateWay()){
        this.canShowPaymentButtons = false
    }else{
        this.canShowPaymentButtons = true
    }
}

}
}

</script>