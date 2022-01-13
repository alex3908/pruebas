<template>
    <b-modal ref="signLinksModal" size="lg" title="Enlaces de firma">
        
        <b-table striped hover :items="linkItems" :fields="fields" class="tablesaw tablesaw-stack" show-empty> 
            <template #empty="">
                <h6 class="text-center">No hay registros</h6>
            </template>
            <template #cell(sign_url)="row">
                <b-link v-if="canSendSignatureLinkByWhatsapp && row.item.phone" href="#" class="table-link" @click="getLink('whatsapp', $event,row.item)" title="Enviar por Whatsapp"><i class="fa fa-whatsapp" aria-hidden="true"></i></b-link>
                <b-link v-if="canSendSignatureLinkByEmail" href="#" class="table-link" @click="getLink('email', $event, row.item)" title="Enviar por correo"><i class="fa fa-envelope-o" aria-hidden="true"></i></b-link>
                <b-link v-if="canSendSignatureLinkByClipboard" ref="clipBoardButton" href="#" class="table-link" @click="getLink('clipboard', $event, row.item)" title="Copiar al portapapeles"><i class="fa fa-clipboard" aria-hidden="true"></i></b-link>
            </template>
        </b-table>
        
        <template #modal-footer="{cancel}">
            <b-button size="sm" variant="secondary" @click="cancel()">
                Cancelar
            </b-button>
        </template>
    </b-modal>
    
</template>
<script>
import axios from 'axios';
import {oldLoading, oldComplete, requestError} from '../packs/payment-mixins'

axios.defaults.headers.common['X-CSRF-TOKEN'] = Rails.csrfToken();

export default {
props:[
"folderId",
],
data() {
  return {
      linkItems: [],
      fields: [
            { key: 'name', label: 'Nombre', class: 'text-center'},
            { key: 'email', label: 'Correo', class: 'text-center'},
            { key: 'sign_url', label: 'Acciones' }
      ],
      canSendSignatureLinkByWhatsapp: false,
      canSendSignatureLinkByEmail: false,
      canSendSignatureLinkByClipboard: false
  }
},
mounted: async function(){
  try {
    this.$root.$on('showSignLinksModal', (recipient_type) => {
        this.showModal(recipient_type)
    })
  } catch (error) {
    requestError()
  }
},
methods: {
    getModalInfo: async function(recipient_type){
        oldLoading(true)
        try {
        const result = await axios.get(Routes.sign_links_modal_info_folder_url(this.folderId,{recipient_type, format: 'json'}))

        const {linkItems, can_send_signature_link_by_whatsapp, can_send_signature_link_by_email, can_send_signature_link_by_clipboard} = result.data
            this.linkItems = linkItems
            this.canSendSignatureLinkByWhatsapp = can_send_signature_link_by_whatsapp
            this.canSendSignatureLinkByEmail = can_send_signature_link_by_email
            this.canSendSignatureLinkByClipboard = can_send_signature_link_by_clipboard
            oldComplete()
        } catch (error) {
            throw new Error('Retry');
        }
    },
    getLink(type, event, item){
        event.preventDefault()
        const {email, id, sign_url, name, phone} = item
        console.log(item)
        switch (type) {
            case 'whatsapp':
                this.getByWhatsApp(name, phone, sign_url)
                break;
            case 'email':
                this.getByEmail(email, id)
                break;
            case 'clipboard':
                this.getByClipboard(sign_url)
                break;
        }
    },
    showModal: async function(recipient_type){
        await this.getModalInfo(recipient_type)
        this.$refs['signLinksModal'].show()
    },
    getByWhatsApp(name, phone, sign_url){
        const message = `Hola ${name} te comparto el enlace para que puedas continuar con tu proceso de firma`.replace(' ','+')
        const whatsapp_url = `https://wa.me/${phone}?text=${message}:+${sign_url}`;
        window.open(whatsapp_url , '_blank');
    },
    getByEmail: async function(email, participant_id){
        try {
            const result = await axios.get(Routes.send_sign_link_email_folder_url(this.folderId,{email, participant_id, format: 'json'}))
            const {message, error} = result.data
            this.fireToast((error ? 'error' : 'success'), message)            
        } catch (error) {
            throw new Error('Retry');
        }
    },
    getByClipboard(url){        
        this.$copyText(url, this.$refs.clipBoardButton.$el).then( (e) => {
            this.fireToast('success', 'La etiqueta se ha copiado al portapapeles')
        }, (e) =>{
            this.fireToast('error', 'Error al copiar')
        })
    },
    fireToast(type, title){
        Swal.fire({
            toast: true,
            type,
            position: 'top-end',
            timer: 4000,
            title,
            showConfirmButton: false,
        });
    }
}
}

</script>