<template>
  <div id="app">
    <nav
      class="navbar navbar-expand-md navbar-dark bg-dark fixed-top shadow-sm"
    >
      <div class="container">
        <a class="navbar-brand" href="/">
          <i class="fa-solid fa-cube fa-xl"></i>
        </a>
        <button
          class="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarCollapse"
          aria-controls="navbarCollapse"
          aria-expanded="false"
          aria-label="Toggle navigation"
        >
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarCollapse">
          <ul class="navbar-nav ms-auto text-capitalize">
            <li
              v-if="store.isAuthenticated && this.store.isAdmin"
              class="nav-item"
            >
              <router-link :to="{ name: 'dashboard' }" class="nav-link">
                dashboard
              </router-link>
            </li>
            <li v-if="store.isAuthenticated && !store.isAdmin" class="nav-item">
              <router-link :to="{ name: 'profile' }" class="nav-link">
                profile
              </router-link>
            </li>
            <li
              v-if="store.isAuthenticated && !this.store.isAdmin"
              class="nav-item"
            >
              <router-link :to="{ name: 'cases' }" class="nav-link">
                case view
              </router-link>
            </li>
            <li v-if="!store.isAuthenticated" class="nav-item">
              <router-link :to="{ name: 'login' }" class="nav-link">
                login
              </router-link>
            </li>
            <li v-if="!store.isAuthenticated" class="nav-item">
              <router-link :to="{ name: 'register' }" class="nav-link">
                register
              </router-link>
            </li>
            <li v-if="store.isAuthenticated" class="nav-item">
              <a href="" class="nav-link" @click="logout"> Logout </a>
            </li>
          </ul>
        </div>
      </div>
    </nav>
    <ToastNotification v-if="store.showNotification" />
    <router-view />
  </div>
</template>

<script>
import ToastNotification from "./components/ToastNotification.vue";
import { useAuthStore } from "./stores/auth";
export default {
  name: "App",
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  components: {
    ToastNotification,
  },
  data() {
    return {
      routeList: [
        {
          path: "/dashboard",
          name: "dashboard",
        },
        {
          path: "/profile",
          name: "profile",
        },
        {
          path: "/case/:id",
          name: "Cases",
        },
        {
          path: "/login",
          name: "login",
        },
        {
          path: "/register",
          name: "register",
        },
      ],
    };
  },
  mounted() {
    this.store.initialize();
  },
  methods: {
    // getRoutes() {
    //   const routes = this.$router.options.routes;
    //   console.log(routes);
    //   if (this.store.isAuthenticated) {
    //     this.routeList = routes
    //       .filter((obj) => obj.name != "login" && obj.name != "register")
    //       .map((r) => r.name);
    //   } else {
    //     this.routeList = routes.map((r) => r.name);
    //   }
    // },
    logout() {
      this.$router.push("/"); // Redirect to login page after logout
      this.store.logout();
      this.store.toastNotification("User Logged out", "bg-success");
    },
  },
};
</script>

<style lang="scss" scoped>
</style>
