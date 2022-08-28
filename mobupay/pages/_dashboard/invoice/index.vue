<template>
  <div>
    <p>Invoicing</p>

    <NuxtLink
      :to="{
        name: 'dashboard',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Dashboard</NuxtLink
    >

    <hr />
    <br />

    <br />
    <hr />
  </div>
</template>

<script>
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "invoice",
  layout: "dashboard",
  data: () => ({}),
  methods: {},
  mounted() {},
};
</script>

<style>
</style>