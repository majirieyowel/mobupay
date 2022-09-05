<template>
  <v-app id="inspire">
    <v-navigation-drawer v-model="drawer" mobile-breakpoint="600" app>
      <v-system-bar color="orange" class="px-0 justify-center">
        Beta
      </v-system-bar>
      <v-container fluid>
        <v-row>
          <v-col cols="12" class="d-flex align-center justify-center">
            <a :href="$auth.$state.user.msisdn" aria-label="Mobupay logo">
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

        <div class="omit--dashboard">
          <v-list-group prepend-icon="mdi-bank-transfer" no-action>
            <template v-slot:activator>
              <v-list-item-content>
                <v-list-item-title text="Transfer">Transfer</v-list-item-title>
              </v-list-item-content>
            </template>

            <NuxtLink
              class="text-decoration-none"
              :to="{
                name: 'dashboard-help-center',
                params: { dashboard: $auth.$state.user.msisdn },
              }"
            >
              <v-list-item link>
                <v-list-item-content>
                  <v-list-item-title>Send</v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            </NuxtLink>
          </v-list-group>
        </div>

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

        <div class="omit--dashboard">
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard-profile',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-list-item link>
              <v-list-item-icon>
                <v-icon>mdi-account-circle-outline</v-icon>
              </v-list-item-icon>
              <v-list-item-content>
                <v-list-item-title>Profile</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </NuxtLink>
        </div>

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

        <div class="omit--dashboard">
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
    </v-app-bar>

    <v-main>
      <Nuxt />
    </v-main>
  </v-app>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  name: "DashboardLayout",
  computed: mapGetters(["breadcrumbs"]),
  data() {
    return {
      drawer: false,
      list: true,
    };
  },
  mounted() {
    // window.addEventListener("resize", () => {
    //   console.log(screen.width);
    // });
  },
};
</script>

<style lang="scss" scoped>
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
    background: linear-gradient(191deg, #33acf4 28.93%, #0052ff 76.95%);
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
    background: linear-gradient(191deg, #33acf4 28.93%, #0052ff 76.95%);
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

.v-breadcrumbs {
  // padding: 0px;
}
</style>