<template>
  <div>
    <span v-html="processed" />
    <span
       v-if="message.count > 1"
       class="repeatBadge"
       :style="{animation: badgeStyle}">
      x{{message.count}}
    </span>
  </div>
</template>

<script>
const bubbleAnimation = 'fontbubble 0.2s infinite';
let timerId = null;

export default {
  name: 'ChatMessage',
  data: () => ({
    badgeStyle: '',
    height: 0,
    shouldSnapToBottom: false,
  }),
  props: {
    message: Object,
    atBottom: Function,
    snapToBottom: Function,
    onUnmount: Function,
    onNewUnseenMessage: Function,
  },
  computed: {
    processed: function() {
      return this.message.process();
    },
    count: function() {
      return this.message.count;
    },
  },
  watch: {
    count() {
      this.badgeStyle = bubbleAnimation;
      clearTimeout(timerId);
      timerId = setTimeout(() => {this.badgeStyle = ''}, 200);
    },
  },
  beforeMount: function() {
    this.shouldSnapToBottom = this.atBottom();
  },
  mounted: function() {
    this.height = this.$el.offsetHeight;

    if (this.shouldSnapToBottom) {
      this.snapToBottom();
      return;
    }

    this.onNewUnseenMessage();
  },
  beforeDestroy: function() {
    this.onUnmount(this.height);
  },
}
</script>

