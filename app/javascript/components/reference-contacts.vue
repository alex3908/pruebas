<template>
<div style="width:100%:">
    <b-button v-if="canAddReferenceContacts" @click="showModal('add', $event)" class="btn btn-success float-right">Agregar</b-button>

    <div v-if="referenceContactsItems.length == 0" class="container">
        <div class="py-5">
        <p class="text-center h5 leyend mb-5">No se encontraron contacto de referencia  registrados.</p>
        </div>
    </div>

    <b-table v-else striped hover :items="referenceContactsItems" :fields="fields" class="tablesaw tablesaw-stack">
        <template #cell(id)="row">
            <b-link href="#" v-if="canEditReferenceContacts" class="table-link" @click="showModal('edit', $event, row.item.id)"><i class="fa fa-pencil-square-o"></i></b-link>
            <b-link href="#" v-if="canDeleteReferenceContacts" class="table-link" @click="deleteReferenceContact(row.item.id, $event)"><i class="fa fa-trash"></i></b-link>
        </template>
    </b-table>

    <b-modal ref="reference-contacts-modal" id="clientUserModal" title="contacto de referencia " :no-close-on-backdrop="true">
        <p b-mt-0>Nombre </p>
            <b-input v-model="name" placeholder="Nombre"/>
        <p class="mt-2">Correo</p>
            <b-input v-model="email" placeholder="Correo"/>
        <p class="mt-2">Teléfono</p>
            <b-input v-model="phone" class="form-control"/>
        <p class="mt-2">Concepto</p>
            <b-input v-model="concept" placeholder="Concepto"/>

        <template #modal-footer>
            <b-button size="sm" variant="success" :disabled="disabledConceptSubmitButton" @click="submit()">
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
import {oldLoading, oldComplete, requestError} from '../packs/payment-mixins'

axios.defaults.headers.common['X-CSRF-TOKEN'] = Rails.csrfToken();

export default {
    components: {

    },
    props:[
    "clientId",
    "canAddReferenceContacts",
    "canEditReferenceContacts",
    "canDeleteReferenceContacts"
    ],
    data() {
    return {
        timer: null,
        modalMode:'add',
        disabledConceptInput: false,
        disabledConceptSubmitButton: false,
        loadingUsers: false,
        referenceContactId: null,
        name: null,
        email: null,
        phone: null,
        concept: null,
        referenceContactsItems:[],
        fields: [
            { key: 'contact_name', label: 'Usuario', class: 'text-center'},
            { key: 'contact_email', label: 'Correo', class: 'text-center'},
            { key: 'contact_phone', label: 'Teléfono', class: 'text-center'},
            { key: 'contact_concept', label: 'Concepto', class: 'text-center'},
            { key: 'id', label: 'Acciones' }
        ]
    }
    },
    created: async function(){
    try {
        await this.getReferenceContacts()
    } catch (error) {
        requestError()
    }
    },
    methods: {
        getReferenceContacts: async function(){
            const response = await axios.get(Routes.reference_contacts_url({format: 'json'}))
            this.referenceContactsItems = response.data
        },
        getReferenceContactById: async function(reference_id){
            const response = await axios.get(Routes.reference_contact_url(reference_id, {format: 'json'}))
            return response
        },
        submit: async function(){
            var validate_email = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
            var validate_phone = /^[(]{0,1}[0-9]{3}[)]{0,1}[-\s\.]{0,1}[0-9]{3}[-\s\.]{0,1}[0-9]{4}$/


            this.disabledConceptSubmitButton = true
               if(!this.name){
                this.fireSwal('El Nombre es inválido','','warning')
                return
            }

            if(!validate_email.test(this.email)) {
                this.fireSwal('El Correo es inválido','','warning')
                return
            }
            if(!validate_phone.test(this.phone)) {
                this.fireSwal('El Teléfono es inválido','','warning')
                return
            }
            if(!this.concept){
                this.fireSwal('El Concepto es inválido','','warning')
                return
            }

            if(this.modalMode == 'add'){
                const response = await axios.post(Routes.reference_contacts_url({format: 'json'}), { reference_contact: {name: this.name, email: this.email, phone: this.phone, concept: this.concept, client_id: this.clientId}})
                await this.responseMessage(response.data, 'El contacto de referencia fue guardado exitosamente')
            }else{
                const response = await axios.put(Routes.reference_contact_url(this.referenceContactId, {format: 'json'}), { reference_contact: {name: this.name, email: this.email, phone: this.phone, concept: this.concept, client_id: this.clientId}})
                await this.responseMessage(response.data, 'El contacto de referencia fue actualizado exitosamente')
            }
            this.referenceContactId = null
            this.$refs['reference-contacts-modal'].hide()
            this.getReferenceContacts()
        },
        deleteReferenceContact: async function(reference_id, event){

            event.preventDefault()
            Swal.fire(
            {title: '¡Atención!',
            text: '¿Estás seguro que deseas eliminar el contacto de referencia',
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
                    const response = await axios.delete(Routes.reference_contact_url(reference_id, {format: 'json'}))
                    await this.responseMessage(response.data, 'El contacto de referencia fue eliminado exitosamente')
                    this.getReferenceContacts()
                }
            })
        },
        showModal: async function(mode, event, reference_id = null) {
            event.preventDefault()
            this.modalMode = mode
            this.referenceContactId = reference_id
            this.disabledConceptSubmitButton = false
            this.$refs['reference-contacts-modal'].show()
            if (this.modalMode == 'edit'){
                try {
                    oldLoading(true)
                    const response = await this.getReferenceContactById(reference_id)
                    const {contact_name, contact_email, contact_phone, contact_concept} = response.data[0]

                    this.name = contact_name
                    this.email = contact_email
                    this.concept = contact_concept
                    this.phone = contact_phone

                    this.disabledConceptInput = true
                    oldComplete()
                } catch (error) {
                    oldComplete()
                    requestError()
                }
            }else{
                this.disabledConceptInput = false
            }
        },
        hideModal(){
            this.$refs['reference-contacts-modal'].hide()
        },
        fireSwal(title,message,type){
            Swal.fire(title,message,type)
            this.disabledConceptSubmitButton = false
        },
        responseMessage: async function(response, message){
            const {errors} = response
            if(Object.keys(errors).length !== 0){
                this.fireSwal('¡Atención!',Object.values(errors).join(', '),'warning')
            }else{
                this.fireSwal('¡Éxito!',message,'success')
            }
        }
    }
}
</script>
