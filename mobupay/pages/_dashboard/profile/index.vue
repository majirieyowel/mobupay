<template>
  <div>
    <p>Profile</p>
  </div>
</template>

<script>
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "profile",
  layout: "dashboard",
  meta: {
    breadcrumbs: [
      {
        text: "Profile",
        disabled: true,
        help: true,
        to: "#",
      },
    ],
  },
  data: () => ({}),
  methods: {},
  mounted() {},
};
</script>

<style>
</style>