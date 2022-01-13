<template>
<div style="width:100%;">
    <b-button v-if="canAddReferredClient" @click="showModal($event)" class="btn btn-success float-right">Agregar</b-button>

    <div v-if="referredCustomersItems.length == 0" class="container">
        <div class="py-5">
        <p class="text-center h5 leyend mb-5">No se encontraron clientes referidos.</p>
        </div>
    </div>

    <b-table v-else striped hover :items="referredCustomersItems" :fields="fields" class="tablesaw tablesaw-stack">
        <template #cell(id)="row">
            <b-link href="#" v-if="canDeleteReferredClient" class="table-link" @click="deleteClientUser(row.item.id, $event)"><i class="fa fa-trash"></i></b-link>
        </template>
    </b-table>

    <b-modal ref="referred-user-modal" title="Clientes refereidos" :no-close-on-backdrop="true">

        <b-form-group v-if="this.canAutocomplete" content-cols-md="12" label="Ingrese el cliente a referir">
            <vue-bootstrap-typeahead
                    ref="typeahead"
                    :data="clients"
                    v-model="clientSearch"
                    size="sm"
                    :serializer="s => s.value"
                    placeholder="Escriba el nombre del cliente"
                    @hit="refferedClientResult = $event"
            />
        </b-form-group> 

        <b-form-group v-else content-cols-md="12" label="Ingrese el correo del cliente a referir">
            <b-form-input v-model="clientSearch" placeholder="Ingresa el correo" type="email"></b-form-input>
        </b-form-group> 
            
        <b-form-group v-if="!this.canAutocomplete" content-cols-md="12" label="Cliente">
            <label><b>Nombre:</b></label> {{this.clientInfo}}
        </b-form-group> 
        <template #modal-footer>
            <b-button size="sm" variant="success" @click="submit()">
                Guardar
            </b-button>
            <b-button size="sm" variant="secondary" @click="hideModal()">
                Cancelar
            </b-button>
        </template>
    </b-modal>

</div>

</template>
<script>
import axios from 'axios';
import VueBootstrapTypeahead from 'vue-bootstrap-typeahead'
import {oldLoading, oldComplete, requestError} from '../packs/payment-mixins'

axios.defaults.headers.common['X-CSRF-TOKEN'] = Rails.csrfToken();

export default {
    components: {VueBootstrapTypeahead},    
    props:[
    "clientId",
    "canAddReferredClient",
    "canDeleteReferredClient",
    "canAutocomplete"
    ],
    data() {
    return {
        clientSearch:'',
        referredCustomersItems: [],
        clientInfo: 'Sin información',
        refferedClientId: null,
        refferedClientResult: null,
        clients: [],
        selectSettings: { width: '100%', placeholder: 'Seleccione un concepto', 'allowClear': true},
        fields: [
            { key: 'client_name', label: 'Cliente', class: 'text-center'},
            { key: 'id', label: 'Acciones' }
        ]
    }
    },
    created: async function(){
        try {
            if(this.clientId){
                this.getReferredCustomers()
            }
        } catch (error) {
            requestError()
        }
    },
    watch: {
        clientSearch: async function(value){
            try {

                if(this.canAutocomplete){
                        const clients = await this.getClientAutocomplete(value)
                        this.clients = clients
                }else{
                    if(this.validEmail(value)){
                        oldLoading()
                        const client = await this.getClientByEmail(value)
                        oldComplete()         
                        if (client){
                            const {id, name, first_surname, second_surname, email} = client
                            this.clientInfo = `${name} ${first_surname} ${second_surname} (${email})`
                            this.refferedClientId = id
                        }
                    }else{
                        this.refferedClientId = null
                        this.clientInfo = 'Sin información'
                    }
                }




            } catch (error) {
                console.log(error)
                requestError()
            }
        },
        referredCustomersItems: async function(value){
            if(!this.clientId){
                document.querySelectorAll('.client-hidden').forEach(e => e.remove());
                const form = document.getElementById("client-form")
                this.jsonArrayToHidden(form, value, 'client[referred_client][]')
            }
        },
        refferedClientResult: function(client){
            this.refferedClientId = client.id
            this.clientInfo = client.value
        }
    },
    methods: {
        getReferredCustomers: async function(){
            const response = await axios.get(Routes.get_referred_clients_client_url(this.clientId, {format: 'json'}))
            const {referred_clients} = response.data
            this.referredCustomersItems = referred_clients
        },
        getClientAutocomplete: async function(search){
            const response = await axios.get(Routes.autocomplete_clients_url({search, format: 'json'}))   
            return response.data ? response.data : null
        },
        getClientByEmail: async function(search){
            const response = await axios.get(Routes.autocomplete_by_email_clients_url({search, format: 'json'}))   
            return response.data ? response.data : null
        },
        submit: async function(){

            if(!this.refferedClientId){
                this.fireSwal('Seleccione un cliente','','warning')
                return
            }

            this.addReferredClient()
            this.$refs['referred-user-modal'].hide()
            this.resetModal()
            if(this.clientId){
                this.getReferredCustomers()
            }
        },
        addReferredClient: async function(){
            if(this.clientId){
                const response = await axios.post(Routes.client_referred_clients_url( this.clientId, {format: 'json'}), { referred_client: {client_id: this.clientId, client_id: this.selectedClientUserConcept, referred_client_id: this.refferedClientId}})
                await this.responseMessage(response.data, 'El cliente referido fue guardado exitosamente')
                this.getReferredCustomers()
            }else{
                const checkClientId = obj => obj.client_id === this.refferedClientId;
                if(this.referredCustomersItems.some(checkClientId)){
                    this.fireSwal('Ya se encuentra registrado','','warning')
                }else{
                    this.referredCustomersItems.push({id: (this.referredCustomersItems.length + 1), client_id: this.refferedClientId, client_name: this.clientInfo })
                }
            }
        },
        deleteClientUser: async function(referred_client_id, event){
            event.preventDefault()

            Swal.fire(
            {title: '¡Atención!',
            text: '¿Estás seguro que deseas eliminar el cliente referido?',
            type: 'warning',
            showCancelButton: true,
            cancelButtonText: 'Cancelar',
            confirmButtonText: 'Continuar',
            customClass: {
                confirmButton: 'btn btn-danger m-1',
                cancelButton: 'btn btn-secondary m-1'
            }}
            ).then( async (result) => {
                if(result.value){
                    if(this.clientId){
                        const response = await axios.delete(Routes.client_referred_client_url(this.clientId, referred_client_id, {format: 'json'}))
                        await this.responseMessage(response.data, 'El cliente referido fue eliminado exitosamente')
                        this.getReferredCustomers()
                    }else{
                        this.referredCustomersItems = this.referredCustomersItems.filter(function(el){ return el.id != referred_client_id; });
                    }
                }
            })
        },
        showModal: async function(event) {
            event.preventDefault()
            this.$refs['referred-user-modal'].show()
        },
        hideModal(){
            this.$refs['referred-user-modal'].hide()
            this.resetModal()
        },
        resetModal(){
            this.clientSearch = ''
        },
        fireSwal(title, message, type){
            Swal.fire(title, message, type)
        },
        responseMessage: async function(response, message){
            const {errors} = response
            if(Object.keys(errors).length !== 0){
                this.fireSwal('¡Atención!', Object.values(errors).join(', '), 'warning')
            }else{
                this.fireSwal('¡Éxito!', message, 'success')
            }
        },
        createHiddenElement: function(value, name){
            let input = document.createElement("input")
            input.setAttribute("class", "client-hidden")
            input.setAttribute("type", "hidden")
            input.setAttribute("name", name)
            input.setAttribute("value", value)
            return input
        },
        jsonArrayToHidden(form, array, name){
            array.forEach((element) =>{
                form.appendChild(this.createHiddenElement(element.client_id, name))
            });
        }
    }
}
</script>