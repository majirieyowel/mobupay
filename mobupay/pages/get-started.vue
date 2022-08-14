<template>
  <v-row v-if="!pageIsLoading" justify="center" align="center">
    <v-col cols="12" sm="8" md="6">
      <component
        v-bind:is="steps[currentStep].component"
        v-bind:params="steps[currentStep].params"
        @submitted="submitted"
      />
    </v-col>
  </v-row>
  <v-row v-else justify="center" align="center">
    <v-col cols="12" sm="8" md="6">
      <h1>Mobupay Loading...</h1>
    </v-col>
  </v-row>
</template>

<script>
export default {
  name: "get-started",
  data: () => ({
    pageIsLoading: true,
    currentStep: 0,
    steps: [
      {
        component: "CreateUser",
        params: {
          msisdn: "2348108125270",
          country: "Nigeria",
          city: "",
          region: "",
          supportedCountries: [],
        },
      },
      {
        component: "VerifyOtp",
        params: {
          msisdn: "",
          otp: "",
        },
      },
      {
        component: "SetPassword",
        params: {
          msisdn: "",
          password: "",
        },
      },
    ],
  }),
  methods: {
    next() {
      this.currentStep++;
    },
    validate_ip(ipaddress) {
      if (
        /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(
          ipaddress
        )
      ) {
        return true;
      }
      return false;
    },
    async submitted(key, form_data) {
      switch (key) {
        case "create_user":
          let secondForm = this.steps[1];
          secondForm.params.msisdn = form_data.msisdn;
          this.next();
          break;
        case "verify_otp":
          let thirdForm = this.steps[2];
          thirdForm.params.msisdn = form_data.msisdn;
          this.next();
          break;
        case "set_password":
          await this.login_user(form_data.msisdn, form_data.password);

          break;
      }
    },
    async login_user(msisdn, password) {
      await this.$auth.loginWith("local", {
        data: {
          msisdn: msisdn,
          password: password,
        },
      });
      this.$router.push({
        name: "dashboard",
        params: { dashboard: msisdn },
      });
    },
  },
  async fetch() {
    try {
      const [gettingStarted, ipLookup] = await Promise.all([
        this.$axios.$get("/onboard/getting-started"),
        this.$axios.$get(process.env.ipURL),
      ]);

      const firstForm = this.steps[0];

      const supportedCountries = gettingStarted.data.supported_countries;

      for (const key in supportedCountries) {
        firstForm.params.supportedCountries.push(supportedCountries[key].name);
      }
      const ip_addr = ipLookup.origin || null;
      if (this.validate_ip(ip_addr)) {
        const ip_info = await this.$axios.$get(
          `https://ipinfo.io/${ip_addr}?token=7afa17ebc35a9d`
        );
        const { country, city, region } = ip_info;
        firstForm.params.city = city;
        firstForm.params.region = region;
        let matched_country = gettingStarted.data.supported_countries[country.toLowerCase()];
        if (typeof matched_country !== "undefined") {
          firstForm.params.country = matched_country.name;
        } else {
          console.log("Country not supported");
        }

        // turn the lights on
        this.pageIsLoading = false;
      } else {
        console.log("Invalid IP");
      }
    } catch (error) {
      console.log("Catch", error);
    }
  },
};
</script>

<style>
</style>