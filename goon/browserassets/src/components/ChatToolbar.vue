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
        <a href="#" v-on:click.prevent="saveChatLog" class="saveLog">
          <span>Save chat log</span> <i class="icon-save"></i>
        </a>
        <a href="#" v-on:click.prevent="onClearMessages" class="clearMessages">
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

function openWindow(content) {
  let win;

  try {
    win = window.open('',
                      'RAW Chat Log',
                      `toolbar=no, location=no, directories=no, status=no, menubar=yes, scrollbars=yes, resizable=yes, width=1200, height=800, top=${screen.height - 400}, left=${screen.width - 840}`);
  }
  catch (e) {
    return;
  }
  if (win && win.document && window.document.body) {
    win.document.body.innerHTML = content;
    return win;
  }
}

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
    getChatHtml: Function,
    onClearMessages: Function,
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
    saveChatLog() {
      // synchronous requests are depricated in modern browsers
      const xmlHttp = new XMLHttpRequest();
      xmlHttp.open('GET', 'browserOutput.css', true);
      xmlHttp.onload = () => {
        // request successful
        if (xmlHttp.status === 200) {
          // Generate Log
          let saved = '<style>' + xmlHttp.responseText + '</style>';
          saved += this.getChatHtml();
          saved = saved.replace(/&/g, '&amp;');
          saved = saved.replace(/</g, '&lt;');
          
          // Generate final output and open the window
          const finalText = '<head><title>Chat Log</title></head> \
<iframe src="saveInstructions.html" id="instructions" style="border:none;" height="220" width="100%"></iframe>'+
              saved
          openWindow(finalText);
        }
        else {
          // request returned http error
          openWindow('Style Doc Retrieve Error: ' + xmlHttp.statusText);
        }
      }

      // timeout and request errors
      xmlHttp.timeout = 300;
      xmlHttp.ontimeout = function() {
        openWindow('XMLHttpRequest Timeout');
      }
      xmlHttp.onerror = function() {
        openWindow('XMLHttpRequest Error: '+xmlHttp.statusText);
      }
      
      // css needs special headers
      xmlHttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
      xmlHttp.send(null);
      return;
    },
  },
}
</script>
