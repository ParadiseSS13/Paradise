<template>
  <div class="tabBar">
    <div v-for="(tab, idx) in tabs"
         class="tab"
         :class="idx === activeTabIdx ? 'activeTab' : 'inactiveTab'"
         :key="idx"
         @click.prevent="updateActiveTabIdx(idx)"
    >
      <div class="tabUnread" :style="{opacity: tab.unread === 0 ? 0 : (.5 + tab.unread / 100)}"></div>
      <div class="tabName">
        <span v-if="idx !== activeTabIdx || !renaming">{{tab.name}}</span>
        <input
           v-show="idx === activeTabIdx && renaming"
           ref="renameInput"
           :value="tab.name"
           @input="onTabRename(idx, $event.target.value)"
           @blur="renaming = false"
           @keydown.enter.stop="renaming = false"
           @keydown.stop
        />
      </div>
      <div class="tabMenu">
        <button
           class="tabMenuButton"
           v-popover="{name: 'tab' + idx}"
        >
          <i class="icon-chevron-down" />
        </button>
        <popover :name="'tab' + idx" class="popover">
          <button @click.prevent="onSetFilter(idx, 'All')">
            <i :class="Object.values(tab.filters).every(val => val) ? 'icon-check' : 'icon-unchecked'" />
            <span>All</span>
          </button>
          <button
             v-for="(filterValue, filterName) in tab.filters"
             :key="filterName"
             @click.prevent="onSetFilter(idx, filterName, !filterValue)"
          >
            <i :class="filterValue ? 'icon-check' : 'icon-unchecked'" />
            <span>{{filterName}}</span>
          </button>
          <button @click.prevent="onCloseTab(idx)">
            <i class="icon-remove" /><span>Close Tab</span>
          </button>
        </popover>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue';
import Popover from 'vue-js-popover';

Vue.use(Popover);

export default {
  name: 'ChatTabBar',
  data() {
    return {
      renaming: false,
    };
  },
  props: {
    tabs: Array,
    activeTabIdx: Number,
    onTabRename: Function,
    onSetFilter: Function,
    onCloseTab: Function,
  },
  methods: {
    updateActiveTabIdx(idx) {
      if (this.activeTabIdx === idx) {
        this.beginRename(idx);
        return;
      }
      this.$emit('update:activeTabIdx', idx);
    },
    beginRename(idx) {
      this.renaming = true;
      this.$nextTick(() => this.$refs.renameInput[idx].focus());
    },
  },
}
</script>
