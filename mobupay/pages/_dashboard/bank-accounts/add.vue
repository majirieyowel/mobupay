<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12" class="pa-0 account">
        <div class="col-12 col-sm-8 col-md-6 mt-sm-5 account-container">
          <v-row align="center">
            <v-col class="d-flex" cols="12">
              <v-select
                v-model="form.cbn_code"
                ref="cbn_code"
                :items="banks"
                :loading="isLoadingBanks"
                item-text="name"
                item-value="code"
                label="Select bank"
                :rules="rules.cbn_code"
              ></v-select>
            </v-col>
          </v-row>

          <v-row align="center">
            <v-col class="d-flex" cols="12">
              <v-text-field
                v-model="form.nuban"
                ref="nuban"
                label="Account number"
                @change="handleNubanChange"
                :rules="rules.nuban"
              >
              </v-text-field>
            </v-col>
          </v-row>

          <v-row align="center">
            <v-col cols="12">
              <v-text-field
                v-model="form.name"
                ref="name"
                label="Account name"
                readonly
                :loading="fetchingBankName"
                :rules="rules.name"
              >
              </v-text-field>
            </v-col>
          </v-row>

          <v-row align="center">
            <v-col class="d-flex justify-center" cols="12">
              <v-btn
                @click="presubmit"
                :loading="submitting"
                class="button"
                color="#0052ff"
                tile
                >Proceed</v-btn
              >
            </v-col>
          </v-row>
        </div>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import catchError from "../../../functions/catchError";

export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "add-bank-account",
  layout: "dashboard",
  meta: {
    breadcrumbs: [
      {
        text: "Bank Accounts",
        disabled: false,
        to: {
          name: "dashboard-bank-accounts",
          params: { dashboard: "" },
        },
      },
      {
        text: "Add",
        disabled: true,
        to: "#",
      },
    ],
  },
  data: () => ({
    fetchingBankName: false,
    isLoadingBanks: true,
    submitting: false,
    formHasErrors: false,
    banks: [],
    form: {
      nuban: "",
      cbn_code: "",
      name: "",
    },
    rules: {
      cbn_code: [(v) => (v || "").length > 0 || "Select your bank"],
      nuban: [(v) => (v || "").length > 0 || "Enter your account number"],
      name: [
        (v) => (v || "").length > 0 || "Readonly: Unresolved account name",
      ],
    },
  }),

  computed: {
    form_cast() {
      return {
        cbn_code: this.form.cbn_code,
        nuban: this.form.nuban,
        name: this.form.name,
      };
    },
  },
  methods: {
    async presubmit() {
      this.formHasErrors = false;

      Object.keys(this.form_cast).forEach((f) => {
        if (!this.form_cast[f]) this.formHasErrors = true;

        this.$refs[f].validate(true);
      });

      if (!this.formHasErrors) await this.submit();
    },
    async submit() {
      this.submitting = true;
      try {
        const selected_bank = this.fetchSelectedBankData(this.form.cbn_code);

        const response = await this.$axios.post("bank-account", {
          nuban: this.form.nuban,
          cbn_code: this.form.cbn_code,
          name: this.form.name,
          currency: selected_bank[0].currency,
          bank_name: selected_bank[0].name,
        });

        this.$store.commit(
          "createBankAccount",
          response.data.data.bank_account
        );

        this.$toast.success("Bank Account Added!");

        let redirect_to = "dashboard-bank-accounts";

        if (this.$route.query.redirect) {
          redirect_to = this.$route.query.redirect;
        }

        this.$router.push({
          name: redirect_to,
          params: { dashboard: this.$auth.$state.user.msisdn },
        });
      } catch (error) {
        catchError(error, this);
      } finally {
        this.submitting = false;
      }
    },
    async handleNubanChange(value) {
      this.fetchingBankName = true;

      try {
        const url = `misc/resolve-account-number?bank_code=${this.form.cbn_code}&account_number=${value}`;

        const response = await this.$axios.get(url);

        this.form.name = response.data.data.account_name;
      } catch (error) {
        catchError(error, this);
      }

      this.fetchingBankName = false;
    },
    fetchSelectedBankData(cbn_code) {
      return this.banks.filter((bank) => {
        return bank.code == cbn_code;
      });
    },
  },
  mounted() {},
  async fetch() {
    try {
      const banks = await this.$axios.$get(process.env.banksListEndpoint);

      let filtered = banks.data.filter((bank) => {
        return bank.code !== "";
      });
      this.banks = filtered;

      this.isLoadingBanks = false;
    } catch (error) {
      catchError(error, this);
    }
  },
};
</script>

<style lang="scss" scoped>
.account {
  .account-container {
    margin-top: 10%;
  }
}

// tablet
@media (min-width: 600px) and (max-width: 960px) {
  .account {
    .account-container {
      margin: 0 auto;
    }
  }
}

//large tablet to laptop
@media (min-width: 960px) {
  /* CSS */
  .account {
    .account-container {
      margin-left: 38px;
    }
  }
}
</style>