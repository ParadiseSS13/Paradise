<template>
  <div class="chatContent">
    <ChatMessage
      v-for="message in messages"
      :message="message"
      :key="message.messageId"
      :onMount="snapIfAtBottom"
      :onUnmount="scrollUp"
    />
  </div>
</template>

<script>
import ChatMessage from './ChatMessage.vue';

export default {
  name: 'ChatContent',
  components: {
    ChatMessage,
  },
  props: {
    messages: Array,
  },
  computed: {
    lastMessageId: function() {
      return this.messages.length && this.messages[this.messages.length - 1].messageId;
    },
  },
  watch: {
    // lastMessageId() {
    //   if (this.atBottom()) {
    // 	const element = this.$refs.chatContent;
    //   }
    // },
  },
  methods: {
    atBottom: function() {
      const element = this.$el;
      const scrollSnapTolerance = 10;
      const scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
      return (document.documentElement.clientHeight + scrollTop >= element.offsetHeight - scrollSnapTolerance);
    },
    snapToBottom: function() {
      this.scrollTo(this.$el.offsetHeight);
    },
    snapIfAtBottom: function() {
      if (this.atBottom()) {
	this.snapToBottom();
      }
    },
    scrollUp: function(distance) {
      console.log(distance);
      if (!this.atBottom()) {
	const scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
	const newPos = scrollTop - distance;
	this.scrollTo(newPos);
      }
    },
    scrollTo: function(pos) {
      document.body.scrollTop = pos;
      document.documentElement.scrollTop = pos;
    },
  },
}
</script>
