<template>
  <div>
    <p>Settings</p>
  </div>
</template>

<script>
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "settings",
  layout: "dashboard",
  meta: {
    breadcrumbs: [
      {
        text: "Settings",
        disabled: true,
        help: true,
        to: "#",
      },
    ],
  },
  methods: {},
  mounted() {},
};
</script>

<style>
</style>