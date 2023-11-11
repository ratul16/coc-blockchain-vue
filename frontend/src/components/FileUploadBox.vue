<template>
  <div class="file-input-box">
    <div class="wrapper-file-input">
      <div class="input-box" @click="openFileInput">
        <h4>
          <i class="fa-solid fa-upload"></i>
          Choose file to upload
        </h4>
        <input ref="fileInput" type="file" hidden @change="handleFileChange" />
      </div>
    </div>
    <div class="wrapper-file-section">
      <div class="selected-files" v-if="selectedFile">
        <p class="fw-bold mb-1">Selected Files</p>
        <ul class="file-list">
          <li class="item d-block">
            <p class="mb-0">{{ selectedFile ? selectedFile.name : "" }}</p>
            <span class="fw-bold">{{
              this.cid ? `File hash: ${this.cid}` : ""
            }}</span>
          </li>
        </ul>
      </div>
    </div>
    <hr />
    <div v-if="false">
      <div class="btn btn-primary" @click="encryptMessage()">Encrypt</div>
      <div class="btn btn-primary" @click="decryptMessage()">Decrypt</div>
      <p>
        {{ message }}
      </p>
      <hr />
      <h6>encrypt: {{ encrypted }}</h6>
      <hr />
      <h6>Decrypt: {{ decrypted }}</h6>
      <div class="my-4">
        <input
          class="form-control"
          type="file"
          id="evidenceFile"
          ref="doc"
          @change="handleFileInput"
        />
        <button @click="encryptFile">Encrypt File</button>
        <button @click="decryptFile">Decrypt File</button>
      </div>
    </div>
  </div>
</template>

<script>
import { create } from "ipfs-http-client";
import { useAuthStore } from "../stores/auth";

export default {
  name: "FileUploadBox",
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  data() {
    return {
      ipfs: null,
      cid: "",
      selectedFile: null,
      isloading: false,
      encrypted: "",
      decrypted: "",
      key: "yolo",
      message: "Hello World",
      encryptedFile: null,
      decryptedFile: null,
    };
  },
  mounted() {
    this.ipfs = create({ host: "localhost", port: 5001, protocol: "http" });
  },
  methods: {
    async uploadFile() {
      if (!this.selectedFile) {
        this.store.toastNotification(
          "Please select a file to upload.",
          "bg-warning"
        );
        return;
      }
      try {
        const fileData = {
          name: this.selectedFile.name,
          type: this.selectedFile.type,
          content: this.selectedFile,
        };
        const fileID = await this.ipfs.add(fileData);
        this.cid = fileID.cid.toString();
        this.$emit("setFileHash", this.cid);
        // console.log(this.cid);
        setTimeout(() => {
          this.cid = "";
        }, 3000);

        this.store.toastNotification(
          "File uploaded successfully!",
          "bg-success"
        );
      } catch (error) {
        console.error("Error uploading file:", error);
        this.store.toastNotification("Error uploading file", "bg-danger");
      }
    },
    openFileInput() {
      this.$refs.fileInput.click();
    },
    handleFileChange(event) {
      const file = event.target.files[0];
      this.selectedFile = file;
      this.uploadFile();
    },
    // ----------------------
    encryptMessage() {
      this.encrypted = this.$CryptoJS.AES.encrypt(
        this.message,
        this.key
      ).toString();
    },
    decryptMessage() {
      this.decrypted = this.$CryptoJS.AES.decrypt(
        this.encrypted,
        this.key
      ).toString(this.$CryptoJS.enc.Utf8);
    },
    handleFileInput(event) {
      const fileRead = this.$refs.doc.files[0];
      this.readFile(fileRead);
    },
    readFile(file) {
      const reader = new FileReader();
      // reader.onload = (event) => {
      //   const fileContent = event.target.result;
      //   // Do something with the file content
      //   // console.log();
      //   this.selectedFile = fileContent;
      // };
      this.selectedFile = reader.readAsText(file);
    },
    encryptFile() {
      console.log("func called");
      if (this.selectedFile) {
        console.log("file exists");
        const reader = new FileReader();
        reader.onload = () => {
          const fileContent = reader.result;
          const encryptedData = this.$CryptoJS.AES.encrypt(
            fileContent,
            this.key
          ).toString();
          this.encryptedFile = new Blob([encryptedData], {
            type: this.selectedFile.type,
          });
        };
        reader.readAsDataURL(this.selectedFile);
      }
    },
    decryptFile() {
      if (this.encryptedFile) {
        const reader = new FileReader();
        reader.onload = () => {
          const encryptedContent = reader.result;
          const decryptedData = this.$CryptoJS.AES.decrypt(
            encryptedContent,
            this.key
          ).toString(this.$CryptoJS.enc.Utf8);
          const byteArray = this.$CryptoJS.enc.Base64.parse(decryptedData);
          const uint8Array = new Uint8Array(byteArray.words.length * 4);
          for (let i = 0; i < byteArray.words.length; i++) {
            const word = byteArray.words[i];
            uint8Array[i * 4] = word >> 24;
            uint8Array[i * 4 + 1] = (word >> 16) & 0xff;
            uint8Array[i * 4 + 2] = (word >> 8) & 0xff;
            uint8Array[i * 4 + 3] = word & 0xff;
          }
          this.decryptedFile = new Blob([uint8Array], {
            type: this.selectedFile.type,
          });
        };
        reader.readAsText(this.encryptedFile);
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.file-input-box {
  display: flex;
  justify-content: center;
  flex-direction: column;
  border-radius: 10px;
  border: 1px solid $border-variant-4;
  width: 100%;
  height: auto;
  // background-color: $white;
  padding: 10px;

  .input-box {
    padding: 20px;
    display: grid;
    place-items: center;
    border: 2px dashed $border-variant-1;
    border-radius: 5px;
    margin-bottom: 5px;
    cursor: pointer;

    h4 {
      margin: 0;
      font-size: 20px;
    }
  }

  .wrapper-file-section {
    .selected-files {
      h5 {
        margin-bottom: 10px;
      }
      .file-list {
        overflow-y: auto;
        list-style-type: none;
        padding: 0;
        margin: 0;
        transition: 0.3s all ease-in-out;

        .item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          border: 1px solid $border-variant-2;
          border-radius: 5px;
          padding: 10px;
          font-size: 14px;
        }
      }
    }
  }
}
</style>
