<template>
  <div>
    <p>SET PASSWORD</p>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-text-field
          v-model="form.password"
          label="Password"
          type="password"
          autofocus
        >
        </v-text-field>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-text-field
          v-model="form.password_confirmation"
          label="Confirm Password"
          type="password"
        >
        </v-text-field>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-btn @click="set_password" elevation="2" outlined raised small
          >Next</v-btn
        >
      </v-col>
    </v-row>
  </div>
</template>

<script>
import { mapState } from "vuex";

export default {
  name: "set_password",
  data: () => ({
    form: {
      msisdn: "",
      password: "",
      password_confirmation: "",
    },
  }),
  computed: mapState(["onboarding"]),

  props: {
    params: {
      msisdn: String,
      password: String,
    },
  },
  methods: {
    async set_password() {
      try {
        await this.$axios.$post("/onboard/set-password", this.form, {
          headers: {
            _hash: this.onboarding._hash,
          },
        });

        this.$emit("submitted", "set_password", { ...this.form });
      } catch (error) {
        this.$toast.error(error.response.data.message || "An error occured!");

        console.log("Request Error occured", error.response);
      }
    },
  },
  mounted() {
    this.form.msisdn = this.params.msisdn;
  },
};
</script>

<style>
</style>