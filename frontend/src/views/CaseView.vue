<template>
  <div class="container case-profile">
    <div>
      <div class="info-box shadow-sm rounded p-3 mb-3">
        <h4>Case Information</h4>
        <div class="row">
          <div class="col-md-4">
            <div class="row g-1">
              <div class="col-md-12">
                <span>Case No </span>
                <p class="mb-0">{{ id }}</p>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <span>Investigator</span>
            <p class="mb-0" v-if="propertyAccessList.investigatorName">
              {{ caseDetails.investigatorName }}
            </p>
            <p class="mb-0" v-else></p>
          </div>
          <div class="col-md-4">
            <span>Timestamp</span>
            <p class="mb-0">
              {{
                Object.keys(caseDetails).length
                  ? getDateTime(caseDetails.timeStamp)
                  : ""
              }}
            </p>
          </div>
        </div>
      </div>
      <div
        class="card shadow-sm mb-3"
        v-if="hasCaseKey || store.isInvestigator"
      >
        <div class="card-body" v-if="!this.store.rsaKey">
          <PasswordPanel
            :caseNo="id"
            :keyList="caseDetails.sharedKeys"
            @getCaseDetails="getCaseDetails"
          />
        </div>
      </div>
      <div class="card" v-else>
        <div class="card-body">
          <h6 class="mb-0 fw-bold text-danger">
            You are not authorized to access this case
          </h6>
        </div>
      </div>
      <div class="case-data-section" v-if="this.store.caseKeyExist(id)">
        <ul
          class="nav nav-tabs mb-3 border-bottom"
          id="pills-tab"
          role="tablist"
        >
          <li class="nav-item" role="presentation">
            <button
              class="nav-link active"
              id="pills-pills-entity-tab"
              data-bs-toggle="pill"
              data-bs-target="#pills-pills-entity"
              type="button"
              role="tab"
              aria-controls="pills-pills-entity"
              aria-selected="false"
            >
              <i class="fa-solid fa-users-viewfinder"></i> &nbsp; Case Entity
            </button>
          </li>
          <li
            class="nav-item"
            role="presentation"
            v-if="propertyAccessList.fileHash"
          >
            <button
              class="nav-link"
              id="pills-file-tab"
              data-bs-toggle="pill"
              data-bs-target="#pills-file"
              type="button"
              role="tab"
              aria-controls="pills-file"
              aria-selected="true"
            >
              <i class="fa-solid fa-folder-open"></i> &nbsp; Evidence File
            </button>
          </li>
        </ul>
        <div class="tab-content" id="pills-tabContent">
          <div
            class="tab-pane fade"
            id="pills-file"
            role="tabpanel"
            aria-labelledby="pills-file-tab"
          >
            <div class="entity-section">
              <div class="section-header">
                <button
                  v-if="false"
                  class="btn btn-primary"
                  @click="
                    setFileHash(
                      'WWG52FqiwNmDNoTvtcBDqUqEokSqF1M6Jq2BTSJAPsKpWD'
                    )
                  "
                >
                  Test
                </button>
                <h4 class="mb-0">Evidence File</h4>
                <hr />
                <div class="row">
                  <div
                    class="col-md-5"
                    v-if="store.isInvestigator || store.isForensic"
                  >
                    <FileUploadBox @setFileHash="setFileHash" />
                  </div>
                  <div class="col-md-7">
                    <FileSection :file-list="evidenceList" />
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="tab-pane fade show active"
            id="pills-pills-entity"
            role="tabpanel"
            aria-labelledby="pills-pills-entity-tab"
          >
            <div class="entity-section">
              <div
                class="section-header d-flex justify-content-between align-items-center border-bottom pb-2 mb-2"
              >
                <h4 class="mb-0">Entity Information</h4>
                <button
                  v-if="this.store.getRoleAccess"
                  type="button"
                  class="btn btn-primary"
                  data-bs-toggle="modal"
                  data-bs-target="#entityModal"
                  @click="openEntityModal('create')"
                >
                  <i class="fa-solid fa-plus"></i>&nbsp;Entity
                </button>
              </div>
              <div class="row g-2">
                <div class="col-md-3">
                  <div class="entity-list">
                    <div v-if="entityList.length">
                      <div
                        v-for="(x, index) in entityList"
                        :key="index"
                        class="entity-card rounded p-2 mb-2 shadow-sm"
                        :class="
                          selectedEntity.id == x.id
                            ? 'border-success bg-hover'
                            : ''
                        "
                        @click="showSelectedEntity(x.id)"
                      >
                        <h6 class="mb-0" v-if="propertyAccessList.name">
                          {{ x.name }}
                        </h6>
                        <h6 v-else class="text-muted">Redacted</h6>
                        <small class="type" :class="typeColor[x.type]">{{
                          entityType[x.type]
                        }}</small>
                      </div>
                    </div>
                    <div
                      v-else
                      class="entity-card rounded p-2 mb-2 border-danger text-center shadow-sm"
                    >
                      <h6 class="mb-0 py-2">No Entity Found</h6>
                    </div>
                  </div>
                </div>
                <div class="col-md-9">
                  <div class="evidence-board p-3 rounded shadow-sm">
                    <div
                      class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2"
                    >
                      <h6 class="fw-bold">Information Board</h6>
                      <button
                        type="button"
                        class="btn btn-primary px-4 btn-sm"
                        data-bs-toggle="modal"
                        data-bs-target="#entityModal"
                        v-if="
                          Object.keys(selectedEntity).length &&
                          store.isInvestigator
                        "
                        @click="openEntityModal('update')"
                      >
                        Update
                      </button>
                    </div>
                    <!-- <CryptoTest /> -->
                    <div
                      class="row g-2"
                      v-if="Object.keys(selectedEntity).length"
                    >
                      <div
                        class="col-md-4 col-sm-6"
                        v-if="propertyAccessList.name"
                      >
                        <label for="name" class="form-label">Name</label>
                        <p>{{ selectedEntity.name }}</p>
                      </div>
                      <div
                        class="col-md-4 col-sm-6"
                        v-if="propertyAccessList.email"
                      >
                        <label for="email" class="form-label">Email</label>
                        <p>{{ selectedEntity.email }}</p>
                      </div>
                      <div
                        class="col-md-4 col-sm-6"
                        v-if="propertyAccessList.phone"
                      >
                        <label for="email" class="form-label"
                          >Contact No.</label
                        >
                        <p>{{ selectedEntity.phone }}</p>
                      </div>
                      <div class="col-md-4 col-sm-6">
                        <label for="type" class="form-label">Type</label>
                        <p>{{ entityType[selectedEntity.type] }}</p>
                      </div>
                      <div
                        class="col-md-4 col-sm-6"
                        v-if="propertyAccessList.dob"
                      >
                        <label for="dob" class="form-label"
                          >Date of birth</label
                        >
                        <p>{{ selectedEntity.dob }}</p>
                      </div>
                      <div
                        class="col-md-4 col-sm-6"
                        v-if="propertyAccessList.gender"
                      >
                        <label for="gender" class="form-label">Gender</label>
                        <p class="text-capitalize">
                          {{ selectedEntity.gender }}
                        </p>
                      </div>
                      <div
                        class="col-md-4 col-sm-6"
                        v-if="propertyAccessList.userAddress"
                      >
                        <label for="address" class="form-label">Address</label>
                        <p>{{ selectedEntity.address }}</p>
                      </div>
                      <div
                        class="col-md-12"
                        v-if="propertyAccessList.additionalInfo"
                      >
                        <label for="adinfo" class="form-label"
                          >Additional Information</label
                        >
                        <p>{{ selectedEntity.additionalInfo }}</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Entity modal -->
    <div
      class="modal fade"
      id="entityModal"
      data-bs-backdrop="static"
      data-bs-keyboard="false"
      tabindex="-1"
      aria-labelledby="staticBackdropLabel"
      aria-hidden="true"
    >
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-body">
            <div
              class="d-flex justify-content-between align-item-center mb-2 border-bottom"
            >
              <h6 class="fw-bold">
                {{ this.formAction === "create" ? "Add New" : "Update" }} Entity
              </h6>
              <button
                type="button"
                class="btn-close btn-close-danger"
                data-bs-dismiss="modal"
                aria-label="Close"
              ></button>
            </div>
            <div class="row g-2">
              <div class="col-md-12">
                <label for="name" class="form-label">Name</label>
                <input
                  v-model="formData.name"
                  type="text"
                  class="form-control"
                  id="name"
                />
              </div>
              <div class="col-md-6">
                <label for="email" class="form-label">Email</label>
                <input
                  v-model="formData.email"
                  type="text"
                  class="form-control"
                  id="email"
                />
              </div>
              <div class="col-md-6">
                <label for="phone" class="form-label">Phone</label>
                <input
                  v-model="formData.phone"
                  type="text"
                  class="form-control"
                  id="phone"
                />
              </div>
              <div class="col-md-6">
                <label for="type" class="form-label">Party Type</label>
                <select v-model="formData.type" id="type" class="form-select">
                  <option value="0">Victim</option>
                  <option value="1">Witness</option>
                  <option value="2">Suspect</option>
                </select>
              </div>
              <div class="col-md-6">
                <label for="dob" class="form-label">Date of birth</label>
                <input
                  v-model="formData.dob"
                  type="date"
                  format="dd/mm/yyyy"
                  class="form-control"
                  id="dob"
                />
              </div>
              <div class="col-md-6">
                <label for="address" class="form-label">Address</label>
                <input
                  v-model="formData.address"
                  type="text"
                  class="form-control"
                  id="address"
                />
              </div>
              <div class="col-md-6">
                <label for="gender" class="form-label">Gender</label>
                <div class="my-2">
                  <div class="form-check form-check-inline">
                    <input
                      v-model="formData.gender"
                      class="form-check-input"
                      type="radio"
                      name="inlineRadioOptions"
                      id="inlineRadio1"
                      value="male"
                    />
                    <label class="form-check-label" for="inlineRadio1"
                      >Male</label
                    >
                  </div>
                  <div class="form-check form-check-inline">
                    <input
                      v-model="formData.gender"
                      class="form-check-input"
                      type="radio"
                      name="inlineRadioOptions"
                      id="inlineRadio2"
                      value="female"
                    />
                    <label class="form-check-label" for="inlineRadio2"
                      >Female</label
                    >
                  </div>
                </div>
              </div>
              <div class="col-md-12">
                <label for="adinfo" class="form-label"
                  >Additional Information</label
                >
                <textarea
                  v-model="formData.additionalInfo"
                  class="form-control"
                  id="adinfo"
                  rows="5"
                ></textarea>
              </div>
              <div class="col-md-12 d-grid">
                <button
                  @click="createUpdateEntity"
                  type="button"
                  class="btn btn-primary btn-block"
                >
                  {{ this.formAction === "create" ? "Create" : "Update" }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- <div class="error-window" v-else>
      <h4>Invalid Case ID</h4>
    </div> -->
  </div>
</template>

<script>
import CmContract from "../../blockchain/caseManager";
import FileSection from "../components/FileSection.vue";
import FileUploadBox from "../components/FileUploadBox.vue";
// import CryptoTest from "../components/CryptoTest.vue";
import { useAuthStore } from "../stores/auth";
import crypto from "../mixins/crypto";
import PasswordPanel from "../components/PasswordPanel.vue";

export default {
  name: "caseView",
  components: { FileUploadBox, FileSection, PasswordPanel },
  mixins: [crypto],
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  data() {
    return {
      id: this.$route.params.id,
      passphrase: "",
      caseDetails: {},
      entityList: [],
      evidenceList: [],
      entityType: {
        0: "Victim",
        1: "Witness",
        2: "Suspect",
      },
      formAction: "",
      formData: {},
      selectedEntity: {},
      propertyAccessList: {},
      typeColor: {
        0: "victim-pill",
        1: "witness-pill",
        2: "suspect-pill",
      },
    };
  },
  mounted() {
    if (this.$route.params.id) {
      this.getCaseDetails();
      this.getRoleAccessList(this.store.user.role);
    }
  },
  computed: {
    hasCaseKey() {
      if (Object.keys(this.caseDetails).length) {
        return this.caseDetails.sharedKeys.includes(this.store.user.email);
      }
      return false;
    },
  },
  methods: {
    async getRoleAccessList(role) {
      try {
        const accessList = await CmContract.methods.getRBACList(role).call();
        this.propertyAccessList = {
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
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    async getCaseDetails() {
      try {
        this.selectedEntity = {};
        const caseFile = await CmContract.methods.getCaseFile(this.id).call();
        this.caseDetails = {
          case: caseFile.caseNo,
          investigatorName: caseFile.investigatorName,
          timeStamp: caseFile.timeStamp,
          evidenceList: caseFile.evidenceList,
          sharedKeys: caseFile.sharedKeys,
          createdBy: caseFile.createdBy,
          entities: caseFile.entityList,
        };
        this.entityList = [];
        if (this.store.rsaKey || this.store.isInvestigator) {
          this.getAllEntity(caseFile.entityList);
          if (this.caseDetails.evidenceList) {
            // this.setFileHash();
            this.evidenceList = this.aesEncryptAndDecrypt(
              "decrypt",
              this.store.derivedKey,
              this.caseDetails.evidenceList
            );
          }
        }
      } catch (error) {
        console.log(error);
        this.store.toastNotification(error, "bg-warning");
      }
    },
    getAllEntity(list) {
      for (let index = 0; index < list.length; index++) {
        this.getEntityDetails(list[index]);
      }
    },
    async getEntityDetails(id) {
      try {
        const entityInfo = await CmContract.methods.getEntity(id).call();
        // console.log(entityInfo);
        const decrypted = this.aesEncryptAndDecrypt(
          "Decrypt",
          this.store.derivedKey,
          entityInfo.data
        );

        // console.log(decrypted);

        let entity = {
          id: entityInfo.entityId,
          createdBy: entityInfo.createdBy,
        };
        entity = {
          ...entity,
          ...decrypted,
        };

        this.entityList.push(entity);
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    showSelectedEntity(id) {
      this.selectedEntity = this.entityList.find((obj) => obj.id === id);
    },
    getDateTime(timestamp) {
      const date = new Date(timestamp * 1000);
      const options = {
        year: "numeric",
        month: "long",
        day: "numeric",
      };
      return `${date.toLocaleDateString(
        "en-GB",
        options
      )} - ${date.toLocaleTimeString("en-GB")}`;
    },
    generateEntityId(caseNo, name) {
      return (
        caseNo.substring(0, 3) +
        Math.random().toString(16).slice(10) +
        name.substring(0, 2)
      );
    },
    setFileHash(hash) {
      // let result = [];
      console.log(hash ? true : false);
      if (hash) {
        this.evidenceList.push(hash);
        this.updatedEvidenceFile();
      } else {
        this.evidenceList.push(hash);
      }

      console.log(this.evidenceList);

      // if (hash) {
      //   if (this.caseDetails.evidenceList.length) {
      //     result = this.aesEncryptAndDecrypt(
      //       "decrypt",
      //       this.store.derivedKey,
      //       this.caseDetails.evidenceList
      //     );
      //   }

      //   console.log(result);
      //   this.evidenceList = [...result, hash];
      //   this.updatedEvidenceFile();
      // } else {
      //   this.evidenceList = result;
      //   // console.log(this.evidenceList);
      // }
      // if (this.caseDetails.evidenceList.length) {
      //   result = this.aesEncryptAndDecrypt(
      //     "decrypt",
      //     this.store.derivedKey,
      //     this.caseDetails.evidenceList
      //   );

      //   this.evidenceList = [...result, hash];
      //     this.updatedEvidenceFile();
      // } else {
      //   // result;
      //   if (hash) {

      //   } else {
      //     this.evidenceList = result;
      //     console.log(result);
      //   }
      // }
    },
    async updatedEvidenceFile() {
      try {
        const encrypted = this.aesEncryptAndDecrypt(
          "encrypt",
          this.store.derivedKey,
          this.evidenceList
        );

        console.log(encrypted);

        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];
        const formData = {
          caseNo: this.$route.params.id,
          evidenceList: encrypted,
        };

        const gasEstimate = await CmContract.methods
          .addEvidenceFile(formData.caseNo, formData.evidenceList)
          .estimateGas({ from: user });
        const gasLimit = Math.floor(gasEstimate * 1.2);

        await CmContract.methods
          .addEvidenceFile(formData.caseNo, formData.evidenceList)
          .send({ from: user, gas: gasLimit });

        this.store.toastNotification(
          "Evidence files updated successfully!",
          "bg-success"
        );
      } catch (error) {
        console.log(error);
        this.store.toastNotification(error, "bg-warning");
      }
    },
    openEntityModal(action) {
      this.formAction = action;
      if (action === "create") {
        this.formData = {
          gender: "male",
          email: "morgan@gmail.com",
          phone: "02356966774",
          name: "Jack Morgan",
          type: "1",
          dob: "1997-06-17",
          address: "Birmingham, UK",
          additionalInfo:
            "Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptate aut nostrum voluptas debitis laudantium nesciunt, dolorem quasi, voluptatem vero quia obcaecati ab suscipit facere unde iure, tenetur deleniti autem optio!",
        };
      } else {
        this.formData = JSON.parse(JSON.stringify(this.selectedEntity));
      }
    },
    async createUpdateEntity() {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];

        var gasLimit = 0;
        var gasEstimate = 0;
        const data = JSON.parse(JSON.stringify(this.formData));

        let entityData = {
          id: data.id
            ? data.id
            : this.generateEntityId(this.$route.params.id, data.name),
          caseNo: this.$route.params.id,
        };

        entityData.content = this.aesEncryptAndDecrypt(
          "encrypt",
          this.store.derivedKey,
          data
        );

        // Calling method
        if (this.formAction === "create") {
          // data.dob = this.formatDateTime(data.dob, "combine");

          // Gas limit estimate
          gasEstimate = await CmContract.methods
            .addEntity(entityData.caseNo, entityData.id, entityData.content)
            .estimateGas({ from: user });
          gasLimit = Math.floor(gasEstimate * 1.2);

          await CmContract.methods
            .addEntity(entityData.caseNo, entityData.id, entityData.content)
            .send({ from: user, gas: gasLimit });

          this.store.toastNotification(
            "Entity added successfully!",
            "bg-success"
          );
        } else {
          // Gas limit estimate
          gasEstimate = await CmContract.methods
            .updateEntity(entityData.id, entityData.content)
            .estimateGas({ from: user });
          gasLimit = Math.floor(gasEstimate * 1.2);

          await CmContract.methods
            .updateEntity(entityData.id, entityData.content)
            .send({ from: user, gas: gasLimit });

          this.store.toastNotification(
            "Entity updated successfully!",
            "bg-success"
          );
        }

        // console.log(this.decryptedData);

        this.getCaseDetails();
      } catch (error) {
        console.log(error);
        this.store.toastNotification(error, "bg-warning");
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.case-profile {
  margin-top: 90px;
  .info-box {
    h4 {
      border-bottom: 2px solid $border-variant-1;
      padding-bottom: 5px;
    }
    border: 1px solid $border-variant-1;
    span {
      font-weight: 600;
    }
  }
  .entity-list {
    .entity-card {
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
          background: $blue;
        }
        &.suspect-pill {
          background: $red;
        }
        &.witness-pill {
          background: $green;
        }
      }
    }
  }
  .evidence-board {
    height: 100%;
    border: 1px solid $border-variant-1;
    label {
      font-weight: 600;
    }
    p {
      margin-bottom: 0;
    }
  }
}
</style>