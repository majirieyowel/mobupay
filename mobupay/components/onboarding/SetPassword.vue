<template>
  <div>
    <v-row align="center">
      <v-col cols="12" sm="10" md="8" class="py-0 mx-auto">
        <v-alert color="orange" text>
          <p class="ma-0 pa-0 text-xs-5">
            Set a password to secure your account.
          </p>
        </v-alert>

        <v-text-field
          ref="password"
          v-model="form.password"
          label="Password"
          type="password"
          autofocus
          :rules="rules.password"
        >
        </v-text-field>

        <v-text-field
          ref="password_confirmation"
          v-model="form.password_confirmation"
          label="Confirm Password"
          type="password"
          :rules="rules.password_confirmation"
        >
        </v-text-field>

        <v-btn
          color="#0052ff"
          @click="submit"
          block
          tile
          large
          elevation="0"
          :loading="submitting"
          class="hero_form__btn mt-2 mt-md-5"
        >
          Proceed
        </v-btn>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import { mapState } from "vuex";
import errorCatch from "../../functions/catchError";

export default {
  name: "set_password",
  data: () => ({
    submitting: false,
    formHasErrors: false,
    form: {
      msisdn: "",
      password: "",
      password_confirmation: "",
    },
    rules: {
      password: [(v) => (v || "").length > 0 || "Password is required"],
      password_confirmation: [
        (v) => (v || "").length > 0 || "Password confirmation required",
      ],
    },
  }),
  computed: {
    form_cast() {
      return {
        password: this.form.password,
        password_confirmation: this.form.password_confirmation,
      };
    },
    ...mapState(["onboarding"]),
  },

  props: {
    params: {
      msisdn: String,
      password: String,
    },
  },
  methods: {
    async submit() {
      this.formHasErrors = false;

      Object.keys(this.form_cast).forEach((f) => {
        if (!this.form_cast[f]) this.formHasErrors = true;

        this.$refs[f].validate(true);
      });

      if (!this.formHasErrors) await this.set_password();
    },
    async set_password() {
      this.submitting = true;
      try {
        await this.$axios.$post("/onboard/set-password", this.form, {
          headers: {
            _hash: this.onboarding._hash,
          },
        });

        this.$emit("submitted", "set_password", { ...this.form });
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.submitting = false;
      }
    },
  },
  mounted() {
    this.form.msisdn = this.params.msisdn;
  },
};
</script>

<style>
.hero-form .hero_form__btn {
  color: #fff;
}
</style>