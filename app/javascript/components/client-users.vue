<template>
<div style="width:100%:">
    <b-button v-if="canAddClientUser" @click="showModal('add', $event)" class="btn btn-success float-right">Agregar</b-button>

    <div v-if="clientUserItems.length == 0" class="container">
        <div class="py-5">
        <p class="text-center h5 leyend mb-5">No se encontraron responsables registrados.</p>
        </div>
    </div>

    <b-table v-else striped hover :items="clientUserItems" :fields="fields" class="tablesaw tablesaw-stack">
        <template #cell(id)="row">
            <b-link href="#" v-if="canEditClientUser" class="table-link" @click="showModal('edit', $event, row.item.client_user_id)"><i class="fa fa-pencil-square-o"></i></b-link>
            <b-link href="#" v-if="canDeleteClientUser" class="table-link" @click="deleteClientUser(row.item.client_user_id, $event)"><i class="fa fa-trash"></i></b-link>
        </template>
    </b-table>

    <b-modal ref="client-user-modal" id="clientUserModal" title="Responsables" :no-close-on-backdrop="true">

        <b-form-group content-cols-md="12" label="Concepto">
            <Select2 v-model="selectedClientUserConcept" :options="clientUserConcepts" @change="roleSelect" :settings="selectSettings" :disabled="this.disabledConceptInput" />
        </b-form-group>

        <b-form-group content-cols-md="12" label="Usuario">
            <SearchAutocomplete
                :items="this.userConcepts"
                v-if="this.useAutocomplete"
                v-model="selectedUserSearch"
                placeholder="Escriba el nombre de usuario"
                inputClass="form-control"
                listColor="#54d335"
                loaderTitle="Cargando.."
                :isAsync="true"
                :isLoading="loadingUsers"
                :disabled="this.selectedClientUserConcept === null"
                @selected="selectedUser = $event"/>

            <Select2 v-else v-model="selectedUser" :options="users" :settings="selectSettings" />
        </b-form-group>

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
import Select2 from 'v-select2-component-reloaded';
import axios from 'axios';
import SearchAutocomplete from './SearchAutocomplete .vue'

import {oldLoading, oldComplete, requestError} from '../packs/payment-mixins'

axios.defaults.headers.common['X-CSRF-TOKEN'] = Rails.csrfToken();

export default {
    components: {
        Select2, SearchAutocomplete
    },
    props:[
    "clientId",
    "canAddClientUser",
    "canEditClientUser",
    "canDeleteClientUser",
    "useAutocomplete"
    ],
    data() {
    return {
        timer: null,
        modalMode:'add',
        disabledConceptInput: false,
        disabledConceptSubmitButton: false,
        loadingUsers: false,
        clientUserId: null,
        selectedClientUserConcept: null,
        clientUserConcepts: [],
        selectedUserSearch: null,
        users: [],
        selectedUser: null,
        userConcepts: [],
        selectSettings: { width: '100%', placeholder: 'Seleccione un concepto', 'allowClear': true},
        clientUserItems:[],
        fields: [
            { key: 'user_name', label: 'Usuario', class: 'text-center'},
            { key: 'user_email', label: 'Correo', class: 'text-center'},
            { key: 'user_phone', label: 'Teléfono', class: 'text-center'},
            { key: 'concept', label: 'Concepto', class: 'text-center'},
            { key: 'id', label: 'Acciones' }
        ]
    }
    },
    created: async function(){
    try {
        await this.getClientUsers()
        await this.getClientConcepts()
    } catch (error) {
        requestError()
    }
    },
    watch: {
        selectedUserSearch: function (value) {
            try {
            clearTimeout(this.timer)

            this.timer = setTimeout(() => {
                this.getUsers(value,this.selectedClientUserConcept)
            }, 200);
            } catch (error) {
                requestError()
            }
        }
    },
    methods: {
        getUsers: async function(user_search, client_user_concept_id){
            this.loadingUsers = true
            const response = await axios.get(Routes.autocomplete_users_url({user_search, client_user_concept_id, format: 'json'}))
            this.userConcepts = response.data
            this.loadingUsers = false
        },
        getClientConcepts: async function(){
            const response = await axios.get(Routes.get_concepts_client_user_concepts_url({format: 'json'}))
            const {client_user_concepts} = response.data
            this.clientUserConcepts = client_user_concepts
        },
        getClientUsers: async function(){
            const response = await axios.get(Routes.get_client_users_client_users_url({client_id: this.clientId, format: 'json'}))
            const {client_users} = response.data
            this.clientUserItems = client_users
        },
        getClientUser: async function(client_user_id){
            const response = await axios.get(Routes.client_user_url(client_user_id, {format: 'json'}))
            return response
        },
        submit: async function(){
            this.disabledConceptSubmitButton = true

            if(!this.selectedClientUserConcept){
                this.fireSwal('Seleccione un concepto','','warning')
                return
            }

            if(!this.selectedUser){
                this.fireSwal('Seleccione un usuario','','warning')
                return
            }

            if(this.modalMode == 'add'){
                const response = await axios.post(Routes.client_users_url({format: 'json'}), { client_user: {client_id: this.clientId, client_user_concept_id: this.selectedClientUserConcept, user_id: this.selectedUser}})
                await this.responseMessage(response.data, 'El responsable fue guardado exitosamente')
            }else{
                const response = await axios.put(Routes.client_user_url(this.clientUserId, {format: 'json'}), { client_user: {client_id: this.clientId, client_user_concept_id: this.selectedClientUserConcept, user_id: this.selectedUser}})
                await this.responseMessage(response.data, 'El responsable fue actualizado exitosamente')
            }
            this.clientUserId = null
            this.$refs['client-user-modal'].hide()
            this.resetModal()
            this.getClientUsers()
        },
        deleteClientUser: async function(client_user_id, event){

            event.preventDefault()

            Swal.fire(
            {title: '¡Atención!',
            text: '¿Estás seguro que deseas eliminar el responsable del cliente',
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
                    const response = await axios.delete(Routes.client_user_url(client_user_id, {format: 'json'}))
                    await this.responseMessage(response.data, 'El responsable fue eliminado exitosamente')
                    this.getClientUsers()
                }
            })
        },
        roleSelect: async function(){
            const response = await axios.get(Routes.list_users_role_client_users_url({id: this.selectedClientUserConcept, format: 'json'}))
            const { users } = response.data
            this.users = users
        },
        showModal: async function(mode, event, client_user_id = null) {
            event.preventDefault()

            this.modalMode = mode
            this.clientUserId = client_user_id
            this.disabledConceptSubmitButton = false
            this.$refs['client-user-modal'].show()

            if (this.modalMode == 'edit'){
                try {
                    oldLoading(true)
                    const response = await this.getClientUser(client_user_id)
                    const {user_id, concept_id, user_name} = response.data

                    this.selectedUser = user_id
                    this.selectedClientUserConcept = concept_id
                    this.selectedUserSearch = user_name
                    this.disabledConceptInput = true

                    await this.roleSelect()

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
            this.$refs['client-user-modal'].hide()
            this.resetModal()
        },
        resetModal(){
            this.selectedUserSearch = ''
            this.selectedUser = null
            this.selectedClientUserConcept = null
            this.users = []
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