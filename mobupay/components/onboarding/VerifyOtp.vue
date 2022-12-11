<template>
  <div class="hero-form">
    <v-row align="center">
      <v-col cols="12" sm="10" md="8" class="py-0 ml-auto">
        <v-alert color="orange" text>
          <p class="ma-0 pa-0">
            {{ message }}
          </p>
        </v-alert>

        <v-otp-input
          v-model="form.otp"
          :length="length"
          type="number"
        ></v-otp-input>

        <div class="resend-otp">
          <span v-if="!showResendLink" class="wait"
            >Resend OTP in {{ counter }}</span
          >
          <span v-else>
            <span v-if="resendingOTP" class="sending blink"
              >Resending OTP...</span
            >
            <span @click="resendOTP" v-else class="resend">Resend</span>
          </span>
        </div>

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
    async resendOTP() {
      this.resendingOTP = true;

      try {
        await this.$axios.$post(
          "/onboard/resend-otp",
          { msisdn: this.params.msisdn },
          {
            headers: {
              _hash: this.onboarding._hash,
            },
          }
        );

        this.message = `OTP resent to ${this.params.msisdn}`;
        this.startCountDown();
        this.resendingOTP = false;
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.resendingOTP = false;
      }
    },
    startCountDown() {
      this.showResendLink = false;
      this.otpInterval = setInterval(() => {
        this.counter = --this.counter;
        if (this.counter == 0) {
          clearInterval(this.otpInterval);
          this.counter = 50;
          this.showResendLink = true;
        }
      }, 1000);
    },
  },
  mounted() {
    this.form.msisdn = this.params.msisdn;
    this.message = `An OTP has been sent to ${this.params.msisdn}`;
    this.startCountDown();

    if (screen.width < 600) {
      this.$emit("mobile");
    }
  },
};
</script>

<style lang="scss" scoped>
.hero-form .hero-form__btn {
  color: #fff;
}

.wait,
.resend,
.sending {
  font-size: 12px;
}
.wait {
}
.resend {
  cursor: pointer;
  text-decoration: underline;
  color: #fea437;
}

.resend-otp {
  text-align: right;
}
</style>