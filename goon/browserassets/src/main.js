import Vue from 'vue';
import App from './App.vue';
import Message from './classes/Message';

Vue.config.productionTip = false;

let messages = [];
let nextMessageId = 0;

function ehjaxCallback() {
  console.log('hi');
}

export default function output(message, flag) {
  if (messages.length) {
    const lastMessage = messages[messages.length - 1];
    if (lastMessage.message === message) {
      lastMessage.count++;
      return;
    }
  }

  const newMessage = new Message(
    message,
    nextMessageId,
    flag === 'preventLink',
  );

  messages.push(newMessage);
  nextMessageId++;
}

// if (!window.attachEvent || window.addEventListener) {
if (true) {
  new Vue({
  data: {
    messages: messages,
    output: output,
  },
  render: createElement => createElement(App, {
    props: {
      messages: messages,
      output: output,
    }
  }),
  }).$mount('#app');
}


window.ehjaxCallback = ehjaxCallback;
