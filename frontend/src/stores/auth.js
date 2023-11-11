import { defineStore } from 'pinia';

export const useAuthStore = defineStore({
  id: 'auth',
  state: () => ({
    isAuth: false,
    user: null,
    roles: {
      0: "Investigator",
      1: "Forensic Analyst",
      2: "Judge",
      3: "Jury",
      4: "Admin"
    },
    derivedKey: "",
    rsaKey: '',
    caseNo: '',
    message: "",
    variant: "",
    showNotification: false,
    isRoleAccess: false,
  }),
  getters: {
    isAuthenticated() {
      return this.isAuth;
    },
    getRole() {
      return this.roles[this.user ? this.user.role : 0];
    },
    getRoleAccess() {
      // const access = false;
      return this.getRole !== "Investigator" ? false : true;
    },
    isAdmin() {
      return this.getRole === "Admin";
    },
    isInvestigator() {
      return this.getRole === "Investigator";
    },
    isForensic() {
      return this.getRole === "Forensic Analyst";
    },
  },
  actions: {
    login(user) {
      this.isAuth = true;
      this.user = user;
      localStorage.setItem('user', JSON.stringify(user));
    },
    logout() {
      this.isAuth = false;
      this.user = null;
      localStorage.removeItem('user');
      localStorage.removeItem('key');
      localStorage.removeItem('rsaKey');
    },
    caseKeyExist(caseNo) {
      const savedKey = localStorage.getItem('key');
      const result = savedKey ? JSON.parse(savedKey).caseNo : '';
      return result === caseNo;
    },
    updateKey(key) {
      if (this.user) {
        this.user.publicKey = key;
        localStorage.setItem('user', JSON.stringify(this.user));
      } else {
        console.log('Error user not exists');
      }
    },
    storeGeneratedKey(key, caseNo) {
      this.derivedKey = key;
      this.caseNo = caseNo;
      localStorage.setItem('key', JSON.stringify({
        key: key,
        caseNo: caseNo
      }));
    },
    storePrivateKey(key) {
      this.rsaKey = key;
      localStorage.setItem('rsaKey', JSON.stringify({
        key: key,
      }));
    },
    initialize() {
      // Check for saved user data on app initialization
      const savedUser = localStorage.getItem('user');
      const savedKey = localStorage.getItem('key');
      const rsaKey = localStorage.getItem('rsaKey');
      if (savedUser) {
        this.isAuth = true;
        this.user = JSON.parse(savedUser);
        this.derivedKey = savedKey ? JSON.parse(savedKey).key : '';
        this.caseNo = savedKey ? JSON.parse(savedKey).caseNo : '';
        this.rsaKey = rsaKey ? JSON.parse(rsaKey).key : '';
      }
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
    toastNotification(message, variant) {
      this.message = message;
      this.variant = variant;
      this.showNotification = true;
      setTimeout(() => {
        this.showNotification = false;
      }, 3000);
    }
  },
});