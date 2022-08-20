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

    <div v-if="showUI">
      <NuxtLink
        :to="{
          name: 'dashboard-self-funding',
          params: { dashboard: $auth.$state.user.msisdn },
        }"
      >
        <v-btn color="primary" elevation="2" large
          >Fund your phone number<br />
          (+{{ $auth.$state.user.msisdn }})</v-btn
        ></NuxtLink
      >

      |

      <NuxtLink
        :to="{
          name: 'dashboard-transfer',
          params: { dashboard: $auth.$state.user.msisdn },
        }"
      >
        <v-btn color="primary" elevation="2" large>
          Transfer to another Phone number</v-btn
        ></NuxtLink
      >
    </div>

    <br />
    <br />
    <hr />
  </div>
</template>

<script>
export default {
  middleware: "auth",
  name: "funding-options",
  data: () => ({
    showUI: false,
  }),
  methods: {},
  mounted() {
    if (!this.$auth.$state.user.email) {
      this.$router.push({
        name: "dashboard-user-add-email",
        params: { dashboard: this.$auth.$state.user.msisdn },
      });
    } else {
      this.showUI = true;
    }
  },
};
</script>

<style>
</style>