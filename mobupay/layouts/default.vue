<template>
  <v-app class="__app">
    <v-container fluid class="pa-0">
      <v-system-bar color="orange" class="px-0 justify-center">
        {{ $config.version }}
      </v-system-bar>

      <!-- header -->
      <v-row no-gutters>
        <v-col cols="12" class="header d-flex align-center">
          <v-col
            lg="10"
            md="12"
            sm="12"
            class="px-md-5 px-0 py-0 d-flex justify-center mx-md-auto px-sm-0"
          >
            <v-col class="d-flex align-center">
              <a href="/" aria-label="Mobupay Home page">
                <img
                  class="logo"
                  src="~/assets/img/mobupay.svg"
                  height="50"
                  width="112"
                  alt="Mobupay Logo"
                />
              </a>
            </v-col>
            <v-spacer></v-spacer>
            <v-col class="d-flex justify-end align-center">
              <div v-if="$auth.loggedIn">
                <NuxtLink
                  class="primary--text text-5 text-decoration-none"
                  :to="{
                    name: 'dashboard',
                    params: { dashboard: $auth.$state.user.msisdn },
                  }"
                  >+{{ $auth.$state.user.msisdn }}
                </NuxtLink>
              </div>
              <div v-else>
                <template v-if="show_login_link">
                  <NuxtLink
                    class="grey--text text-5 text-decoration-none"
                    to="/login"
                    >Login</NuxtLink
                  >
                </template>
              </div>
              <!--
              
                <div v-if="$auth.loggedIn">
                  <v-btn
                    color="#0052ff"
                    tile
                    block
                    elevation="0"
                    @click="$auth.logout()"
                  >
                    Logout
                  </v-btn>
                </div>
              -->
            </v-col>
          </v-col>
        </v-col>
      </v-row>

      <v-row no-gutters>
        <v-col cols="12">
          <v-col lg="10" md="12" sm="12" class="px-md-5 mx-auto working-box">
            <Nuxt />
          </v-col>
        </v-col>
      </v-row>
    </v-container>
  </v-app>
</template>

<script>
export default {
  name: "DefaultLayout",
  data: () => ({
    show_login_link: false,
  }),
  mounted() {
    if (this.$route.name !== "login") {
      this.show_login_link = true;
    }
  },
};
</script>

<style lang="scss" scoped>
.__app {
  background-color: $grey_light;

  .logo {
    vertical-align: bottom;
  }
  .header {
    height: 58px;
    background-color: $white;
    border-bottom: 1px dashed rgb(236, 239, 241);
  }
}
</style>
