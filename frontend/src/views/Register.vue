<template>
  <div class="container-fluid register">
    <div class="content-body">
      <div class="register-form">
        <div class="card border-0 shadow p-4">
          <div class="row g-3">
            <div class="col-md-12">
              <label for="name">Name</label>
              <input
                v-model="name"
                type="text"
                class="form-control"
                id="name"
              />
            </div>
            <div class="col-md-12">
              <label for="role" class="form-label">Position</label>
              <select v-model="role" id="role" class="form-select">
                <option value="" selected>Select Role</option>
                <option value="0">Investigator</option>
                <option value="1">Forensic Analyst</option>
                <option value="2">Judge</option>
                <option value="3">Jury</option>
              </select>
            </div>
            <div class="col-md-12">
              <label for="email">Email</label>
              <input
                v-model="email"
                type="email"
                class="form-control"
                id="email"
              />
            </div>
            <div class="col-md-12">
              <label for="password">Password</label>
              <input
                v-model="password"
                type="password"
                class="form-control"
                id="password"
              />
            </div>
            <div class="col-md-12 mb-2">
              <label for="rePassword">Confirm Password</label>
              <input
                v-model="repassword"
                type="password"
                class="form-control"
                id="rePassword"
              />
            </div>
            <div class="col-12 text-center d-grid">
              <button
                @click="registerUser"
                type="submit"
                class="btn btn-outline-primary px-5 py-2 rounded"
              >
                Register &nbsp;<i class="fa-solid fa-right-to-bracket"></i>
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
  name: "register",
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  data() {
    return {
      name: "",
      email: "",
      password: "",
      repassword: "",
      role: "",
      connected: false,
      isUserRegistered: false,
      account: "",
    };
  },
  mounted() {
    if (this.store.isAuth) {
      this.$router.push({ name: "profile" });
    }
    this.checkUserRegistration();
  },
  methods: {
    async registerUser() {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];

        const gasEstimate = await lcContract.methods
          .registerUser(this.name, this.email, this.password, this.role)
          .estimateGas({ from: user });
        const gasLimit = Math.floor(gasEstimate * 1.2);

        await lcContract.methods
          .registerUser(this.name, this.email, this.password, this.role)
          .send({ from: user, gas: gasLimit })
          .once("receipt", (receipt) => {
            console.log(receipt);
          });
        this.$router.push({ name: "login" });
        this.store.toastNotification(
          "User registered successfully!",
          "bg-success"
        );
        this.checkUserRegistration();
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    async checkUserRegistration() {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];
        const userDetails = await lcContract.methods.getUserInfo(user).call();
        if (Object.keys(userDetails).length === 0) {
          this.store.toastNotification("User Already registered", "bg-danger");
        }

        // console.log(userDetails);
        // this.userInfo = {
        //   name: userDetails[0],
        //   email: userDetails[1],
        // };
      } catch (error) {
        console.error(error);
        this.store.toastNotification(
          "Error checking user registration",
          "bg-danger"
        );
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.register {
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
    .register-form {
      max-width: 420px;
      input {
        background: #fbfbfb;
      }
      h2 {
        text-align: center;
        margin-bottom: 10px;
      }
    }
  }
}
</style>
