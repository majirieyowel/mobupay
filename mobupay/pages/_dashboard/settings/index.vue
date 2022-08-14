<template>
  <div>
    <p>Contacts</p>

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
  middleware: "auth",
  name: "settings",
  methods: {},
  mounted() {},
};
</script>

<style>
</style>