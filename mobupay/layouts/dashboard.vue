<template>
  <v-app id="inspire">
    <v-navigation-drawer v-model="drawer" app>
      <v-system-bar color="orange" class="px-0 justify-center">
        Beta
      </v-system-bar>

      <template v-slot:append>
        <div class="pa-2">
          <v-btn tile block elevation="0" @click="$auth.logout()">
            Logout
          </v-btn>
        </div>
      </template>
    </v-navigation-drawer>

    <v-app-bar app>
      <v-app-bar-nav-icon @click="drawer = !drawer"></v-app-bar-nav-icon>

      <v-toolbar-title>Dashboard</v-toolbar-title>
    </v-app-bar>

    <v-main>
      <Nuxt />
    </v-main>
  </v-app>
</template>

<script>
export default {
  name: "DashboardLayout",
  data: () => ({ drawer: null }),
};
</script>

<style>
</style>