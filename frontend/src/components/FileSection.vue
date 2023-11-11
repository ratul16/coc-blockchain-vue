<template>
  <div class="file-section">
    <p class="fw-bold mb-1">Uploaded Files</p>
    <ul class="file-list" :style="true ? 'max-height:220px' : 'height:auto'">
      <li class="item border-danger" v-if="!fileList.length">
        <i class="fa-solid fa-file-arrow-down"></i> &nbsp;
        <span>No file available</span>
      </li>
      <li class="item" v-for="(f, index) in fileList" :key="index">
        <i class="fa-solid fa-file-arrow-down"></i>
        <a
          :href="`http://localhost:8080/ipfs/${f}`"
          target="_blank"
          class="name"
        >
          {{ f }}
        </a>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: "FileSection",
  props: {
    fileList: {
      type: Array,
      default: () => [],
    },
  },
};
</script>

<style lang="scss" scoped>
.file-section {
  border-radius: 10px;
  border: 1px solid $border-variant-4;
  width: 100%;
  height: auto;
  padding: 10px;
  .file-list {
    overflow-y: auto;
    list-style-type: none;
    padding: 0 10px 10px 0;
    margin: 0;
    transition: 0.3s all ease-in-out;

    .item {
      border: 1px solid $border-variant-2;
      border-radius: 5px;
      padding: 10px;
      font-size: 14px;
      cursor: pointer;
      transition: $transition;
      &:hover {
        border: 1px solid $blue;
        color: $blue;
        .name {
          color: $blue;
        }
      }
      .name {
        transition: $transition;
        color: initial;
        margin-left: 5px;
        text-decoration: none;
      }
      &:not(:last-child) {
        margin-bottom: 5px;
      }
    }
  }
}
</style>