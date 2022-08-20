<template>
  <v-app>
    <v-container>
      <p>Desktop Layout</p>
      <Nuxt />
    </v-container>
  </v-app>
</template>

<script>
export default {
  name: "desktop",
  data() {
    return {
      clipped: false,
      drawer: false,
      fixed: false,
      items: [
        {
          icon: "mdi-apps",
          title: "Welcome",
          to: "/",
        },
        {
          icon: "mdi-chart-bubble",
          title: "Inspire",
          to: "/inspire",
        },
      ],
      miniVariant: false,
      right: true,
      rightDrawer: false,
      title: "Vuetify.js",
    };
  },
};
</script>
