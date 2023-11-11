<template>
  <div class="toast-notification">
    <div
      class="toast align-items-center text-white border-0"
      :class="store.variant"
      role="alert"
      aria-live="assertive"
      aria-atomic="true"
    >
      <div class="d-flex">
        <div class="toast-body">{{ store.message }}</div>
        <button
          type="button"
          class="btn-close btn-close-white me-2 m-auto"
          data-bs-dismiss="toast"
          aria-label="Close"
        ></button>
      </div>
    </div>
  </div>
</template>

<script>
import { useAuthStore } from "../stores/auth";
export default {
  name: "ToastNofitication",
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
};
</script>
<style lang="scss" scoped>
.toast-notification {
  position: fixed;
  bottom: 15px;
  right: 15px;
  z-index: 999999999;
  transition: $transition;
  .toast {
    display: block;
  }
}
</style>