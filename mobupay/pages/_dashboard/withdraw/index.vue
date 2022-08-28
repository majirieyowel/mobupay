<template>
  <div>
    <p>Withdraw your money</p>

    <NuxtLink
      :to="{
        name: 'dashboard',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Dashboard</NuxtLink
    >

    <hr />
    <br />

    <h2>
      Balance: {{ $auth.$state.user.balance.currency
      }}{{ $auth.$state.user.balance.amount | format_money }}
    </h2>

    <br />

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-select
          v-model="form.bank_account_ref"
          :items="bankAccounts"
          item-text="label"
          item-value="ref"
          persistent-hint
          label="Select Account"
          clearable
        >
        </v-select>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-text-field v-model="form.amount" label="Amount"> </v-text-field>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex justify-end" cols="12" sm="6">
        <v-btn @click="preWithdrawal" elevation="2" outlined raised small
          >Proceed</v-btn
        >
      </v-col>
    </v-row>

    <br />
    <hr />

    <VerifyPassword
      :show="showVerifyPasswordUI"
      @close="showVerifyPasswordUI = false"
      @successful="withdraw"
    />

    <v-dialog v-model="addBankAccount" width="500" persistent>
      <v-card>
        <v-card-title class="text-h6 primary">
          <div>
            <span>Add Bank Account</span>
          </div>
        </v-card-title>

        <v-card-text class="mt-6 pb-0">
          <p>You need to add a bank account to withdraw funds.</p>
        </v-card-text>

        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            @click="$router.back()"
            color="grey"
            class="ma-1"
            depressed
            small
          >
            &lt;&lt; Back
          </v-btn>

          <NuxtLink
            :to="{
              name: 'dashboard-bank-accounts-add',
              params: { dashboard: $auth.$state.user.msisdn },
              query: { redirect: 'dashboard-withdraw' },
            }"
          >
            <v-btn color="primary" class="ma-1" depressed small> Add + </v-btn>
          </NuxtLink>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "withdraw",
  layout: "dashboard",
  computed: mapGetters(["bankAccounts"]),
  data: () => ({
    addBankAccount: false,
    showVerifyPasswordUI: false,
    form: {
      bank_account_ref: "",
      amount: "",
      ip_address: "",
      device: "",
    },
  }),
  methods: {
    preWithdrawal() {
      // Validation checks here

      this.showVerifyPasswordUI = true;
    },
    async withdraw() {
      this.showVerifyPasswordUI = false;

      let ip = await this.$axios.$get(process.env.ipURL);
      this.form.ip_address = ip.origin;
      this.form.device = window.navigator.userAgent;
      try {
        const response = await this.$axios.$post("/withdraw", this.form);

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
    setupBankAccounts() {
      if (this.bankAccounts.length > 0) {
        for (let index = 0; index < this.bankAccounts.length; index++) {
          const element = this.bankAccounts[index];
          element.label = `${element.bank_name} - ${element.nuban}`;
        }
      } else {
        this.addBankAccount = true;
      }
    },
  },
  mounted() {
    this.setupBankAccounts();
  },
};
</script>

<style>
</style>