import JSEncrypt from 'jsencrypt'; // Import JSEncrypt library

export default {
  data() {
    return {
      message: "",
      rsaPublicKey: "",
      rsaPrivateKey: "",
      encryptedKey: "",
      decryptedKey: "",
      rsa_decrypt: "",
      aesKey: "",
      password: "",
      salt: import.meta.env.VITE_SALT,
      formData: {
        gender: "",
        email: "",
        phone: "",
        name: "",
        type: "",
        dob: "",
        address: "",
        additionalInfo:
          "",
      },
      encryptedData: "",
      decryptedData: null,
    };
  },
  methods: {
    aesEncryptAndDecrypt(action, password, data) {
      const aesKey = this.deriveAESKey(password);
      var result = null;

      if (action === "encrypt") {
        const content = JSON.stringify(data);
        // Encrypt the content using AES-CBC mode
        const encryptedData = this.$CryptoJS.AES.encrypt(content, aesKey);
        result = encryptedData.toString();
        // console.log(result);
      } else {
        // Decrypt the encrypted data
        const decryptedData = this.$CryptoJS.AES.decrypt(
          data,
          aesKey
        );
        result = JSON.parse(
          decryptedData.toString(this.$CryptoJS.enc.Utf8)
        );
        // console.log(result);
      }
      return result;
    },
    deriveAESKey(password) {
      // Derive the AES key using PBKDF2-SHA256
      const derivedKey = this.$CryptoJS.PBKDF2(password, this.salt, {
        keySize: 256 / 32, // AES-256 key size is 256 bits, or 32 bytes
        iterations: 1000,
        hasher: this.$CryptoJS.algo.SHA256,
      });
      this.aesKey = derivedKey.toString();
      return derivedKey.toString();
    },
    generateKeyPair(name) {
      const crypt = new JSEncrypt({ default_key_size: 1024 });
      const publicKey = crypt.getPublicKey();
      const privateKey = crypt.getPrivateKey();
      // console.log(publicKey);
      this.rsaPublicKey = publicKey
        .replace(/-----BEGIN PUBLIC KEY-----|-----END PUBLIC KEY-----/g, "")
        .trim();

      // Download RSA key pair
      const keysText = `${publicKey}\n\n\n${privateKey}`;
      const blob = new Blob([keysText], { type: "text/plain" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `${name}_rsa_keys.txt`;
      a.click();

      // Clean up
      URL.revokeObjectURL(url);
    },
    rsaEncryptAndDecrypt(action, rsaKey, aesKey) {
      const crypt = new JSEncrypt();
      var result = null;

      if (action === "encrypt") {
        crypt.setPublicKey(rsaKey);

        const encryptedKey = crypt.encrypt(aesKey);
        result = encryptedKey.toString();
        console.log(encryptedKey);
      } else {
        crypt.setPrivateKey(rsaKey);

        const decryptedKey = crypt.decrypt(aesKey);
        console.log(decryptedKey);
        result = decryptedKey;
      }
      return result;
    },
    encryptMessage() {
      if (!this.rsaPublicKey) {
        console.error("Public key is missing. Generate key pair first.");
        return;
      }
      const crypt = new JSEncrypt();
      crypt.setPublicKey(this.rsaPublicKey);

      this.encryptedKey = crypt.encrypt(this.aesKey);
      console.log(this.encryptedKey);
    },
    decryptMessage() {
      if (!this.rsaPrivateKey) {
        console.error("Private key is missing. Generate key pair first.");
        return;
      }

      const crypt = new JSEncrypt();
      crypt.setPrivateKey(this.rsaPrivateKey);

      this.decryptedKey = crypt.decrypt(this.encryptedKey);
      console.log(this.decryptedKey);
    },
  },
};
