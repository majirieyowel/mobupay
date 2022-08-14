<template>
  <div>
    <p>Login</p>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-text-field
          v-model="form.msisdn"
          label="Phone number"
          hide-details="auto"
        >
        </v-text-field>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-text-field
          v-model="form.password"
          label="Password"
          hide-details="auto"
        >
        </v-text-field>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-btn @click="login" elevation="2" outlined raised small>Login</v-btn>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <NuxtLink to="/get-started">Register</NuxtLink>
      </v-col>
    </v-row>
  </div>
</template>

<script>
export default {
  name: "login",
  auth: "guest",
  data: () => ({
    form: {
      msisdn: "2348108125270",
      password: "@Nelie&e12",
    },
  }),

  methods: {
    async login() {
      try {
        await this.$auth.loginWith("local", {
          data: this.form,
        });
        this.$router.push({
          name: "dashboard",
          params: { dashboard: this.form.msisdn },
        });
      } catch (error) {
        console.log(error);
        this.$toast.error(
          error.response.data.message || "Authentication failed"
        );
      }
    },
  },
  mounted() {},
};
</script>

<style>
</style>