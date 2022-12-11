<template>
  <v-container fluid>
    <v-row class="login my-8 my-md-16">
      <v-col cols="12" md="5" class="login-card ma-0 mx-auto">
        <h2 class="pl-3 pl-sm-14 title">Login</h2>

        <v-form @keyup.native.enter="pre_validate">
          <v-container fluid class="px-3 px-sm-14 login-body">
            <v-row>
              <v-col>
                <v-row align="center">
                  <v-col>
                    <v-text-field
                      ref="msisdn"
                      clearable
                      v-model="form.msisdn"
                      label="Mobile number"
                      hide-details="auto"
                      :rules="rules.msisdn"
                      hint="International format e.g 2348108125270"
                      persistent-hint
                    >
                    </v-text-field>
                  </v-col>
                </v-row>

                <v-row>
                  <v-col>
                    <v-text-field
                      ref="password"
                      v-model="form.password"
                      :append-icon="showPassword ? 'mdi-eye' : 'mdi-eye-off'"
                      label="Password"
                      hide-details="auto"
                      :type="showPassword ? 'text' : 'password'"
                      :rules="rules.password"
                      @click:append="showPassword = !showPassword"
                    >
                    </v-text-field>
                  </v-col>
                </v-row>

                <v-row>
                  <v-col cols="12" md="6" class="text-center mt-4 mx-auto">
                    <v-btn
                      block
                      @click="pre_validate"
                      :loading="submitting"
                      class="button"
                      color="#0052ff"
                      tile
                      >Login</v-btn
                    >
                  </v-col>
                  <v-col cols="12" class="text-center">
                    <p class="text-4 forgot-password" @click="forgotPassword">
                      Forgot Password?
                    </p>
                  </v-col>
                </v-row>
              </v-col>
            </v-row>
          </v-container>
        </v-form>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import errorCatch from "../functions/catchError";
export default {
  name: "login",
  middleware: "auth",
  auth: "guest",
  data: () => ({
    submitting: false,
    showPassword: false,
    formHasErrors: false,
    form: {
      msisdn: "2348108125270",
      password: "@Nelie&e12",
    },
    rules: {
      msisdn: [(v) => (v || "").length > 0 || "Mobile number is required"],
      password: [(v) => (v || "").length > 0 || "Input your password"],
    },
  }),
  computed: {
    form_cast() {
      return {
        msisdn: this.form.msisdn,
        password: this.form.password,
      };
    },
  },

  methods: {
    async pre_validate() {
      this.formHasErrors = false;

      Object.keys(this.form_cast).forEach((f) => {
        if (!this.form_cast[f]) this.formHasErrors = true;

        this.$refs[f].validate(true);
      });

      if (!this.formHasErrors) await this.login();
    },
    async login() {
      this.formHasErrors = false;
      this.submitting = true;
      try {
        await this.$auth.loginWith("local", {
          data: this.form,
        });
        this.$router.push({
          name: "dashboard",
          params: { dashboard: this.form.msisdn },
        });
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.submitting = false;
      }
    },
    forgotPassword(e) {
      e.preventDefault();

      this.$toast.info("Feature coming soon. Calm down!");
    },
  },
  mounted() {},
};
</script>

<style lang="scss" scoped>
.login {
  // margin: 35px 0px;
  .login-card {
    padding: 60px 0 40px 0;
    border-radius: 5px;
    position: relative;
    background-color: $white;
    box-sizing: border-box;
    box-shadow: 0 1px 3px rgb(0 0 0 / 12%), 0 1px 2px rgb(0 0 0 / 24%);
  }

  .title {
    position: relative;
    z-index: 1;
    border-left: 5px solid $primary;
    margin: 0 0 35px;
    color: $primary;
    font-weight: 600;
    text-transform: uppercase;
  }

  .login-body {
    // padding: 0px 56px;

    .button {
      background-color: $primary;
      color: $white;
      width: 50%;
    }
  }

  .forgot-password {
    color: $grey_text;
    cursor: pointer;
    &:hover {
      text-decoration: none;
      color: $primary;
    }
  }
}
</style>
