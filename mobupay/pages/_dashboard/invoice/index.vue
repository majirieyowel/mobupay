<template>
  <div></div>
</template>

<script>
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "invoice",
  layout: "dashboard",
  meta: {
    breadcrumbs: [
      {
        text: "Invoice",
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