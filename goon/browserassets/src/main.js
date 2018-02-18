import Vue from 'vue';
import App from './App.vue';
import Message from './classes/Message';
import ehjaxHelper from './utils/ehjax';
import macros from './utils/macros';

Vue.config.productionTip = false;

const messages = [];
let messageLimit = 2053;
let nextMessageId = 0;
let clientData = [];
const ehjaxInfo = {
  pingTime: 0,
  pongTime: 0,
  lastPang: 0,
  pangLimit: 35000,
  admin: false,
  cookieLoaded: false,
};

function ehjaxCallback(data) {
  ehjaxHelper(data, ehjaxInfo, clientData);
}

window.ehjaxCallback = ehjaxCallback;

// Callback for winget.
window.wingetMacros = macros.wingetMacros;

function clearMessages() {
  messages.splice(0, messages.length);
}

export default function output(message, flag='') {
  const newMessage = new Message(
    message,
    nextMessageId,
    flag === 'preventLink',
  );

  if (messages.length) {
    const lastMessage = messages[messages.length - 1];
    if (lastMessage.message === newMessage.message) {
      lastMessage.count++;
      return;
    }
  }

  messages.push(newMessage);
  nextMessageId++;

  if (messages.length > messageLimit) {
    messages.shift();
  }
}

// if (!window.attachEvent || window.addEventListener) {

new Vue({
  data: {
    messages: messages,
    output: output,
    ehjaxInfo: ehjaxInfo,
    onClearMessages: clearMessages,
  },
  render: createElement => createElement(App, {
    props: {
      messages: messages,
      output: output,
      ehjaxInfo: ehjaxInfo,
      onClearMessages: clearMessages,
    }
  }),
}).$mount('#app');
