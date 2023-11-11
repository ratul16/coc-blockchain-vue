<template>
  <div class="user-activity">
    <div class="section-header mb-3">
      <h4 class="mb-0">User Activity</h4>
    </div>
    <div class="row">
      <div class="col-md-4">
        <div class="row user-list" v-if="userActivityList.length">
          <div
            class="col-md-12 user-card rounded p-3 d-flex justify-content-between align-items-center mb-2"
            :class="selectedUser == x.email ? 'border-success bg-hover' : ''"
            v-for="(x, index) in userActivityList"
            :key="index"
            @click="showUserEvents(x.email)"
          >
            <div>
              <h6 class="mb-0 d-block">{{ x.name }}</h6>
              <small class="text-muted">{{ roleList[x.role].name }}</small>
            </div>
            <i class="fa-solid fa-xl" :class="roleList[x.role].icon"></i>
          </div>
        </div>
        <div v-else class="user-card rounded">
          <h6 class="mb-0 py-2">No User Found</h6>
        </div>
      </div>
      <div class="col-md-8">
        <div class="user-activity-list p-2">
          <div
            class="header d-flex justify-content-between align-items-center pb-3 mb-3"
          >
            <h6 class="fw-bold mb-0">Activity History</h6>
            <div class="action-btn">
              <button type="button" class="btn btn-danger btn-sm">
                <i class="fa-solid fa-xmark"></i>&nbsp;Revoke Access
              </button>
            </div>
          </div>

          <div class="row g-3 mb-3 activity-list" v-if="selectedUser">
            <div v-if="selectedUserEvent.events.length">
              <div
                class="activity-card rounded p-2 mb-2 shadow-sm"
                v-for="(x, index) in selectedUserEvent.events.slice().reverse()"
                :key="index"
                :class="
                  x.eventLog.includes('Case')
                    ? 'border-success '
                    : 'border-primary'
                "
              >
                <div>
                  <h6 class="mb-1">
                    {{ x.eventLog }}
                  </h6>
                  <div class="d-flex justify-content-between align-items-end">
                    <small>{{ x.variableID }}</small>
                    <small class="text-muted">
                      {{ store.getDateTime(x.timestamp) }}
                    </small>
                  </div>
                  <small v-if="store.isAdmin">
                    <strong>User:</strong>
                    {{ x.userAddress }}
                  </small>
                </div>
              </div>
            </div>
            <div v-else class="rounded text-danger">
              <h6 class="mb-0 py-2">No Activity Found</h6>
            </div>
          </div>
          <div v-else class="user-card rounded text-danger">
            <h6 class="mb-0 py-2">No User Selected</h6>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CmContract from "../../blockchain/caseManager";
import lcContract from "../../blockchain/userAuth";
import { useAuthStore } from "../stores/auth";

export default {
  name: "UserActivity",
  setup() {
    const store = useAuthStore();
    return {
      store,
    };
  },
  data() {
    return {
      selectedRole: "",
      selectedUser: "",
      userActivityList: [],
      selectedUserEvent: [],
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
        4: {
          name: "Admin",
          icon: "fa-user-gear",
        },
      },
    };
  },
  mounted() {
    // this.getCaseAccessList();
    this.getAllUsers();
  },
  methods: {
    async getAllUsers() {
      try {
        const allUsers = await lcContract.methods.getAllUsers().call();
        for (let index = 0; index < allUsers.length; index++) {
          this.getUserEvents(allUsers[index]);
        }
      } catch (error) {
        console.log(error);
      }
    },
    async getUserEvents(user) {
      try {
        const userDetails = await lcContract.methods.getUserInfo(user).call();
        const response = await CmContract.methods
          .getUserEvents()
          .call({ from: user });
        const event = response.map((x) => ({
          eventLog: x[1],
          timestamp: x[3],
          userAddress: x[0],
          variableID: x[2],
        }));
        const userActivity = {
          name: userDetails[0],
          email: userDetails[1],
          role: userDetails[2],
          events: event,
        };
        this.userActivityList.push(userActivity);
      } catch (error) {
        console.log(error);
      }
    },
    showUserEvents(email) {
      this.selectedUser = email;
      const userEvents = this.userActivityList.find(
        (user) => user.email === email
      );
      this.selectedUserEvent = userEvents;
    },
  },
};
</script>

<style lang="scss" scoped>
.user-activity {
  .section-header {
    padding: 20px 0;
    border-bottom: 1px solid $border-variant-4;
  }
  .user-list {
    .user-card {
      cursor: pointer;
      border: 1px solid $border-variant-1;
      transition: $transition;
      &:hover {
        box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
        border-color: $border-variant-4;
      }
    }
  }
  .user-activity-list {
    border-left: 1px solid $border-variant-1 !important;
    .header {
      border-bottom: 1px solid $border-variant-1;
    }
    .activity-list {
      overflow: auto;
      max-height: 300px;
      .activity-card {
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