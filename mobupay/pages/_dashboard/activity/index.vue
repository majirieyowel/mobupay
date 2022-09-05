<template>
  <div>
    <p>Your Activity</p>
  </div>
</template>

<script>
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "activity",
  layout: "dashboard",
  meta: {
    breadcrumbs: [
      {
        text: "Your Activity",
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