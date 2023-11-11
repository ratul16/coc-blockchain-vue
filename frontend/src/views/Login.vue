<template>
  <div class="container-fluid login">
    <div class="content-body">
      <div class="login-form">
        <div class="card border-0 shadow p-4">
          <div class="row g-4">
            <div class="col-md-12 form-floating">
              <input
                v-model="email"
                type="email"
                class="form-control"
                id="email"
                placeholder="name@example.com"
              />
              <label for="email">Email</label>
            </div>
            <div class="col-md-12 form-floating">
              <input
                v-model="password"
                type="password"
                class="form-control"
                id="password"
                placeholder="name@example.com"
              />
              <label for="password">Password</label>
            </div>
            <div class="col-12 text-center d-grid">
              <button
                @click="login"
                type="submit"
                class="btn btn-primary px-5 py-2 rounded"
              >
                Login &nbsp;<i class="fa-solid fa-right-to-bracket"></i>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import lcContract from "../../blockchain/UserAuth";
import { useAuthStore } from "../stores/auth";
export default {
  name: "Login",
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  data() {
    return {
      email: "",
      password: "",
      isVerified: false,
    };
  },
  mounted() {
    if (this.store.isAuth) {
      this.$router.push({ name: "profile" });
    }
  },
  methods: {
    connectWallet() {
      if (window.ethereum) {
        //meta mask installed
        window.ethereum
          .request({ method: "eth_requestAccounts" })
          .then((res) => {
            this.connected = true;
            this.account = res[0];
            this.getUserInventory();
          })
          .catch((err) => {
            alert(err.message);
          });
      } else {
        this.store.toastNotification("Please Install Metamask", "bg-danger");
      }
    },
    async login() {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];
        const isValidUser = await lcContract.methods
          .isValidUser(this.email, this.password)
          .call({ from: user });
        const userDetails = await lcContract.methods.getUserInfo(user).call();
        // update login status in blockchain
        if (isValidUser) {
          this.store.toastNotification("Login successfully!", "bg-success");
          this.store.login({
            name: userDetails[0],
            email: userDetails[1],
            role: userDetails[2],
            wallet: user,
            publicKey: userDetails[3],
          });
          if (this.store.isAdmin) {
            this.$router.push({ name: "dashboard" });
          } else {
            this.$router.push({ name: "profile" });
          }
        } else {
          this.store.toastNotification("Invalid user credential", "bg-danger");
        }
      } catch (err) {
        console.log(err);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    reset() {
      this.email = "";
      this.password = "";
    },
  },
};
</script>

<style lang="scss" scoped>
.login {
  background-color: #e5e5f7;
  background-image: radial-gradient($blue 0.5px, #e5e5f7 0.5px);
  background-size: 10px 10px;
  .content-body {
    font-size: 14px;
    min-height: calc(100vh - 58px);
    // background-color: red;
    display: flex;
    justify-content: center;
    align-items: center;
    .login-form {
      max-width: 450px;
      label {
        margin-left: 10px;
      }
      input {
        background: #f9f9f9;
      }
      h2 {
        text-align: center;
        margin-bottom: 10px;
      }
    }
  }
}
</style>
