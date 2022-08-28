<template>
  <div>
    <p>ADD YOUR EMAIL</p>

    <NuxtLink
      :to="{
        name: 'dashboard',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Dashboard</NuxtLink
    >

    <hr />
    <br />

    <p>Before creating your first transaction please add your email address</p>
    <p>This is for transactions notifications only</p>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-text-field v-model="form.email" label="Email Address">
        </v-text-field>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-btn @click="add_email" elevation="2" outlined raised small
          >Proceed</v-btn
        >
      </v-col>
    </v-row>

    <br />
    <hr />
  </div>
</template>

<script>
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "add-email",
  layout: "dashboard",
  data: () => ({
    form: {
      email: "majirieyowel@gmail.com",
    },
  }),
  methods: {
    async add_email() {
      try {
        await this.$axios.$post("user/add-email", this.form);

        this.$store.commit("addEmail", this.form.email);

        this.$toast.success("Email added succcessfully!");

        this.$router.push({
          name: "dashboard-funding-options",
          params: { dashboard: this.$auth.$state.user.msisdn },
        });
      } catch (error) {
        console.log(error.response);
        this.$toast.error(error.response.data.message || "An error occured!");
        console.log("Request Error occured", error.response);
      }
    },
  },
  mounted() {},
};
</script>

<style>
</style>