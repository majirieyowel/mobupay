<template>
  <v-row class="content px-md-5">
    <v-col class="pa-md-0" cols="12" sm="6" v-if="showHeroSection">
      <div class="hero">
        <h1 class="hero__title mb-5">
          Send money <br />
          to any valid mobile number
        </h1>
        <p class="hero_subtitle text-left">
          Mobupay is the easiest place to use your phone number to send and
          receive money, pay bills and create invoices. Sign up and get started
          today.
        </p>
      </div>
    </v-col>

    <v-col class="pa-md-0" cols="12" sm="6" style="position: relative">
      <div class="hero-form mt-0 mb-15">
        <component
          v-bind:is="steps[currentStep].component"
          v-bind:params="steps[currentStep].params"
          @submitted="submitted"
          @mobile="showHeroSection = false"
        />
        <v-overlay
          color="#f2f2f2"
          opacity="0.7"
          absolute
          :value="$auth.loggedIn"
        >
        </v-overlay></div
    ></v-col>
  </v-row>
</template>

<script>
export default {
  name: "home",
  data: () => ({
    currentStep: 0,
    showHeroSection: true,
    steps: [
      {
        component: "CreateUser",
        params: {
          msisdn: "",
          country: "",
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
  },
  async fetch() {
    try {
      const [gettingStarted, ipLookup] = await Promise.all([
        this.$axios.$get("/onboard/getting-started"),
        this.$axios.$get("https://httpbin.org/ip"),
      ]);

      console.log("IP URL: ", process.env.ipURL);

      const firstForm = this.steps[0];

      const supportedCountries = gettingStarted.data;

      for (let i = 0; i < supportedCountries.length; i++) {
        const element = supportedCountries[i];

        firstForm.params.supportedCountries.push(element.country);
      }
      const ip_addr = ipLookup.origin || null;
      console.log("IP ADDR: ", ip_addr);
      if (this.validate_ip(ip_addr)) {
        const ip_info = await this.$axios.$get(
          `https://ipinfo.io/${ip_addr}?token=7afa17ebc35a9d`
        );
        console.log("IP INFO: ", ip_info);
        const { country, city, region } = ip_info;
        firstForm.params.city = city;
        firstForm.params.region = region;
        let matched_country = gettingStarted.data.filter((item) => {
          return item.country_code === country;
        });

        if (matched_country.length > 0) {
          firstForm.params.country = matched_country[0].country;
        } else {
          firstForm.params.country = false;
        }
      } else {
        console.log("Invalid IP");
      }
    } catch (error) {
      console.log("Catch", error);
    }
  },
  fetchOnServer: false,
  mounted() {
    console.log("BACKEND URL: ", process.env.BACKEND_URL);
  },
};
</script>

<style lang="scss" scoped>
.content {
  margin-top: 2rem;
}

.hero {
  .hero__title {
    font-size: 36px;
    font-weight: 500;
    line-height: 47px;
  }

  .hero_subtitle {
    color: #5b5b5b;
    font-size: 14px;
  }
}

@media (min-width: 767px) {
  .content {
    margin-top: 8rem;
  }

  .hero {
    .hero__title {
      font-size: 50px;
      font-weight: 900;
    }

    .hero_subtitle {
      font-size: 18px;
    }
  }
}
</style>
