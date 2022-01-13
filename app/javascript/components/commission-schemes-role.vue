<template>
  <section class="w-100">
    <div class="row">
      <div class="col-md-1 text-center py-3">
        <img v-bind:src="icons_quotation_discounts" class="img-fluid">
      </div>
      <div class="col-md-11">
        <div class="d-flex justify-content-between py-2">
          <h3 class="vertical-align m-0">{{section_title}}</h3>
          <button type="button" title="Agregar" class="btn btn-info" @click="add_commission_schemes_role">+</button>
        </div>
        <div class="row mb-3">
          <div class="col-4 pr-0">
            <hr class="marker-bar-green">
          </div>
          <div class="col-8 pl-0">
            <hr class="marker-bar-gray">
          </div>
        </div>
      </div>
    </div>

    <div class="row">
      <div class="col-md-12">
        <div class="table-container">
          <table class="table">
            <thead>
              <tr>
                <th v-for="(column) in labels.table_columns" :key="column">{{column}}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in commissions" :key="index" v-show="item._destroy != 1">
                <td>
                  <input type="hidden" v-model="item.id" :disabled="item.id < 0" :name="'commission_scheme[commission_schemes_roles_attributes]['+item.id+'][id]'">
                  <select :name="'commission_scheme[commission_schemes_roles_attributes]['+item.id+'][role_id]'" class="select2">
                    <option v-for="(role) in roles" :selected="role.id == item.role_id" :key="role.id" v-bind:value="role.id">{{role.name}}</option>
                  </select>
                </td>

                <td>
                  <select :name="'commission_scheme[commission_schemes_roles_attributes]['+item.id+'][folder_user_concept_id]'" class="select2">
                    <option v-for="(concept) in folder_user_concepts" :selected="concept.id == item.folder_user_concept_id" :key="concept.id" v-bind:value="concept.id">{{concept.name}}</option>
                  </select>
                </td>

                <td>
                  <div class="input-group">
                    <input type="number" v-model="item.commission" step="0.01" max="100" min="0" required="required" :name="'commission_scheme[commission_schemes_roles_attributes]['+item.id+'][commission]'" class="form-control text-right">
                    <div class="input-group-append">
                      <span class="input-group-text">%</span>
                    </div>
                  </div>
                </td>
                <td class="text-right">
                  <input v-model="item._destroy" type="hidden" :name="'commission_scheme[commission_schemes_roles_attributes]['+item.id+'][_destroy]'">
                  <a @click="click_delete(item.id, index)" data-toggle="" :data-confirm="labels.confirmation_destroy" href="javascript:void(0);" class="table-link existing" :title="labels.button_deleted">
                    <i class="fa fa-trash"></i>
                  </a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </section>
</template>
<script>

import icons_quotation_discounts from 'images/icons/quotation-discounts.png';

export default {
  name: 'commmission-schemes-role',
  props: { params: Object },
  data() {
    return {
      icons_quotation_discounts,
      labels: {},
      commissions: [],
      section_title: "",
      roles: [],
      folder_user_concepts: []
    }
  },
  methods: {
    commission_schemes_roles_url() {
      const queryString = window.location.search;
      const urlParams = new URLSearchParams(queryString);
      urlParams.append('id', this.commission_scheme_id);
      return `/commission_schemes/commission_schemes_roles.json?${urlParams.toString()}`;
    },
    add_commission_schemes_role() {
      let folder_user_concept_id = 0
      let role_id = 0;
      if(this.folder_user_concepts.length !== 0)
        folder_user_concept_id = this.folder_user_concepts[0].id

      if(this.roles.length !== 0)
        role_id = this.roles[0].id;

      this.commissions.push({
        commission: 0,
        folder_user_concept_id: folder_user_concept_id,
        id: Date.now() * -1,
        role_id: role_id
      })
    },
    click_delete(id, index) {
      let btn_confirm_delete = document.querySelector('.commit');
      if(btn_confirm_delete != undefined){
        btn_confirm_delete.onclick = this.assign_removed(id, index);
      }
    },
    assign_removed(id, index) {
      this.commissions[index]._destroy = 1;
      this.$forceUpdate();
    },
  },
  mounted() {
    if(this.params.hasOwnProperty('section_title'))
      this.section_title = this.params.section_title

    if(this.params.hasOwnProperty('labels'))
      this.labels = this.params.labels

    if(this.params.hasOwnProperty('roles'))
      this.roles = this.params.roles

    if(this.params.hasOwnProperty('folder_user_concepts'))
      this.folder_user_concepts = this.params.folder_user_concepts

    if(this.params.hasOwnProperty('commissions'))
      this.commissions = this.params.commissions
  },
  updated() {
    document.querySelectorAll(".select2").forEach(function(select_two) {
      initSelect2(select_two);
    });
  }
}
</script>
<style scoped>
</style>
