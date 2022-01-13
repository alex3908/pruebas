<template>
  <div>
    <b-list-group-item>
      <div v-if="hidden == false">
        <span
	 class="pointer"
         :aria-expanded="viewable ? 'true' : 'false'"
         :aria-controls="id"
         @click="toggleBody"
        >
          <strong>
	    <u :class="viewed() ? '' : 'text-primary'">{{ announcement.title }}</u><small class="ml-1 text-warning" v-if="viewed() == false">(nuevo)</small>
	  </strong>
        </span>
        <i class="mt-1 float-right fa fa-times" @click="hide" aria-hidden="true"></i>
      </div>
      <div v-else>
        <i class="text-disabled">Anuncio oculto</i>
      </div>
    </b-list-group-item>
    <b-collapse :id="id" v-model="viewable">
      <b-card>
        {{ announcement.body }}
      </b-card>
    </b-collapse>
  </div>
</template>
<style>
span {
 word-wrap:break-word;
}
.pointer {
  cursor: pointer;
}
</style>
<script>
import CookieMixin from '../mixins/set-cookie';
export default {
  mixins: [CookieMixin],
  props: ['announcement'],
  data: function () {
    return {
      hidden: false,
      viewable: false,
      id: this._uid.toString()
    }
  },
  methods: {
    viewed() {
      return this.getArrayCookie('viewedAnnouncements').includes(this.announcement.id.toString())
    },
    toggleBody: function() {
      if (this.viewable == false && !this.viewed()) {
        this.addToArrayCookie('viewedAnnouncements', this.announcement.id);
      }

      this.viewable = !this.viewable;
    },
    hide: function() {
      this.visible = false;
      this.hidden = true;

      this.addToArrayCookie('hiddenAnnouncements', this.announcement.id);
    }
  }
}
</script>
