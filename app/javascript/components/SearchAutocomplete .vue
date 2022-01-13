<template>
  <div class="autocomplete">
    <input
      type="text"
      :class="inputClass"
      :value="value"
      @input="onChange($event.target.value)"
      :placeholder="placeholder"
      @keydown.down="onArrowDown"
      @keydown.up="onArrowUp"
      @keydown.enter="onEnter"
      :disabled="disabled"
    />
    <ul
      id="autocomplete-results"
      v-show="isOpen"
      class="autocomplete-results"
      :style="cssProps"
    >
      <li
        class="loading"
        v-if="isLoading"
      >
        {{loaderTitle}}
      </li>
      <li
        v-else
        v-for="(result, i) in results"
        :key="i"
        @click="setResult(result)"
        class="autocomplete-result"
        :class="{ 'is-active': i === arrowCounter }"
      >
        {{ result.value }}
      </li>
    </ul>
  </div>
</template>

<script>
  export default {
    name: 'SearchAutocomplete',
    props: {
      items: {
        type: Array,
        required: false,
        default: () => [],
      },
      isAsync: {
        type: Boolean,
        required: false,
        default: false,
      },
      placeholder: {
        required: false,
        type: String,
        default: ''
      },
      inputClass: {
        required: false,
        type: String,
        default: ''
      },
      value: {
        type: String,
        default: ''
      },
      listColor: {
        required: false,
        type: String,
        default: '#4AAE9B'
      },
      loaderTitle: {
        required: false,
        type: String,
        default: ''
      },
      isLoading: {
        required: false,
        type: Boolean,
        default: false
      },
      disabled: {
        required: false,
        type: Boolean,
        default: false
      }
    },
    data() {
      return {
        isOpen: false,
        results: [],
        arrowCounter: -1,
        hoverColor: this.listColor
      };
    },
    computed: {
      cssProps () {
          return{
              '--hover-color': this.hoverColor
          }
      }
    },
    watch: {
      items: async function () {
          try{
           await this.filterResults();
          }catch(err){  
            throw new Error(err);
          }
      }
    },
    mounted() {
      document.addEventListener('click', this.handleClickOutside)
    },
    destroyed() {
      document.removeEventListener('click', this.handleClickOutside)
    },
    methods: {
      setResult(result) {
        this.$emit('input', result.value);
        this.$emit('selected', result.id);
        this.isOpen = false;
      },
      filterResults: async function() {
        this.isOpen = true;
        this.results = await this.items.filter((item) => {
          return item.value.toLowerCase().indexOf(this.value.toLowerCase()) > -1;
        });
        if(this.results.length === 0) {
          this.isOpen = false;
        }
      },
      onChange(newValue) {
        this.$emit('input', newValue)
        this.$emit('selected', null);
      },
      handleClickOutside(event) {
        if (!this.$el.contains(event.target)) {
          this.isOpen = false;
          this.arrowCounter = -1;
        }
      },
      onArrowDown() {
        if (this.arrowCounter < this.results.length) {
          this.arrowCounter = this.arrowCounter + 1;
        }
      },
      onArrowUp() {
        if (this.arrowCounter > 0) {
          this.arrowCounter = this.arrowCounter - 1;
        }
      },
      onEnter() {
        if (this.arrowCounter < 0){
          return 
        }
        const result = this.results[this.arrowCounter]
  
        this.$emit('input', result.value);
        this.$emit('selected', result.id);
        this.isOpen = false;
        this.arrowCounter = -1;
      },
    },
  };
</script>

<style scoped>
  .autocomplete {
    position: relative;
  }

  .autocomplete-results {
    padding: 0;
    margin: 0;
    border: 1px solid #eeeeee;
    height: 120px;
    overflow: auto;
  }

  .autocomplete-result {
    list-style: none;
    text-align: left;
    padding: 4px 2px;
    cursor: pointer;
  }

  .autocomplete-result.is-active,
  .autocomplete-result:hover {
    background-color: var(--hover-color);
    color: white;
  }
</style>
