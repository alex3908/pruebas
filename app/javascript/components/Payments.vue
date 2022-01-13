<template>
  <div class="container">
      <nav>
        <div class="nav nav-tabs" id="payments-tab" role="tablist">
            <a v-for="(tab, index) in this.tabs" :key="tab.key" class="nav-item nav-link" :class="{active: activePanel == index}" data-toggle="tab" @click="setSelectedTab(tab.key,index)" :href="`#${tab.key}`" role="tab" aria-selected="true">{{tab.label}}</a>
        </div>
      </nav>
      <div class="tab-content" id="nav-tabContent">
        <div class="row mb-3">
          <div class="col-4 pr-0">
            <hr class="marker-bar-green">
          </div>
          <div class="col-8 pl-0">
            <hr class="marker-bar-gray">
          </div>
        </div>
        <div v-for="(tab,index) in this.tabs" :key="tab.key" :id="tab.key" class="tab-pane fade" :class="[activePanel == index ? ['active','show'] : '']" role="tabpanel">
            <keep-alive>
              <new-payment :ref="tab.key" :folder-id="folderId" :has-pending-installments="hasPendingInstallments" v-if="tab.key == 'new_payment' && activePanel == index" @loadTab="activeForm = tab.key"/> 
            </keep-alive>

            <keep-alive>
              <new-capital :ref="tab.key" :folder-id="folderId" :restructure-type="tab.key" v-if="tab.key == 'new_capital' && activePanel == index" @loadTab="activeForm = tab.key"/> 
            </keep-alive>

            <keep-alive>
              <new-restructure :ref="tab.key" :folder-id="folderId" :restructure-type="tab.key" v-if="tab.key == 'new_restructure' && activePanel == index" @loadTab="activeForm = tab.key"/> 
            </keep-alive>

            <keep-alive>
              <new-date :ref="tab.key" :folder-id="folderId" :restructure-type="tab.key" v-if="tab.key == 'new_date' && activePanel == index" @loadTab="activeForm = tab.key"/> 
            </keep-alive>

            <keep-alive>
              <new-delay :ref="tab.key" :folder-id="folderId" :restructure-type="tab.key" v-if="tab.key == 'new_delay' && activePanel == index" @loadTab="activeForm = tab.key"/> 
            </keep-alive>

            <keep-alive>
              <new-additional-concept-payment :ref="tab.key" :folder-id="folderId" :restructure-type="tab.key" v-if="tab.key == 'new_additional_concept_payment' && activePanel == index" @loadTab="activeForm = tab.key"/> 
            </keep-alive>
        </div>
        
      </div>
  </div>
</template>
<script>
  import {oldComplete, oldLoading} from '../packs/payment-mixins'

export default {
  
  components: { 
      NewPayment:() => import('./NewPayment.vue'),
      NewCapital: () => import('./NewCapital.vue'),
      NewRestructure: () => import('./NewRestructure.vue'),
      NewDate: () => import('./NewDate.vue'),
      NewDelay: () => import('./NewDelay.vue'),
      NewAdditionalConceptPayment: () => import('./NewAdditionalConceptPayment.vue')
    },
    props: ['folderId','hasPendingInstallments'],
    data() {
    return {
      activePanel: 0,
      activeForm:"",
      tabs: []
    }},
    created() {
      oldLoading()
      
      fetch(this.folder_data_url())
        .then(data => data.json())
        .then(({payment_permissions}) => {
          this.tabs = payment_permissions  
          oldComplete()  
        })
    },
    mounted(){
      const saveButton = document.getElementById('save');
      if(saveButton){
        saveButton.disabled = false
        saveButton.addEventListener('click',() =>{
          const component = this.$refs[this.activeForm][0]
          component.submitForm(component.$refs.form,component.getPayload())    
        });
      }
      
    },
    methods: {
      folder_data_url() {
        return`/folders/${this.folderId}/installments/payment_settings.json`;
      },
      setSelectedTab(key,index){
        this.activePanel = index
        this.activeForm = key
      }
      
    }
}
  
</script>
<style scoped>
</style>