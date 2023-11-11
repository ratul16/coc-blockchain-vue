<template>
  <div class="container dashboard">
    <div class="content-body">
      <div class="info-box shadow-sm rounded p-3 mb-3">
        <div
          class="d-flex justify-content-between align-items-center border-bottom border-2 pb-2 mb-2"
        >
          <h4 class="mb-0">Dashboard</h4>
          <div class="action-btn">
            <button
              class="btn btn-secondary btn-sm"
              type="button"
              data-bs-toggle="collapse"
              data-bs-target="#case-list"
              aria-expanded="false"
              aria-controls="case-list"
            >
              <i class="fa-solid fa-list"></i>&nbsp;Show Cases
            </button>
          </div>
        </div>
        <div class="row" v-if="store.isAuth">
          <div class="col-md-3">
            <div class="row g-1">
              <div class="col-md-12">
                <span>Name</span>
                <p class="mb-0">{{ store.user.name }}</p>
              </div>
            </div>
          </div>
          <div class="col-md-6">
            <span>Address</span>
            <p class="mb-0">{{ store.user.wallet }}</p>
          </div>
          <div class="col-md-3">
            <span>Role</span>
            <p class="mb-0">{{ store.getRole }}</p>
          </div>
        </div>
      </div>
      <div class="info-section" v-if="store.getRole !== 'Admin'">
        <!-- <div class="case-list">
          <div
            class="section-header d-flex justify-content-between align-items-center"
          >
            <h4 class="mb-0">Case Files</h4>
            <button
              type="button"
              class="btn btn-primary"
              data-bs-toggle="modal"
              data-bs-target="#caseModal"
            >
              New Case File
            </button>
          </div>
          <hr />
          <div class="cases">
            <div
              class="case-card"
              v-for="(c, index) in caseList.slice().reverse()"
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
        </div> -->
        <div class="evidence-section">
          <div class="row g-2">
            <div class="col-md-7">
              <div class="info-box border shadow-sm rounded p-3">
                <h4>Activity History</h4>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div v-else>
        <div class="collapse" id="case-list">
          <div class="case-list">
            <div class="cases">
              <div
                class="case-card"
                v-for="(c, index) in caseList.slice().reverse()"
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
        <AdminPanel :case-list="caseList" />
      </div>
    </div>
    <!-- Case Modal -->
  </div>
</template>

<script>
import AdminPanel from "../components/AdminPanel.vue";
import CmContract from "../../blockchain/caseManager";
import { useAuthStore } from "../stores/auth";
export default {
  name: "dashboard",
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  components: {
    AdminPanel,
  },
  data() {
    return {
      caseNo: "",
      name: "",
      age: "",
      gender: "",
      evidenceFile: null,
      evidenceDetails: "",
      caseList: [],
    };
  },
  mounted() {
    if (this.store.isAdmin) {
      this.getAllCase();
    } else {
      this.getUserCase();
    }
  },
  methods: {
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
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    async getAllCase() {
      try {
        this.caseList = await CmContract.methods.getAllCaseFiles().call();
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.dashboard {
  margin-top: 90px;
  .content-body {
    .info-box {
      border: 1px solid $border-variant-1;
      span {
        font-weight: 600;
      }
      p {
        word-wrap: break-word;
      }
    }
    .case-list {
      margin-bottom: 15px;
      .cases {
        display: flex;
        overflow-x: auto;
        gap: 10px;
        .case-card {
          flex-basis: calc(100% / 7);
          min-width: 220px;
          border-radius: 5px;
          margin-bottom: 10px;
          display: flex;
          flex-direction: column;
          padding: 20px;
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
  }
}
</style>