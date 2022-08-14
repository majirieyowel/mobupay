<template>
  <div>
    <p>Create a new Account</p>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-select
          v-model="form.country"
          :items="params.supportedCountries"
          label="Country"
        ></v-select>
      </v-col>
    </v-row>

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
        <v-btn @click="get_started" elevation="2" outlined raised small
          >Next</v-btn
        >
      </v-col>
    </v-row>
  </div>
</template>

<script>
export default {
  name: "create_user",
  emits: ["submitted"],
  data: () => ({
    form: {
      msisdn: "",
      country: "",
      city: "",
      region: "",
    },
  }),
  props: {
    params: {
      msisdn: String,
      country: String,
      city: String,
      region: String,
      supportedCountries: Array,
    },
  },
  methods: {
    async get_started() {
      try {
        const response = await this.$axios.$post(
          "/onboard/partial-onboard",
          this.form
        );

        this.$store.commit("onboardingHash", response.data._hash);
        this.$emit("submitted", "create_user", { ...this.form });
      } catch (error) {
        this.$toast.error(error.response.data.message || "An error occured!");
        console.log("Request Error occured", error.response);
      }
    },
  },
  mounted() {
    this.form.msisdn = this.params.msisdn;
    this.form.country = this.params.country;
    this.form.city = this.params.city;
    this.form.region = this.params.region;
  },
};
</script>

<style>
</style>