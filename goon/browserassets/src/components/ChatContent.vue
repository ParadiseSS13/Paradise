<template>
  <div class="chatContent">
    <ChatMessage
      v-for="message in messages"
      :message="message"
      :key="message.messageId"
      :atBottom="atBottom"
      :snapToBottom="snapToBottom"
      :onUnmount="scrollUp"
      :filters="filters"
      :onNewMessage="onNewMessage"
      :onNewUnseenMessage="newUnseenMessage"
      :shouldCondenseChat="shouldCondenseChat"
    />
    <a href="#" v-on:click.prevent="snapToBottom" v-if="newMessages > 0" id="newMessages">
      <span>{{newMessages}} new message{{newMessages > 1 ? 's' : ''}}</span>
      <i class="icon-double-angle-down" />
    </a>
  </div>
</template>

<script>
import ChatMessage from './ChatMessage.vue';

let wasAtBottom = true;

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
    shouldCondenseChat: Boolean,
    filters: Object,
    active: Boolean,
    tabIdx: Number,
    unread: Number,
    onUpdateTabUnread: Function,
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
    },
    active(newActive) {
      if (newActive) {
        this.onActivate();
        return;
      }
      this.onDeactivate();
    },
  },
  methods: {
    atBottom: function(ignoreActive=false) {
      const element = this.$el;
      if (!element || (!ignoreActive && !this.active)) {
        return false;
      }
      const scrollSnapTolerance = 10;
      const scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
      return (document.documentElement.clientHeight + scrollTop >= element.offsetHeight - scrollSnapTolerance);
    },
    snapToBottom: function() {
      this.scrollTo(this.$el.offsetHeight);
      this.newMessages = 0;
      console.log(`${this.tabIdx} 0`);
      this.onUpdateTabUnread(this.tabIdx, 0);
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
    onNewMessage: function() {
      if (!this.active) {
        console.log(this.unread);
        console.log(this.unread + 1);
        this.onUpdateTabUnread(this.tabIdx, this.unread + 1);
      }
    },
    onActivate: function() {
      if (wasAtBottom) {
        this.$nextTick(this.snapToBottom);
      }
    },
    onDeactivate: function() {
      wasAtBottom = this.atBottom(true);
    },
  },
}
</script>
