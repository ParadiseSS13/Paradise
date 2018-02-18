<template>
  <div class="popup" :style="{'transform': 'translate(-50%, -50%)'}">
    <slot />
    <a href="#" v-on:click.prevent="onRequestClose" class="close">
      <i class="icon-remove"></i>
    </a>
  </div>
</template>

<script>


export default {
  name: 'ChatModal',
  props: {
    onRequestClose: Function,
  },
}
</script>
