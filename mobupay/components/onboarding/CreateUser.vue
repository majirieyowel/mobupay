<template>
  <div>
    <v-form>
      <v-row align="center">
        <v-col cols="12" sm="10" md="8" class="py-0 ml-auto">
          <v-alert color="orange" text type="info" v-if="!supported">
            <p class="ma-0 pa-0 text-xs-5">
              Mobupay is currently not supported in your country.
            </p>
          </v-alert>

          <v-select
            v-model="form.country"
            ref="country"
            :items="params.supportedCountries"
            item-text="label"
            item-value="ref"
            persistent-hint
            label="Country"
            :rules="rules.country"
          >
          </v-select>

          <v-text-field
            ref="msisdn"
            v-model="form.msisdn"
            label="Phone Number"
            required
            type="number"
            :rules="rules.msisdn"
            clearable
          ></v-text-field>

          <v-btn
            color="#0052ff"
            block
            :loading="submitting"
            @click="submit"
            tile
            large
            elevation="0"
            class="hero_form__btn mt-2 mt-md-5"
          >
            Let's go 🚀
          </v-btn>
        </v-col>
      </v-row>
    </v-form>
  </div>
</template>

<script>
import errorCatch from "../../functions/catchError";

export default {
  name: "create_user",
  emits: ["submitted"],
  data: () => ({
    submitting: false,
    supported: true,
    formHasErrors: false,
    form: {
      msisdn: "",
      country: "",
      city: "",
      region: "",
    },
    rules: {
      msisdn: [(v) => (v || "").length > 0 || "Mobile number is required"],
      country: [(v) => (v || "").length > 0 || "Select your country"],
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
  computed: {
    form_cast() {
      return {
        msisdn: this.form.msisdn,
        country: this.form.country,
      };
    },
  },

  methods: {
    async submit() {
      this.formHasErrors = false;

      Object.keys(this.form_cast).forEach((f) => {
        if (!this.form_cast[f]) this.formHasErrors = true;

        this.$refs[f].validate(true);
      });

      if (!this.formHasErrors) await this.do_submit();
    },
    async do_submit() {
      this.submitting = true;
      try {
        const response = await this.$axios.$post(
          "/onboard/partial-onboard",
          this.form
        );

        this.$store.commit("onboardingHash", response.data._hash);
        this.$emit("submitted", "create_user", {
          msisdn: response.data.msisdn,
        });
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.submitting = false;
      }
    },
    setup() {
      // assign props
      this.form.msisdn = this.params.msisdn;
      this.form.city = this.params.city;
      this.form.region = this.params.region;
      if (this.params.country) {
        this.form.country = this.params.country;
      } else {
        this.supported = false;
      }

      // Grab msisdn from query params if exist
      let query = this.$route.query;
      if (query.p) {
        this.form.msisdn = query.p;
      }
    },
  },
  mounted() {
    this.setup();
  },
};
</script>

<style scoped>
.hero-form .hero_form__btn {
  color: #fff;
}
</style>