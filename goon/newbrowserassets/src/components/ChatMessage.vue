<template>
  <div>
    <span v-show="filters[messageType]" ref="messageContent" v-html="processed" />
    <span
       v-if="shouldCondenseChat && message.count > 1"
       class="repeatBadge"
       :style="{animation: badgeStyle}">
      x{{message.count}}
    </span>
  </div>
</template>

<script>
import filterClasses from './filterClasses';
const bubbleAnimation = 'fontbubble 0.2s infinite';

function determineMessageType(element) {
  const classNames = element.className.split(' ');

  for (const [filterName, classes] of Object.entries(filterClasses)) {
    if (classNames.some(className => classes.includes(className))) {
      return filterName;
    }
  }

  if (classNames.some(className => className.includes('radio'))) {
    return 'radios';
  }

  for (const child of element.children) {
    const childType = determineMessageType(child);
    if (childType) {
      return childType;
    }
  }

  return null;
}

export default {
  name: 'ChatMessage',
  data: () => ({
    badgeStyle: '',
    height: 0,
    shouldSnapToBottom: false,
    emojiEnabled: false,
    timerId: null,
    messageType: 'other',
  }),
  props: {
    message: Object,
    atBottom: Function,
    snapToBottom: Function,
    onUnmount: Function,
    onNewUnseenMessage: Function,
    shouldCondenseChat: Boolean,
    filters: Object,
    onNewMessage: Function,
  },
  computed: {
    processed: function() {
      const processedMessage = this.message.process(this.emojiEnabled);
      if (this.shouldCondenseChat) {
        return processedMessage;
      }
      return Array(this.message.count).fill(processedMessage).join('<br>');
    },
    count: function() {
      return this.message.count;
    },
  },
  watch: {
    count() {
      this.badgeStyle = bubbleAnimation;
      clearTimeout(this.timerId);
      this.timerId = setTimeout(() => {this.badgeStyle = ''}, 200);
    },
  },
  updated: function() {
    this.height = this.$el.offsetHeight;
  },
  beforeMount: function() {
    this.shouldSnapToBottom = this.atBottom();
  },
  mounted: function() {
    this.height = this.$el.offsetHeight;
    this.emojiEnabled = this.shouldEmojify();
    this.setMessageType();
    if (this.filters[this.messageType]) {
      this.onNewMessage();
    }
    if (this.shouldSnapToBottom) {
      this.snapToBottom();
      return;
    }

    this.onNewUnseenMessage();
  },
  beforeDestroy: function() {
    this.onUnmount(this.height);
  },
  methods: {
    shouldEmojify: function() {
      return this.$el.querySelector('.emoji_enabled') !== null;
    },
    setMessageType: function() {
      this.messageType = determineMessageType(this.$refs.messageContent.firstChild) || 'other';
    },
  },
}
</script>
