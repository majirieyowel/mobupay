<template>
  <div>
    <v-row align="center">
      <v-col cols="12" sm="10" md="8" class="py-0 ml-auto">
        <v-alert color="orange" text>
          <p class="ma-0 pa-0 text-xs-5">
            Set a password to secure your account.
          </p>
        </v-alert>

        <div v-if="password_guide.display" class="password--guide mb-3">
          <div>
            <v-checkbox
              readonly
              :success="password_guide.min_8"
              label="Minimum of 8 characters"
              color="success"
              :value="password_guide.min_8"
              :input-value="password_guide.min_8"
              hide-details
            ></v-checkbox>
          </div>
          <div>
            <v-checkbox
              readonly
              :success="password_guide.lowercase"
              label="At least one lower case character"
              color="success"
              :value="password_guide.lowercase"
              :input-value="password_guide.lowercase"
              hide-details
            ></v-checkbox>
          </div>
          <div>
            <v-checkbox
              readonly
              :success="password_guide.uppercase"
              label="At least one upper case character"
              color="success"
              :value="password_guide.uppercase"
              :input-value="password_guide.uppercase"
              hide-details
            ></v-checkbox>
          </div>
          <div>
            <v-checkbox
              readonly
              :success="password_guide.digit"
              label="At least one digit"
              color="success"
              :value="password_guide.digit"
              :input-value="password_guide.digit"
              hide-details
            ></v-checkbox>
          </div>
        </div>

        <v-text-field
          ref="password"
          v-model="form.password"
          label="Password"
          autofocus
          :rules="rules.password"
          :append-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
          :type="showPassword ? 'text' : 'password'"
          @click:append="showPassword = !showPassword"
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
    showPassword: false,
    password_guide: {
      display: false,
      min_8: false,
      lowercase: false,
      uppercase: false,
      digit: false,
    },
    submitting: false,
    formHasErrors: false,
    form: {
      msisdn: "",
      password: "",
    },
    rules: {
      password: [
        (v) => (v || "").length > 0 || "Password is required",
        (v) => !/\s/g.test(v) || "No spaces allowed",
      ],
    },
  }),
  computed: {
    form_cast() {
      return {
        password: this.form.password,
      };
    },
    ...mapState(["onboarding"]),
  },
  watch: {
    "form.password"(newValue, oldValue) {
      newValue = newValue.replaceAll(" ", "");
      if (newValue.trim() == "") {
        this.password_guide.display = false;
      } else {
        this.password_guide.display = true;
      }

      // Min 8 characters
      if (newValue.trim().length >= 8) {
        this.password_guide.min_8 = true;
      } else {
        this.password_guide.min_8 = false;
      }

      // Atleast one lowercase
      if (/[a-z]/.test(newValue)) {
        this.password_guide.lowercase = true;
      } else {
        this.password_guide.lowercase = false;
      }

      // Atleast one lowercase
      if (/[A-Z]/.test(newValue)) {
        this.password_guide.uppercase = true;
      } else {
        this.password_guide.uppercase = false;
      }

      // Atleast one digit
      if (/[0-9]/.test(newValue)) {
        this.password_guide.digit = true;
      } else {
        this.password_guide.digit = false;
      }
    },
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

<style lang="scss" scoped>
.hero-form .hero_form__btn {
  color: #fff;
}

.password--guide {
  /* transition: display 2s; */

  .v-label {
    font-size: 12px;
  }
}
</style>