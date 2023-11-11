<template>
  <div class="admin-panel">
    <div class="content-body">
      <div class="evidence-section">
        <div class="overview">
          <div class="section-header">
            <h4 class="mb-0">Overview</h4>
          </div>
        </div>
        <hr />
        <div class="row g-3 justify-content-between">
          <div class="col-md-3 role-list p-2">
            <div class="row g-2" v-if="Object.keys(roleList).length">
              <div
                class="col-md-12 col-sm-6 role-card rounded p-3 d-flex justify-content-between align-items-center mb-2"
                :class="selectedRole == index ? 'border-success bg-hover' : ''"
                v-for="(x, index) in roleList"
                :key="index"
                @click="getRoleAccessList(index)"
              >
                <h6 class="mb-0">{{ x.name }}</h6>
                <i class="fa-solid fa-xl" :class="x.icon"></i>
              </div>
            </div>
            <div v-else class="role-card rounded">
              <h6 class="mb-0 py-2">No Entity Found</h6>
            </div>
          </div>
          <div class="col-md-9">
            <div class="evidence-board p-2">
              <div
                class="header d-flex justify-content-between align-items-center pb-3 mb-3"
              >
                <h6 class="fw-bold mb-0">Information Permission Panel</h6>
                <div class="action-btn">
                  <button
                    type="button"
                    class="btn btn-outline-primary btn-sm"
                    @click="updateRolePropertyAccessList"
                  >
                    Save Changes
                  </button>
                  <button
                    type="button"
                    class="btn btn-primary btn-sm"
                    data-bs-toggle="modal"
                    data-bs-target="#roleCaseModal"
                  >
                    <i class="fa-solid fa-shield-halved"></i>&nbsp;Case Access
                  </button>
                </div>
              </div>
              <div class="row g-3 mb-3">
                <div class="col-md-4 col-sm-6">
                  <div
                    class="access-card rounded d-flex justify-content-between"
                  >
                    <label class="form-check-label">Investigator Name</label>
                    <div class="form-check form-switch mb-0">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        v-model="selectedRoleList.investigatorName"
                      />
                    </div>
                  </div>
                </div>
                <div class="col-md-4 col-sm-6">
                  <div
                    class="access-card rounded d-flex justify-content-between"
                  >
                    <label class="form-check-label">File Hash</label>
                    <div class="form-check form-switch mb-0">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        v-model="selectedRoleList.fileHash"
                      />
                    </div>
                  </div>
                </div>
                <div class="col-md-4 col-sm-6">
                  <div
                    class="access-card rounded d-flex justify-content-between"
                  >
                    <label class="form-check-label">Name</label>
                    <div class="form-check form-switch mb-0">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        v-model="selectedRoleList.name"
                      />
                    </div>
                  </div>
                </div>
                <div class="col-md-4 col-sm-6">
                  <div
                    class="access-card rounded d-flex justify-content-between"
                  >
                    <label class="form-check-label">Email</label>
                    <div class="form-check form-switch mb-0">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        v-model="selectedRoleList.email"
                      />
                    </div>
                  </div>
                </div>
                <div class="col-md-4 col-sm-6">
                  <div
                    class="access-card rounded d-flex justify-content-between"
                  >
                    <label class="form-check-label">Address</label>
                    <div class="form-check form-switch mb-0">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        v-model="selectedRoleList.userAddress"
                      />
                    </div>
                  </div>
                </div>
                <div class="col-md-4 col-sm-6">
                  <div
                    class="access-card rounded d-flex justify-content-between"
                  >
                    <label class="form-check-label">Gender</label>
                    <div class="form-check form-switch mb-0">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        v-model="selectedRoleList.gender"
                      />
                    </div>
                  </div>
                </div>
                <div class="col-md-4 col-sm-6">
                  <div
                    class="access-card rounded d-flex justify-content-between"
                  >
                    <label class="form-check-label">Phone</label>
                    <div class="form-check form-switch mb-0">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        v-model="selectedRoleList.phone"
                      />
                    </div>
                  </div>
                </div>
                <div class="col-md-4 col-sm-6">
                  <div
                    class="access-card rounded d-flex justify-content-between"
                  >
                    <label class="form-check-label">Date of Birth</label>
                    <div class="form-check form-switch mb-0">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        v-model="selectedRoleList.dob"
                      />
                    </div>
                  </div>
                </div>
                <div class="col-md-4 col-sm-6">
                  <div
                    class="access-card rounded d-flex justify-content-between"
                  >
                    <label class="form-check-label"
                      >Additional Information</label
                    >
                    <div class="form-check form-switch mb-0">
                      <input
                        class="form-check-input"
                        type="checkbox"
                        v-model="selectedRoleList.additionalInfo"
                      />
                    </div>
                  </div>
                </div>
              </div>
              <div class="role-case-list">
                <h6 class="fw-bold">Case Files</h6>
                <div v-if="roleCaseList.length" class="cases">
                  <div
                    class="case-card"
                    v-for="(c, index) in roleCaseList.slice().reverse()"
                    :key="index"
                    @click="openCaseFile(c)"
                  >
                    <span class="day font-weight-bold text-uppercase">
                      Case: {{ c }}</span
                    >
                  </div>
                </div>
                <div v-else class="case-card">
                  <small
                    class="fw-bold text-capitalize text-danger"
                    v-if="selectedRole != 0"
                  >
                    No case file found
                  </small>
                </div>
              </div>
            </div>
          </div>
        </div>
        <hr />
        <UserActivity />
      </div>
    </div>

    <!-- Modal Section -->

    <div
      class="modal fade"
      id="roleCaseModal"
      data-bs-backdrop="static"
      data-bs-keyboard="false"
      tabindex="-1"
      aria-labelledby="staticBackdropLabel"
      aria-hidden="true"
    >
      <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-body">
            <div class="d-flex justify-content-between align-item-center mb-2">
              <h6 class="fw-bold">Grant Access to Case Files</h6>
              <button
                type="button"
                class="btn-close"
                data-bs-dismiss="modal"
                aria-label="Close"
              ></button>
            </div>
            <p class="mb-4">
              <strong>Selected:</strong> {{ selectedCaseAccessList.join(", ") }}
            </p>
            <div class="row g-2">
              <div
                v-for="(c, index) in caseList.slice().reverse()"
                :key="index"
                class="col-md-6 col-sm-6"
              >
                <div class="border p-2 rounded d-flex justify-content-between">
                  <label class="form-check-label">{{ c }}</label>
                  <div class="form-check mb-0">
                    <input
                      class="form-check-input"
                      type="checkbox"
                      :value="c"
                      v-model="selectedCaseAccessList"
                    />
                  </div>
                </div>
              </div>
              <div class="col-md-12 mt-4">
                <button
                  class="btn btn-outline-primary btn-sm px-5 py-2"
                  @click="updateRoleCaseAccessList"
                >
                  Submit
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
import CmContract from "../../blockchain/caseManager";
import { useAuthStore } from "../stores/auth";
import UserActivity from "../components/UserActivity.vue";
export default {
  name: "AdminPanel",
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  props: {
    caseList: {
      type: Array,
      default: () => [],
    },
  },
  components: {
    UserActivity,
  },
  data() {
    return {
      email: "",
      password: "",
      isVerified: false,
      selectedRole: null,
      selectedRoleList: {},
      roleCaseList: [],
      selectedCaseAccessList: [],
      roleList: {
        0: {
          name: "Investigator",
          icon: "fa-user-secret",
        },
        1: {
          name: "Forensic Analyst",
          icon: "fa-user-shield",
        },
        2: {
          name: "Judge",
          icon: "fa-user-tie",
        },
        3: {
          name: "Jury",
          icon: "fa-users",
        },
      },
    };
  },
  mounted() {
    // this.getCaseAccessList();
  },
  methods: {
    async updateRolePropertyAccessList() {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];
        const formData = this.selectedRoleList;
        formData.role = Number(this.selectedRole);
        const {
          role,
          additionalInfo,
          dob,
          email,
          fileHash,
          gender,
          investigatorName,
          name,
          phone,
          userAddress,
        } = formData;

        const gasEstimate = await CmContract.methods
          .updateAccessList(
            role,
            additionalInfo,
            dob,
            email,
            fileHash,
            gender,
            investigatorName,
            name,
            phone,
            userAddress
          )
          .estimateGas({ from: user });
        const gasLimit = Math.floor(gasEstimate * 1.2);

        await CmContract.methods
          .updateAccessList(
            role,
            investigatorName,
            fileHash,
            name,
            email,
            gender,
            dob,
            phone,
            userAddress,
            additionalInfo
          )
          .send({ from: user, gas: gasLimit });

        this.store.toastNotification(
          "Information Access Updated",
          "bg-success"
        );
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    async updateRoleCaseAccessList() {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];
        const gasEstimate = await CmContract.methods
          .updateCaseAccess(this.selectedRole, this.selectedCaseAccessList)
          .estimateGas({ from: user });
        const gasLimit = Math.floor(gasEstimate * 1.2);

        await CmContract.methods
          .updateCaseAccess(this.selectedRole, this.selectedCaseAccessList)
          .send({ from: user, gas: gasLimit });

        this.getCaseAccessList(this.selectedRole);
        this.store.toastNotification("Case Access List Updated!", "bg-success");
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    async getRoleAccessList(role) {
      try {
        const accessList = await CmContract.methods.getRBACList(role).call();
        this.selectedRole = role;
        this.selectedRoleList = {
          additionalInfo: accessList.additionalInfo,
          dob: accessList.dob,
          email: accessList.email,
          fileHash: accessList.fileHash,
          gender: accessList.gender,
          investigatorName: accessList.investigatorName,
          name: accessList.name,
          phone: accessList.phone,
          userAddress: accessList.userAddress,
        };
        this.getCaseAccessList(role);
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    async getCaseAccessList(role) {
      try {
        const response = await CmContract.methods.getCaseAccess(role).call();
        this.roleCaseList = response.caseList;
        this.selectedCaseAccessList = response.caseList;
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    async addSampleData() {
      try {
        const allCaseFiles = await CmContract.methods.getAllCaseFiles().call();
        console.log(allCaseFiles);
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    openCaseFile(id) {
      this.$router.push({ name: "cases", params: { id: id } });
    },
  },
};
</script>

<style lang="scss" scoped>
.admin-panel {
  margin-bottom: 40px;
  .content-body {
    .case-list {
      margin: 15px 0;
      .cases {
        display: flex;
        overflow-x: auto;
        gap: 10px;
        .case-card {
          flex-basis: calc(100% / 7);
          min-width: 180px;
          border-radius: 5px;
          // margin-bottom: 5px;
          display: flex;
          flex-direction: column;
          padding: 10px;
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
    .role-list {
      .role-card {
        cursor: pointer;
        border: 1px solid $border-variant-1;
        transition: $transition;
        &:hover {
          box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
          border-color: $border-variant-4;
        }
        .type {
          display: inline-block;
          padding: 0.35em 0.65em;
          font-size: 0.75em;
          font-weight: 700;
          line-height: 1;
          color: #fff;
          border-radius: 10px;
          text-align: center;
          white-space: nowrap;
          vertical-align: baseline;
          &.victim-pill {
            background: $green;
          }
          &.suspect-pill {
            background: $red;
          }
          &.witness-pill {
            background: $blue;
          }
        }
      }
    }
    .evidence-board {
      border-left: 1px solid $border-variant-1;
      border-right: 1px solid $border-variant-1;

      .header {
        border-bottom: 1px solid $border-variant-1;
      }
      .access-card {
        padding: 10px;
        border: 1px solid $border-variant-1;
        transition: $transition;
        label {
          font-size: 14px;
          font-weight: 500;
        }
        .form-switch input {
          cursor: pointer;
        }
      }
      .role-case-list {
        margin: 20px 0;
        .cases {
          display: flex;
          overflow-x: auto;
          gap: 10px;
          .case-card {
            flex-basis: calc(100% / 7);
            min-width: 180px;
            border-radius: 5px;
            margin-bottom: 10px;
            display: flex;
            flex-direction: column;
            padding: 10px;
            background-color: white;
            cursor: pointer;
            border: 1px solid $border-variant-1;
            transition: $transition;
            &:hover {
              box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
              border-color: $border-variant-4;
            }
          }
        }
      }
    }
  }
}
</style>
