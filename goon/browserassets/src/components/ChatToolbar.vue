<template>
  <div id="userBar">
    <div v-if="showPing" id="ping">
      <i :style="pingCircleColor" class="icon-circle"></i>
      <span class="ms">{{ping}}ms</span>
    </div>
    <div id="options">
      <a href="#" v-on:click.prevent.stop="showOptions = !showOptions" class="toggle" title="Options">
        <i class="icon-cog"></i>
      </a>
      <div v-if="showOptions" v-click-outside="hide" class="sub" style="display: block">
        <a href="#" v-on:click.prevent="onIncreaseFontsize(-1)" class="decreaseFont">
          <span>Decrease font size</span>
          <i class="icon-font">-</i>
        </a>
        <a href="#" v-on:click.prevent="onIncreaseFontsize(1)" class="increaseFont">
          <span>Increase font size</span> <i class="icon-font">+</i>
        </a>
        <a href="#" class="chooseFont">
          Change font <i class="icon-font"></i>
        </a>
        <a href="#" class="toggleHideSpam">
          <span>Condense chat</span> <i class="icon-ban-circle"></i>
        </a>
        <a href="#" v-on:click.prevent="showPing = !showPing" class="togglePing">
          <span>Toggle ping display</span> <i class="icon-circle"></i>
        </a>
        <a href="#" class="highlightTerm">
          <span>Highlight string</span> <i class="icon-tag"></i>
        </a>
        <a href="#" class="saveLog">
          <span>Save chat log</span> <i class="icon-save"></i>
        </a>
        <a href="#" class="clearMessages">
          <span>Clear all messages</span> <i class="icon-eraser"></i>
        </a>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue';
import vClickOutside from 'v-click-outside';

Vue.use(vClickOutside);

export default {
  name: 'ChatToolbar',
  data() {
    return {
      showOptions: false,
      showPing: true,
    };
  },
  props: {
    ping: Number,
    onIncreaseFontsize: Function,
  },
  computed: {
    pingCircleColor() {
      // Interpolate between green to red
      const red = Math.min(this.ping, 255);
      const green = 255 - red;
      const blue = 0;
      return {color: `rgb(${red}, ${green}, ${blue})`};
    },
  },
  methods: {
    hide() {
      this.showOptions = false;
    },
  },
}
</script>
