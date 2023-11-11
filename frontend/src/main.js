import { useAuthStore } from './stores/auth';
import Vue from "vue";
import { createPinia, PiniaVuePlugin } from "pinia";
import Cryptojs from 'vue-cryptojs';
import App from "./App.vue";
import router from "./router";

const pinia = createPinia();

// import "./assets/main.scss";
Vue.use(Cryptojs);
Vue.use(PiniaVuePlugin);

new Vue({
  pinia,
  router,
  render: (h) => h(App),
}).$mount("#app");

router.beforeEach((to, from, next) => {
  const store = useAuthStore();
  store.initialize();
  if (to.meta.requiresAuth && !store.isAuthenticated) {
    next('/');
  } else {
    next();
  }
});