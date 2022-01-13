<template>
  <div>
    <div class="mt-2 bullhorn">
      <i v-b-modal.announcements-modal class="fa fa-bullhorn fa-2x" v-bind:class="bullhornColor" aria-hidden="true">
      </i>
    </div>
    <b-modal id="announcements-modal" title="Anuncios" hide-footer>
      <b-card v-if="visibleAnnouncements.length == 0">
        No hay anuncios para visualizar.
      </b-card>
      <b-list-group v-else>
        <notification-list-object v-for="announcement in visibleAnnouncements"
	                   v-bind:announcement="announcement"
	>
	</notification-list-object>
      </b-list-group>
    </b-modal>
  </div>
</template>
<style>
.bullhorn {
  cursor: pointer;
}
.notification:after {
  color: orange;
  content: '•';
  margin-left: -80%;
}
</style>
<script>
import NotificationListObject from './notification-list-object.vue';
import CookieMixin from '../mixins/set-cookie';

export default {
  mixins: [CookieMixin],
  components: { NotificationListObject },
  props: ['announcements'],
  data() {
    return {
      visibleAnnouncements: this.announcements.filter(announcement => !this.hasBeenHidden(announcement)),
      viewedAnnouncements: this.announcements.filter(announcement => this.getArrayCookie('viewedAnnouncements').includes(announcement.id.toString()))
    }
  },
  computed: {
    bullhornColor() { 
      return {
        'text-white': this.visibleAnnouncements.length > 0,
	'notification': this.visibleAnnouncements.length > 0 && this.viewedAnnouncements.length <= this.visibleAnnouncements.length
      }
    }
  },
  methods: {
    hasBeenHidden: function(announcement) {
      const hiddenAnnouncementsCookie = this.$cookies.get('hiddenAnnouncements')
      if (hiddenAnnouncementsCookie !== null) {
        return hiddenAnnouncementsCookie.includes(announcement.id);
      } else {
        return false;
      }
    }
  }
}
</script>
