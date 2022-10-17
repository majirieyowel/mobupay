<template>
  <div class="wrapper relative">
    <span @click="$emit('close')" class="close">&times;</span>
    <div class="contentAlert">
      <div class="topHalf">
        <p>
          <svg
            style="fill: green"
            viewBox="0 0 512 512"
            width="100"
            title="check-circle"
          >
            <path
              d="M504 256c0 136.967-111.033 248-248 248S8 392.967 8 256 119.033 8 256 8s248 111.033 248 248zM227.314 387.314l184-184c6.248-6.248 6.248-16.379 0-22.627l-22.627-22.627c-6.248-6.249-16.379-6.249-22.628 0L216 308.118l-70.059-70.059c-6.248-6.248-16.379-6.248-22.628 0l-22.627 22.627c-6.248 6.248-6.248 16.379 0 22.627l104 104c6.249 6.249 16.379 6.249 22.628.001z"
            />
          </svg>
        </p>
        <h3 class="title">{{ title }}</h3>

        <div>
          <slot></slot>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "success",
  props: {
    title: String,
  },
};
</script>

<style lang="scss" scoped>
.wrapper {
  /* height: 100vh; */
  display: flex;
  font-size: 14px;
  text-align: center;
  justify-content: center;
  align-items: center;
  /* font-family: "Khand", sans-serif; */

  .close {
    font-size: 30px;
    position: absolute;
    right: 33px;
    top: 15px;
    cursor: pointer;
  }
}
</style>

