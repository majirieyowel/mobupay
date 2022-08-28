<template>
  <div class="hero-form">
    <v-row align="center">
      <v-col cols="12" sm="10" md="8" class="py-0 mx-auto">
        <v-alert color="orange" text>
          <p class="ma-0 pa-0 text-xs-5">
            An OTP has been sent to {{ params.msisdn }}
          </p>
        </v-alert>

        <v-otp-input
          v-model="form.otp"
          :length="length"
          type="number"
        ></v-otp-input>

        <v-btn
          :disabled="!isActive"
          :loading="loading"
          color="#0052ff"
          class="hero-form__btn mt-2 mt-md-5"
          block
          tile
          large
          elevation="0"
          @click="verify_otp"
          >PROCEED</v-btn
        >
      </v-col>
    </v-row>
  </div>
</template>

<script>
import { mapState } from "vuex";
import errorCatch from "../../functions/catchError";

export default {
  name: "verify_otp",
  emits: ["submitted", "mobile"],
  data: () => ({
    length: 4,
    loading: false,
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
      this.loading = true;
      try {
        await this.$axios.$post("/onboard/verify-otp", this.form, {
          headers: {
            _hash: this.onboarding._hash,
          },
        });

        this.$emit("submitted", "verify_otp", { ...this.form });
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.loading = false;
      }
    },
  },
  mounted() {
    this.form.msisdn = this.params.msisdn;

    if (screen.width < 600) {
      this.$emit("mobile");
    }
  },
};
</script>

<style scoped>
.hero-form .hero-form__btn {
  color: #fff;
}
</style>