<template>
  <div ref="chatContent" class="chatContent">
    <ChatMessage
      v-for="message in messages"
      :message="message"
      :key="message.messageId"
      :onMount="snapIfAtBottom"
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
      const element = this.$refs.chatContent;
      const scrollSnapTolerance = 10;
      return (document.documentElement.clientHeight + document.documentElement.scrollTop >= element.offsetHeight - scrollSnapTolerance);
    },
    snapToBottom: function() {
      document.documentElement.scrollTop = document.documentElement.scrollTopMax;
      document.documentElement.scrollTop = this.$refs.chatContent.offsetHeight;
    },
    snapIfAtBottom: function() {
      if (this.atBottom()) {
	this.snapToBottom();
      }
    },
  },
}
</script>
