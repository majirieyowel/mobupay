<template>
  <div>
    <p>Complete withdrawal</p>

    <NuxtLink
      :to="{
        name: 'dashboard',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Dashboard</NuxtLink
    >

    <hr />
    <br />

    <div v-if="completed">
      <v-row class="justify-center">
        <v-col cols="12" sm="6">
          <v-otp-input
            v-model="form.otp"
            :length="otpLength"
            type="number"
          ></v-otp-input>
        </v-col>
      </v-row>

      <v-row class="justify-center">
        <v-col cols="12" sm="6" class="d-flex justify-end">
          <v-btn @click="preWithdrawal" elevation="2" outlined raised small
            >Proceed</v-btn
          >
        </v-col>
      </v-row>
    </div>
    <div v-else>
      <Success title="Withdrawal Successful">
        <p>
          You have sent money to your bank account
          <br />
          <small>You can still get your money back</small>
        </p>

        <div>
          <NuxtLink
            :to="{
              name: 'dashboard',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-btn color="primary"> Dashboard </v-btn>
          </NuxtLink>
        </div>
      </Success>
    </div>

    <br />
    <hr />
  </div>
</template>

<script>
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "complete-withdrawal",
  layout: "dashboard",
  data: () => ({
    completed: false,
    otpLength: 4,
    form: {
      ref: "",
      otp: "",
      ip_address: "",
      device: "",
    },
  }),
  methods: {
    async complete() {
      let ip = await this.$axios.$get(process.env.ipURL);
      this.form.ip_address = ip.origin;
      this.form.device = window.navigator.userAgent;
      try {
        const response = await this.$axios.$post(
          "/withdraw/complete",
          this.form
        );

        if (response.status) {
          this.$router.push({
            name: "dashboard-withdraw-complete-withdrawal",
            params: { dashboard: this.$auth.$state.user.msisdn },
            query: { ref: response.data.reference },
          });
        }
      } catch (error) {
        if (error.response.status == 400) {
          this.$toast.error(error.response.data.message);
        } else if (error.response.status == 422) {
          this.$toast.error(error.response.data.message);
          console.log(error.response.data.error);
        }
      }

      // redirect to verification
    },
    ensureRef() {
      let ref = this.$route.query.ref;

      if (typeof ref == "undefined") {
        this.$router.push({
          name: "invalid-path",
        });
        return;
      }
      this.ref = ref;
    },
  },
  mounted() {
    this.ensureRef();
  },
};
</script>

<style>
</style>