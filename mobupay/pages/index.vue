<template>
  <v-row justify="center" align="center">
    <v-col cols="12" sm="8" md="6">
      <div>
        <NuxtLink to="/get-started">Get Started</NuxtLink>
      </div>

      <div v-if="$auth.loggedIn">
        <p>You are logged in.</p>
        <button @click="$auth.logout()">Logout</button>
        <NuxtLink
          :to="{ name: 'dashboard', params: { dashboard: 2348108125270 } }"
          >Dashboard</NuxtLink
        >
      </div>
      <div v-if="!$auth.loggedIn">
        <p>You are NOT logged in.</p>
        <NuxtLink to="/login">Login</NuxtLink>
      </div>
    </v-col>
  </v-row>
</template>

<script>
export default {
  name: "home",
  mounted() {},
};
</script>
