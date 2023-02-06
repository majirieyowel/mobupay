<template>
  <v-container fluid>
    <v-row class="login my-8 my-md-16">
      <v-col cols="12" md="5" class="login-card ma-0 mx-auto">
        <v-alert color="orange" text>
          <p class="ma-0 pa-0">
            Mobupay uses your device biometrics to secure your transactions.
          </p>
        </v-alert>
        <v-row align="center">
          <v-col cols="12" class="py-5">
            <p class="mb-1">Enter security token below:</p>
            <v-otp-input
              v-model="form.otp"
              :length="length"
              type="number"
            ></v-otp-input>

            <v-btn
              :disabled="!isActive"
              :loading="loading"
              color="#0052ff"
              class="form__btn mt-2 mt-md-5"
              block
              tile
              large
              elevation="0"
              @click="verify_otp"
              >SECURE DEVICE</v-btn
            >
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import errorCatch from "../../functions/catchError";

export default {
  name: "secure-device",
  head() {
    return {
      title: "Mobupay - Secure Whatsapp Device 🔒",
    };
  },
  data: () => ({
    message: "",
    length: 4,
    counter: 50,
    showResendLink: false,
    loading: false,
    resendingOTP: false,
    form: {
      msisdn: "",
      otp: "",
    },
    otpInterval: null,
  }),
  computed: {
    isActive() {
      return this.form.otp.length === this.length;
    },
  },
  methods: {
    // async verify_email() {
    //   try {
    //     const response = await this.$axios.post("/verify-whatsapp-email", {
    //       token: this.token,
    //     });
    //     let data = response.data;
    //     if (data.confirmed) {
    //       this.message = "Your email has been verified successfully";
    //     } else {
    //       this.message = "Unable to verify email";
    //     }
    //   } catch (error) {
    //     errorCatch(error, this);
    //   }
    // },
  },
  mounted() {
    // this.token = this.$route.params.token;
    // this.verify_email();
  },
};
</script>

<style lang="scss" scoped>
.form__btn {
  color: #fff;
}
</style>
