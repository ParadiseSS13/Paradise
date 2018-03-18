<template>
  <ChatModal v-if="open" :onRequestClose="requestClose">
    <div class="head">Change Font</div>
    <div class="changeFont">
      <a href="#"
         v-for="(fontFamily, displayName) in fontOptions"
         v-on:click.prevent="onFontChange(fontFamily)"
         :key="displayName"
         :style="{'font-family': fontFamily}"
      >
        {{displayName}}
      </a>
    </div>
  </ChatModal>
</template>

<script>
import ChatModal from './ChatModal.vue';

export default {
  name: 'FontSelect',
  components: {
    ChatModal,
  },
  data() {
    return {
      fontOptions: {
        // Display name: real name
        'Verdana (Default)': 'Verdana',
        'Arial / Helvetica': "'Helvetica Neue', Helvetica, Arial",
        'Times New Roman': 'Times New Roman',
        'Georgia': 'Georgia',
        'Courier New': 'Courier New',
        'Lucida Console': 'Lucida Console',
        'Wingdings': 'Wingdings',
        'Comic Sans MS': 'Comic Sans MS',
      },
    };
  },
  props: {
    onFontChange: Function,
    open: Boolean,
  },
  methods: {
    requestClose() {
      this.$emit('update:open', false);
    },
  }
}
</script>
