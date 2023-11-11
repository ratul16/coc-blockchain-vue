<template>
  <div class="container profile">
    <div class="content-body">
      <div class="row g-3" v-if="store.isAuth">
        <div class="col-md-12">
          <div class="profile-info border shadow-sm rounded p-3">
            <div
              class="d-flex justify-content-between align-items-center border-bottom border-2 pb-2 mb-2"
            >
              <h4 class="mb-0">Profile</h4>
              <div class="action-btn" v-if="store.getRoleAccess">
                <button
                  type="button"
                  class="btn btn-primary btn-sm"
                  data-bs-toggle="modal"
                  data-bs-target="#caseModal"
                >
                  <i class="fa-solid fa-plus"></i>&nbsp;Case File
                </button>
              </div>
            </div>
            <div class="row g-1">
              <div class="col-md-3">
                <span>Name</span>
                <p class="mb-0">
                  {{ store.user.name }}
                  <!-- ({{
                    store.user.publicKey ? true : false
                  }}) -->
                </p>
              </div>
              <div class="col-md-7">
                <span>Address</span>
                <p class="mb-0">
                  {{ store.user.wallet }}
                </p>
              </div>
              <div class="col-md-2">
                <span>Position</span>
                <p class="mb-0">{{ store.getRole }}</p>
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-8 col-sm-12">
          <div class="case-file">
            <h4>Case File List</h4>
            <div class="cases">
              <div
                class="case-card shadow-sm mb-2"
                v-for="(c, index) in caseList"
                :key="index"
                @click="openCaseFile(c)"
              >
                <i class="fa-regular fa-folder-open fa-xl"></i>
                <span class="day font-weight-bold text-uppercase">
                  Case: {{ c }}</span
                >
              </div>
              <div class="case-card border-danger" v-if="!caseList.length">
                <i class="fa-regular fa-folder-open fa-xl"></i>
                <span class="day font-weight-bold text-uppercase">
                  No case file found</span
                >
              </div>
            </div>
          </div>
        </div>
        <div class="col-md-4">
          <div class="activity-list" v-if="activityLog.length">
            <h4>Recent Activity</h4>
            <div class="item-list shadow-sm">
              <div
                class="item rounded p-2 mb-2 mx-1"
                :class="
                  a.eventLog.includes('Case')
                    ? 'border-success '
                    : 'border-primary'
                "
                v-for="(a, index) in activityLog.slice().reverse()"
                :key="index"
              >
                <h6 class="mb-1">
                  {{ a.eventLog }}
                </h6>
                <div class="d-flex justify-content-between align-items-end">
                  <small>{{ a.variableID }}</small>
                  <small class="text-muted">
                    {{ store.getDateTime(a.timestamp) }}
                  </small>
                </div>
                <small v-if="store.isAdmin"
                  ><strong>User:</strong> {{ a.userAddress }}</small
                >
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- Modal Section -->
    <div
      class="modal fade"
      id="caseModal"
      data-bs-backdrop="static"
      data-bs-keyboard="false"
      tabindex="-1"
      aria-labelledby="staticBackdropLabel"
      aria-hidden="true"
    >
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-body">
            <div class="d-flex justify-content-between align-item-center">
              <h6 class="fw-bold">Create Case File</h6>
              <button
                type="button"
                class="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              ></button>
            </div>
            <div class="row g-3">
              <div class="col-md-12">
                <label for="case-no" class="form-label">Case No.</label>
                <input
                  v-model="caseNo"
                  type="text"
                  class="form-control"
                  id="case-no"
                />
              </div>
              <div class="col-12">
                <button
                  @click="createCaseFile"
                  class="btn btn-outline-primary px-5"
                >
                  Create
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// import Web3 from "web3";
import CmContract from "../../blockchain/caseManager";
import lcContract from "../../blockchain/UserAuth";
import { useAuthStore } from "../stores/auth";
import crypto from "../mixins/crypto";

export default {
  name: "profile",
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  mixins: [crypto],
  data() {
    return {
      caseNo: "",
      activityLog: [],
      caseList: [],
    };
  },
  mounted() {
    if (this.store.getRole !== "Investigator") {
      this.getCaseAccess(this.store.user.role);
    } else {
      this.getUserCase();
    }
    if (this.store.user && !this.store.user.publicKey) {
      this.generateUserKey();
    }
    this.getUserEvents();
  },
  methods: {
    async generateUserKey() {
      try {
        this.generateKeyPair(this.store.user.name.replace(/ /g, "_"));
        this.store.updateKey(this.rsaPublicKey);
        const key = this.store.user.publicKey;

        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];

        const gasEstimate = await lcContract.methods
          .updatePublicKey(key)
          .estimateGas({ from: user });
        const gasLimit = Math.floor(gasEstimate * 1.2);

        await lcContract.methods
          .updatePublicKey(key)
          .send({ from: user, gas: gasLimit });
        this.store.toastNotification("Key pair generated !", "bg-success");
      } catch (error) {
        this.store.toastNotification(error, "bg-warning");
      }
    },
    openCaseFile(id) {
      this.$router.push({ name: "cases", params: { id: id } });
    },
    async getUserCase() {
      try {
        this.caseList = await CmContract.methods
          .getUserCaseFiles()
          .call({ from: this.store.user.wallet });
      } catch (error) {
        console.log(error);
      }
    },
    async getCaseAccess(role) {
      try {
        const response = await CmContract.methods.getCaseAccess(role).call();
        this.caseList = response.caseList;
      } catch (error) {
        console.log(error);
      }
    },
    async getUserEvents() {
      try {
        const response = await CmContract.methods
          .getUserEvents()
          .call({ from: this.store.user.wallet });
        this.activityLog = response.map((x) => ({
          eventLog: x[1],
          timestamp: x[3],
          userAddress: x[0],
          variableID: x[2],
        }));
      } catch (error) {
        console.log(error);
      }
    },
    async createCaseFile() {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];
        const gasEstimate = await CmContract.methods
          .createCaseFile(this.caseNo, this.store.user.name)
          .estimateGas({ from: user });
        const gasLimit = Math.floor(gasEstimate * 1.2);

        await CmContract.methods
          .createCaseFile(this.caseNo, this.store.user.name)
          .send({ from: user, gas: gasLimit });
        this.getUserCase();
        this.getUserEvents();
        this.store.toastNotification(
          "Case Created successfully!",
          "bg-success"
        );
      } catch (error) {
        this.store.toastNotification(error, "bg-warning");
      }
    },
    // async addSampleData() {
    //   try {
    //     await CmContract.methods
    //       .addSampleData()
    //       .call({ from: this.store.user.wallet });
    //   } catch (error) {
    //     console.log(error);
    //   }
    // },
  },
};
</script>

<style lang="scss" scoped>
.profile {
  margin-top: 90px;
  .profile-info {
    span {
      font-weight: 600;
    }
    p {
      word-wrap: break-word;
    }
  }
  .case-file {
    .cases {
      display: flex;
      // overflow-x: auto;
      flex-wrap: wrap;
      gap: 10px;
      .case-card {
        flex-basis: calc(100% / 7);
        min-width: 220px;
        border-radius: 5px;
        display: flex;
        flex-direction: column;
        padding: 10px 15px;
        margin-bottom: 5px;
        background-color: white;
        cursor: pointer;
        border: 1px solid $border-variant-1;
        transition: $transition;
        &:hover {
          box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
          border-color: $border-variant-4;
        }
        i {
          margin: 15px 0;
        }
      }
    }
  }
  .activity-list {
    .item-list {
      overflow: auto;
      max-height: 400px;
      border-left: 1px solid $border-variant-1;
      padding: 10px 5px;
      .item {
        cursor: pointer;
        border: 2px solid $border-variant-1;
        transition: $transition;
        &:hover {
          box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
          border-color: $border-variant-4;
        }
      }
    }
  }
}
</style>