<template>
  <div>
    <p>Help Center</p>
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
        text: "Help Center",
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