<template>
  <div id="app">
    <ChatToolbar :ping="ping" :onIncreaseFontsize="increaseFontsize" />
    <ChatContent ref="chatContent" :style="style" :messages="messages" />
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

const macros = {};

// Callback for winget.
function wingetMacros(newMacros) {
  const idRegex = /.*?\.(?!(?:CRTL|ALT|SHIFT)\+)(.*?)(?:\+REP)?\.command/;
  // Do NOT match macros which need crtl, alt or shift to be held down.
  for (const key in newMacros) {
    const match = idRegex.exec(key);

    if (match === null) {
      continue;
    }

    const macroID = match[1].toUpperCase();

    macros[macroID] = newMacros[key];
  }
}

window.wingetMacros = wingetMacros;

const cookieStyleFields = {
  fontsize: 'font-size',
  fonttype: 'font-family',
}

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
    onSetClientData: Function,
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
    setInterval(this.checkConnection, 2000);
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
  }
}
</script>
