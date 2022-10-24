<template>
  <v-app id="inspire">
    <v-navigation-drawer v-model="drawer" mobile-breakpoint="600" app>
      <v-system-bar color="orange" class="px-0 justify-center">
        Beta
      </v-system-bar>
      <v-container fluid>
        <v-row>
          <v-col cols="12" class="d-flex align-center justify-center">
            <a :href="'/' + $auth.$state.user.msisdn" aria-label="Mobupay logo">
              <img
                class="logo"
                src="~/assets/img/mobupay.svg"
                height="50"
                width="112"
                alt="Mobupay Logo"
              />
            </a>
          </v-col>
        </v-row>
      </v-container>

      <v-list>
        <div>
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-list-item link>
              <v-list-item-icon>
                <v-icon>mdi-view-dashboard</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>Dashboard</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </NuxtLink>
        </div>

        <!--
          <div class="omit--dashboard">
            <NuxtLink
              class="text-decoration-none"
              :to="{
                name: 'dashboard-send',
                params: { dashboard: $auth.$state.user.msisdn },
              }"
            >
              <v-list-item link @click.stop.prevent="displayOptionsDialog">
                <v-list-item-icon>
                  <v-icon>mdi-send-outline</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>Send</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </NuxtLink>
          </div>
        -->

        <div class="omit--dashboard">
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard-invoice',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-list-item link>
              <v-list-item-icon>
                <v-icon>mdi-receipt-text-plus-outline</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>Invoice</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </NuxtLink>
        </div>

        <div class="omit--dashboard">
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard-withdraw',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-list-item link>
              <v-list-item-icon>
                <v-icon>mdi-transfer-down</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>Withdraw</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </NuxtLink>
        </div>

        <div class="omit--dashboard">
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard-contacts',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-list-item link>
              <v-list-item-icon>
                <v-icon>mdi-card-account-mail-outline</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>Contacts</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </NuxtLink>
        </div>

        <div class="omit--dashboard">
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard-bank-accounts',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-list-item link>
              <v-list-item-icon>
                <v-icon>mdi-bank</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>Bank Accounts</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </NuxtLink>
        </div>

        <!--
          <div class="omit--dashboard">
            <NuxtLink
              class="text-decoration-none"
              :to="{
                name: 'dashboard-cards',
                params: { dashboard: $auth.$state.user.msisdn },
              }"
            >
              <v-list-item link>
                <v-list-item-icon>
                  <v-icon>mdi-card-account-details-outline</v-icon>
                </v-list-item-icon>
                <v-list-item-content>
                  <v-list-item-title>Cards</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </NuxtLink>
          </div>
        -->

        <div class="omit--dashboard">
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard-settings',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-list-item link>
              <v-list-item-icon>
                <v-icon>mdi-tune-vertical</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>Settings</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </NuxtLink>
        </div>

        <!-- <div class="omit--dashboard">
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard-activity',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-list-item link>
              <v-list-item-icon>
                <v-icon>mdi-cookie-settings-outline</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>Activity</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </NuxtLink>
        </div> 
      -->

        <div class="omit--dashboard">
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard-help-center',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-list-item link>
              <v-list-item-icon>
                <v-icon>mdi-help-circle-outline</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>Help Center</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </NuxtLink>
        </div>
      </v-list>

      <template v-slot:append>
        <div class="pa-2">
          <v-btn tile block elevation="0" @click="$auth.logout()">
            Logout
          </v-btn>
        </div>
      </template>
    </v-navigation-drawer>

    <v-app-bar class="app--bar" app>
      <v-app-bar-nav-icon @click="drawer = !drawer"></v-app-bar-nav-icon>

      <v-toolbar-title class="pl-0">
        <v-breadcrumbs nuxt exact :items="breadcrumbs">
          <template v-slot:divider>
            <v-icon>mdi-chevron-right</v-icon>
          </template>
          <template v-slot:item="{ item }">
            <v-breadcrumbs-item exact :to="item.to" :disabled="item.disabled">
              {{ item.text }}
              <v-icon class="help-icon" v-if="item.help"
                >mdi-help-circle-outline</v-icon
              >
            </v-breadcrumbs-item>
          </template>
        </v-breadcrumbs>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <div class="balance" v-if="showHeaderBalance">
        <div class="account">
          <span>Account Balance:</span>
          <span>
            {{ $auth.$state.user.currency }}
            {{ $auth.$state.user.account_balance | format_money }}
          </span>
        </div>
        <div class="book">
          <span>Book Balance:</span>
          <span>
            {{ $auth.$state.user.currency }}
            {{ $auth.$state.user.book_balance | format_money }}
          </span>
        </div>
      </div>
    </v-app-bar>

    <v-main>
      <Nuxt />

      <v-dialog
        @click:outside="$store.commit('setSendDialog', false)"
        v-model="sendDialog"
        width="500"
        content-class="send-dialog"
      >
        <v-card>
          <v-card-subtitle>
            <h3 class="_title">Select sending option</h3></v-card-subtitle
          >
          <v-card-actions class="d-flex justify-space-between pa-0">
            <v-container>
              <v-row class="justify-space-between">
                <v-col
                  cols="5"
                  class="pa-0 item"
                  @click="navigate('dashboard-send-self')"
                >
                  <p class="text-center">
                    <v-icon>mdi-phone-incoming</v-icon>
                    <br />
                    Your number
                  </p>
                </v-col>
                <v-col
                  cols="5"
                  class="pa-0 item"
                  @click="navigate('dashboard-send')"
                >
                  <p class="text-center">
                    <v-icon>mdi-phone-outgoing</v-icon>
                    <br />
                    Other number
                  </p>
                </v-col>
              </v-row>
            </v-container>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </v-main>
  </v-app>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  name: "DashboardLayout",
  computed: mapGetters(["breadcrumbs", "sendDialog"]),
  data() {
    return {
      drawer: true,
      list: true,
      showHeaderBalance: true,
    };
  },
  methods: {
    displayOptionsDialog(e) {
      this.$store.commit("setSendDialog", true);
    },
    navigate(location) {
      this.$store.commit("setSendDialog", false);
      this.$router.push({
        name: location,
        params: { dashboard: this.$auth.$state.user.msisdn },
      });
    },
  },
  beforeMount() {
    if (screen.width < 600) {
      this.drawer = false;
    }
  },
  mounted() {},
};
</script>

<style lang="scss" scoped>
.balance {
  display: flex;
  flex-direction: column;
  align-items: flex-end;

  .account span {
    font-weight: bold;
  }
  .book span {
    font-size: 0.864rem;
  }
}
.app--bar {
  // background: linear-gradient(191deg, #33acf4 28.93%, #0052ff 76.95%);
  box-shadow: none !important;
  background: $white !important;
}
.nuxt-link-exact-active {
  .v-list-item__title {
    color: $white;
  }
  .v-list-item {
    // background: linear-gradient(191deg, #33acf4 28.93%, #0052ff 76.95%);
    background: $primary;
  }
  .v-icon {
    color: $white;
  }
}
.omit--dashboard .nuxt-link-active {
  .v-list-item__title {
    color: $white;
  }
  .v-list-item {
    // background: linear-gradient(191deg, #33acf4 28.93%, #0052ff 76.95%);
    background: $primary;
  }
  .v-icon {
    color: $white;
  }
}

.v-icon {
  font-size: 20px;
}

.help-icon {
  padding-left: 2px;
}

.send-dialog {
  ._title {
    text-align: center;
    font-size: 16px;
    font-weight: 500;
    margin-bottom: 50px;
    color: #1976d2;
  }

  p {
    color: #666666 !important;
    font-weight: 600;
    margin: 0;
  }

  .item {
    min-height: 100px;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 5px;
    cursor: pointer;
    &:hover {
      background: #eee;
    }
  }

  .v-icon {
    font-size: 30px;
    color: #ff9800;
    padding-bottom: 7px;
  }

  .v-card {
    padding: 20px;
  }
}
</style>