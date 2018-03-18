<template>
  <div class="tabMenu">
    <button
       v-popover:tab
    >
      <i class="icon-chevron-down" />
    </button>
    <popover name="tab" class="popover">
      <div v-for="i in [1, 2, 3, 4, 5]">
	<input type="checkbox">item {{ i }}
      </div>
      <button>Close Tab</button>
  </popover>
  </div>
</template>

<script>
export default {
  name: 'TabMenu',
}
</script>
