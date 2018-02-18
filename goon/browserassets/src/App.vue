<template>
  <div id="app">
    <ChatToolbar
       :ping="ping"
       :onIncreaseFontsize="increaseFontsize"
       :getChatHtml="getChatHtml"
       :onClearMessages="onClearMessages"
    />
    <ChatContent
       ref="chatContent"
       class="chatContent"
       :style="style"
       :messages="messages"
       v-on:click.native="handleClick($event)"
       v-on:mousedown.native="handleMousedown($event)"
       v-on:mouseup.native="handleMouseup($event)"
    />
    <div
       v-if="noResponse"
       :style="style"
       class="connectionClosed internal"
       :class="{restored: restored}">
      {{errorMessage}}
    </div>
  </div>
</template>

<script>
import ChatContent from './components/ChatContent.vue';
import ChatToolbar from './components/ChatToolbar.vue';
import runByond from './utils/runByond';
import cookies from './utils/cookies';
import macros from './utils/macros';

const cookieStyleFields = {
  fontsize: 'font-size',
  fonttype: 'font-family',
}

const mouseInfo = {
  downX: 0,
  downY: 0,
  tolerance: 10,
}

let intervalId;

export default {
  name: 'App',
  components: {
    ChatContent,
    ChatToolbar,
  },
  data: function() {
    return {
      style: {
	'font-size': '14px',
	'font-family': 'Verdana',
      },
      noResponse: false,
      restored: false,
      errorMessage: '',
    }
  },
  props: {
    messages: Array,
    output: Function,
    ehjaxInfo: Object,
    onClearMessages: Function,
  },
  computed: {
    cookieLoaded: function() {
      return this.ehjaxInfo.cookieLoaded;
    },
    ping: function() {
      return Math.ceil((this.ehjaxInfo.pongTime - this.ehjaxInfo.pingTime) / 2);
    },
  },
  watch: {
    cookieLoaded() {
      if (this.ehjaxInfo.cookieLoaded) {
        this.loadCookieStyles();
      }
    },
  },
  mounted: function() {
    // Tell BYOND to give us a macro list.
    // You need to activate hotkeymode before you can winget the macros in it.
    runByond('byond://winset?id=mainwindow&macro=hotkeymode');
    runByond('byond://winset?id=mainwindow&macro=macro');
    runByond('byond://winget?callback=wingetMacros&id=hotkeymode.*&property=command');
    runByond('?_src_=chat&proc=doneLoading');
    intervalId = setInterval(this.checkConnection, 2000);
    document.addEventListener('keydown', this.handleKeydown);
  },
  destroyed: function() {
    document.removeEventListener('keydown', this.handleKeydown);
    clearInterval(intervalId);
  },
  methods: {
    loadCookieStyles: function() {
      for (const cookieStyleField in cookieStyleFields) {
        const styleValue = cookies.getCookie(cookieStyleField);
        const styleName = cookieStyleFields[cookieStyleField];

        if (styleValue) {
          this.style[styleName] = styleValue;
          this.notify(`Loaded ${styleName} setting of ${styleValue}.`);
        }
      }
    },
    notify: function(text) {
      this.output(`<span class="internal boldnshit">${text}</span>`, 'internal');
    },
    checkConnection: function() {
      if (this.ehjaxInfo.lastPang + this.ehjaxInfo.pangLimit < Date.now()) {
        this.loseConnection();
        return;
      }
      if (this.noResponse) {
        this.restoreConnection();
      }
    },
    loseConnection: function() {
      this.noResponse = true;
      this.errorMessage = "You are either AFK, experiencing lag or the connection has closed."
    },
    restoreConnection: function() {
      // On restore connection, the user will be notified for 3 seconds that this has happened, no need to fill the screen with these.
      this.restored = true;
      this.errorMessage = 'Your connection has been restored (probably)!';
      setTimeout(() => {this.restored = this.noResponse = false}, 3000);
    },
    increaseFontsize: function(amount) {
      const currentFontsize = this.style['font-size'] ||
            getComputedStyle(this.$refs.chatContent.$el)['font-size'];
      const newFontsize = `${parseInt(currentFontsize) + amount}px`;
      this.style['font-size'] = newFontsize;
      cookies.setCookie('fontsize', newFontsize, 365);
    },
    handleKeydown: function(event) {
      event.preventDefault();

      // Hardcoded because else there would be no feedback message.
      if (event.key === 'F2') {
        runByond('byond://winset?screenshot=auto');
        this.notify('Screenshot taken');
      }

      const command = macros.keyToCommand(event.key);

      if (command) {
        runByond('byond://winset?mapwindow.map.focus=true;command='+command);
        return;
      }

      if (event.key.length === 1) {
        runByond('byond://winset?mapwindow.map.focus=true;mainwindow.input.text=' + event.key.toLowerCase());
        return;
      }

      this.focusMap();
    },
    handleClick: function(event) {
      // Handle byond links and open external links in external browser
      if (event.target.nodeName === 'A') {
        event.preventDefault();
        const href = event.target.getAttribute('href');

        if (href[0] === '?' || href.startsWith('byond://')) {
          runByond(href);
          return;
        }

        runByond('?action=openLink&link=' + encodeURIComponent(href));
      }
    },
    handleMousedown: function(event) {
      mouseInfo.downX = event.pageX;
      mouseInfo.downY = event.pageY;
    },
    handleMouseup: function(event) {
      if (Math.abs(mouseInfo.downX - event.pageX) <= mouseInfo.tolerance &&
          Math.abs(mouseInfo.downY - event.pageY) <= mouseInfo.tolerance) {
        // Focus map after all other event handlers finish
        setTimeout(this.focusMap, 0);
      }
    },
    focusMap: function() {
      runByond('byond://winset?mapwindow.map.focus=true');
    },
    getChatHtml: function() {
      return this.$refs.chatContent.$el.outerHTML;
    },
  }
}
</script>
