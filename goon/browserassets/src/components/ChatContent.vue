<template>
  <div class="chatContent">
    <ChatMessage
      v-for="message in messages"
      :message="message"
      :key="message.messageId"
      :atBottom="atBottom"
      :snapToBottom="snapToBottom"
      :onUnmount="scrollUp"
      :onNewUnseenMessage="newUnseenMessage"
    />
    <a href="#" v-on:click.prevent="snapToBottom" v-if="newMessages > 0" id="newMessages">
      <span>{{newMessages}} new message{{newMessages > 1 ? 's' : ''}}</span>
      <i class="icon-double-angle-down" />
    </a>
  </div>
</template>

<script>
import ChatMessage from './ChatMessage.vue';

export default {
  name: 'ChatContent',
  components: {
    ChatMessage,
  },
  data: function() {
    return {
      newMessages: 0,
    };
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
    newMessages() {
      if (this.atBottom()) {
	this.snapToBottom();
      }
    }
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
      this.newMessages = 0;
    },
    scrollUp: function(distance) {
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
    newUnseenMessage: function() {
      this.newMessages++;
    },
  },
}
</script>
