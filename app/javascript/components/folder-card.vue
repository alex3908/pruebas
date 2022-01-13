<style scoped></style>
<template>
  <div class="folder-card my-2 py-2 px-1 rounded border bg-light position-relative">
    <a :href="folder.link_url" class="text-decoration-none text-dark d-block text-left">
      <div class="card-main-data">
        {{ folder.project.name }}
        <span v-if="folder.stage.show_full_name">, {{ folder.phase.name }}</span>
      </div>
      <div class="card-main-data">
        {{ folder.stage.name }}, {{ folder.project.lot_entity_name }}
        {{ folder.lot.name }}
      </div>
      <div class="card-main-data">Folio: {{ folder.id }}</div>
      <small class="card-secondary-data">Cliente: {{ folder.client }}</small>
      <small class="card-secondary-data">
        Asesor: {{ folder.responsable_name }}
      </small>
      <small class="card-secondary-data">
        {{ folder_users_key(folder.key) }}
      </small>
      <div class="card-secondary-data ml-3">
        <small v-for="(user, index) in folder.folder_users" :key="index">- {{ user.name }}</small>
      </div>
      <small v-if="folder.time_in_step" class="card-secondary-data">
        Tiempo de operación: {{ folder.time_in_step }}
      </small>
      <small
        v-if="folder.required_documents_progress"
        class="card-secondary-data">
        Documentos: {{ folder.required_documents_progress }}
      </small>
      <small v-if="folder.total_sale" class="card-secondary-data">
        Monto de venta: {{ folder.total_sale }}
      </small>
      <i
        v-if="folder.back_to_step > 0"
        class="fa fa-info-circle pl-2"
        v-b-tooltip.hover
        :title="'Este expediente ha sido regresado ' + back_to_step_label(folder.back_to_step) + ' a este paso'"
      ></i>
    </a>
    <div class="step-avatar avatar-image">
<avatar 
      v-b-tooltip.hover 
      :title="'Vendedor: ' + folder.responsable_name"
      :alt="'Vendedor: ' + folder.responsable_name"
      class="avatar-image rounded-circle p-1 custom-avatar"
      :username="folder.responsable_name"
      :rounded="false"
      :size="40"
      :src="folder.avatar_url"></avatar>
    </div>

    
  </div>
</template>
<script>
  export default {
    props: ['folder'],
    methods: {
      back_to_step_label(back_to_step) {
        return back_to_step == 1 ? 'una vez' : `${back_to_step} veces`
      },
      folder_users_key(key) {
        if (key == 'director') {
          return 'Subdirectores responsables';
        } else if (key == 'vice_director') {
          return 'Gerentes responsables';
        } else if (key == 'manager') {
          return 'Coordinadores responsables';
        } else if (key == 'coordinator') {
          return 'Asesores responsables';
        } else {
          return 'Responsable';
        }
      },
    },
  }
</script>
