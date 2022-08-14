<template>
  <div>
    <p>Verify OTP</p>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-otp-input
          v-model="form.otp"
          :length="length"
          type="number"
        ></v-otp-input>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-btn
          :disabled="!isActive"
          @click="verify_otp"
          elevation="2"
          outlined
          raised
          small
          >Next</v-btn
        >
      </v-col>
    </v-row>
  </div>
</template>

<script>
import { mapState, mapGetters, mapActions, mapMutations } from "vuex";

export default {
  name: "verify_otp",
  data: () => ({
    length: 4,
    form: {
      msisdn: "",
      otp: "",
    },
  }),
  computed: {
    isActive() {
      return this.form.otp.length === this.length;
    },
    ...mapState(["onboarding"]),
  },
  props: {
    params: {
      msisdn: String,
    },
  },
  methods: {
    async verify_otp() {
      try {
        await this.$axios.$post("/onboard/verify-otp", this.form, {
          headers: {
            _hash: this.onboarding._hash,
          },
        });

        this.$emit("submitted", "verify_otp", { ...this.form });
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