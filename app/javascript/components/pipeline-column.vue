<template>
  <div>
    <folder-card v-for="(folder) in folders" :key="folder.id" :folder="folder" />
    <infinite-loading @infinite="loadFolders">
      <template v-slot:no-more>&nbsp;</template>
      <template v-slot:no-results>&nbsp;</template>
      <template v-slot:spinner><b-spinner variant="success" label="Cargando..."></b-spinner></template>
    </infinite-loading>
  </div>
</template>
<script>
import FolderCard from './folder-card.vue';
import InfiniteLoading from 'vue-infinite-loading';

export default {
  components: { FolderCard, InfiniteLoading  },
  props: ['step_id'],
  data() {
    return {
      page: 1,
      folders: [],
      is_loading: false
    }
  },
  methods: {
    loadFolders($state) {
      this.is_loading = true;
      if (this.page == null) { 
        return; 
      }

      return fetch(this.folder_url())
        .then(blob => blob.json())
        .then(({ next_page, folders }) => {
          this.page = next_page;
          this.folders = this.folders.concat(folders);
        })
        .finally(() => {
          this.is_loading = false;
          if (this.page == null) {
            $state.complete();
          } else {
            $state.loaded();
          }
        })
    },
    folder_url() {
      const queryString = window.location.search;
      const urlParams = new URLSearchParams(queryString);
      urlParams.append('page', this.page);
      urlParams.append('step', this.step_id);
      return `/steps/pipeline.json?${urlParams.toString()}`;
  },
  }
}
</script>
<style scoped>
</style>
