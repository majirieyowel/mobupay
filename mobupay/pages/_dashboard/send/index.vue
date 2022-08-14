<template>
  <div>
    <p>Sending Options</p>

    <NuxtLink
      :to="{
        name: 'dashboard',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Dashboard</NuxtLink
    >
    <hr />
    <br />

    <NuxtLink
      :to="{
        name: 'dashboard-send-self-funding',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
    >
      <v-btn color="primary" elevation="2" large
        >Fund your phone number<br />
        (+{{ $auth.$state.user.msisdn }})</v-btn
      ></NuxtLink
    >

    |

    <v-btn color="primary" elevation="2" large>
      Transfer to another Phone number</v-btn
    >

    <br />
    <br />
    <hr />
  </div>
</template>

<script>
export default {
  middleware: "auth",
  name: "send",
  methods: {},
  mounted() {
    if (!this.$auth.$state.user.email) {
      this.$router.push({
        name: "dashboard-user-add-email",
        params: { dashboard: this.$auth.$state.user.msisdn },
      });
    }
  },
};
</script>

<style>
</style>