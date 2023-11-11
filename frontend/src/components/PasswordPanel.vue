<template>
  <div class="password-panel">
    <div class="row g-4" v-if="this.store.isInvestigator">
      <div class="col-md-6 mb-sm-4 mb-md-0">
        <h6 class="fw-bold">Please enter case passphrase</h6>
        <div class="input-group mb-2">
          <input
            v-model="passphrase"
            type="password"
            class="form-control"
            placeholder="Enter Passphrase"
            aria-label="Enter Passphrase"
            aria-describedby="button-addon2"
            :disabled="this.store.caseKeyExist(caseNo)"
          />
          <button
            class="btn btn-primary"
            type="button"
            id="button-addon2"
            :disabled="!this.passphrase.length"
            @click="generateKey"
          >
            Generate
          </button>
        </div>
        <small
          class="fw-bold text-success"
          :class="
            this.store.caseKeyExist(caseNo) ? ' text-success' : ' text-danger'
          "
        >
          Case Passphrase
          {{ this.store.caseKeyExist(caseNo) ? "Found" : "Not Found" }}
        </small>
      </div>
      <div class="col-md-6">
        <h6 class="fw-bold">Share File Key</h6>
        <div
          class="d-flex align-items-center flex-wrap entity-access mb-2"
          v-if="this.store.caseKeyExist(caseNo)"
        >
          <div
            class="border p-2 rounded d-flex align-items-start"
            v-for="(c, index) in userList.slice().reverse()"
            :key="index"
          >
            <input
              class="form-check-input"
              type="checkbox"
              v-model="selectedEntityAccessList"
              :value="c.email"
              :id="index"
              :disabled="c.email === 'admin@gmail.com'"
            />
            <label class="form-check-label" :for="index">
              <span>{{ c.name }}</span>
              <small class="text-muted">
                {{ store.roles[c.role] }}
              </small>
            </label>
          </div>
        </div>
        <div class="mb-2" v-else>
          <p class="text-danger">Passphrase required to proceed</p>
        </div>
        <button
          v-if="this.store.caseKeyExist(caseNo)"
          class="btn btn-outline-primary btn-sm px-4 py-2"
          @click="shareKeys"
        >
          Submit
        </button>
      </div>
    </div>
    <div class="private-key" v-else>
      <h6 class="fw-bold">
        Please enter your private key to view case information
      </h6>
      <textarea
        class="form-control mb-2"
        id="floatingTextarea2"
        v-model="privateKey"
        style="height: 150px"
      ></textarea>
      <button
        class="btn btn-outline-primary btn-sm px-4 py-2"
        type="button"
        id="button-addon2"
        @click="setRsaKey()"
      >
        Verify Key
      </button>
    </div>
  </div>
</template>

<script>
import lcContract from "../../blockchain/userAuth";
import CmContract from "../../blockchain/caseManager";
import { useAuthStore } from "../stores/auth";
import crypto from "../mixins/crypto";

export default {
  name: "PasswordPanel",
  props: {
    caseNo: {
      type: String,
      default: "",
    },
    keyList: {
      type: Array,
      default: () => [],
    },
  },
  mixins: [crypto],
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  data() {
    return {
      passphrase: "",
      privateKey: "",
      selectedEntityAccessList: [],
      userList: [],
      sharedKeyList: [],
      test: [],
    };
  },
  mounted() {
    if (this.store.isInvestigator) {
      this.getAllUsers();
    }
  },
  methods: {
    generateKey() {
      const cipherKey = this.deriveAESKey(this.passphrase);
      this.store.storeGeneratedKey(cipherKey, this.caseNo);
      this.passphrase = "";
      this.$router.go(0);
    },
    setRsaKey() {
      this.store.storePrivateKey(this.privateKey);
      this.getUserKey(this.store.user.email);
    },
    async getAllUsers() {
      try {
        const allUsers = await lcContract.methods.getAllUsers().call();
        const result = allUsers.filter(
          (item) => item.toLowerCase() !== this.store.user.wallet.toLowerCase()
        );
        for (let index = 0; index < result.length; index++) {
          this.getUserInfo(result[index]);
        }
      } catch (error) {
        console.log(error);
      }
    },
    async getUserInfo(user) {
      try {
        const userDetails = await lcContract.methods.getUserInfo(user).call();
        const userInfo = {
          name: userDetails[0],
          email: userDetails[1],
          role: userDetails[2],
          publicKey: userDetails[3],
        };
        this.userList.push(userInfo);
      } catch (error) {
        console.log(error);
      }
    },
    async getUserKey(id) {
      try {
        const key = await CmContract.methods.getSharedKey(id).call();
        console.log(key.key);
        const derivedKey = this.rsaEncryptAndDecrypt(
          "decrypt",
          this.store.rsaKey,
          key.key
        );
        this.store.storeGeneratedKey(derivedKey, this.caseNo);
        this.privateKey = "";
        this.$emit("getCaseDetails");
        this.$router.go(0);
      } catch (error) {
        console.log(error);
      }
    },
    shareKeys() {
      let users = [];
      let result = [];

      if (this.selectedEntityAccessList.length) {
        this.selectedEntityAccessList.forEach((key) => {
          users.push(this.userList.filter((x) => x.email === key)[0]);
        });

        for (let index = 0; index < users.length; index++) {
          let encryptedKey = this.rsaEncryptAndDecrypt(
            "encrypt",
            users[index].publicKey,
            this.store.derivedKey
          );

          let sharedKeys = {
            id: users[index].email,
            role: users[index].role,
            key: encryptedKey,
          };
          this.createSharedKeyList(sharedKeys);
          result.push(sharedKeys);
        }
      }
      this.sharedKeyList = result;
      this.updateCaseSharedKeyList();
    },
    async updateCaseSharedKeyList() {
      const formData = this.sharedKeyList.map((x) => x.id);
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];
        const gasEstimate = await CmContract.methods
          .updateSharedKeysInCaseFile(this.caseNo, formData)
          .estimateGas({ from: user });
        const gasLimit = Math.floor(gasEstimate * 1.2);

        await CmContract.methods
          .updateSharedKeysInCaseFile(this.caseNo, formData)
          .send({ from: user, gas: gasLimit });

        this.$emit("getCaseDetails");
        this.store.toastNotification(
          "Case Shared Key List Updated!",
          "bg-success"
        );
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
    async createSharedKeyList(key) {
      try {
        const accounts = await window.ethereum.request({
          method: "eth_requestAccounts",
        });
        const user = accounts[0];
        const gasEstimate = await CmContract.methods
          .createSharedKey(this.caseNo, key.id, key.role, key.key)
          .estimateGas({ from: user });
        const gasLimit = Math.floor(gasEstimate * 1.2);

        await CmContract.methods
          .createSharedKey(this.caseNo, key.id, key.role, key.key)
          .send({ from: user, gas: gasLimit });

        // this.getCaseAccessList(this.selectedRole);
        this.store.toastNotification("Shared Key generated", "bg-success");
      } catch (error) {
        console.log(error);
        this.store.toastNotification("Error occurred try again", "bg-warning");
      }
    },
  },
  watch: {
    keyList(newKeyList) {
      this.selectedEntityAccessList = newKeyList;
    },
  },
};
</script>

<style lang="scss" scoped>
.entity-access {
  gap: 10px;
  border-bottom: 1px solid $border-variant-2;
  padding-bottom: 10px;
  label {
    cursor: pointer;
    padding-inline: 10px;
    display: flex;
    flex-direction: column;
    span {
      margin-bottom: 0;
    }
  }
}
</style>