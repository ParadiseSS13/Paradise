import Vue from 'vue';
import App from './App.vue';
import Message from './classes/Message';
import ehjaxHelper from './utils/ehjax';

Vue.config.productionTip = false;

let messages = [];
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
}

function ehjaxCallback(data) {
  ehjaxHelper(data, ehjaxInfo, clientData);
}

function setClientData(newClientData) {
  clientData = newClientData;
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
if (true) {
  new Vue({
  data: {
    messages: messages,
    output: output,
    ehjaxInfo: ehjaxInfo,
    onSetClientData: setClientData,
  },
  render: createElement => createElement(App, {
    props: {
      messages: messages,
      output: output,
      ehjaxInfo: ehjaxInfo,
      onSetClientData: setClientData,
    }
  }),
  }).$mount('#app');
}


window.ehjaxCallback = ehjaxCallback;
