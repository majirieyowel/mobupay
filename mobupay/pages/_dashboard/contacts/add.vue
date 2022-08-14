<template>
  <div>
    <p>Add New Contact</p>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-select
          v-model="form.cbn_code"
          :items="banks"
          :loading="isLoadingBanks"
          item-text="name"
          item-value="code"
          label="Select bank"
        ></v-select>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-text-field
          v-model="form.nuban"
          label="Account number"
          @change="handleNubanChange"
        >
        </v-text-field>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-text-field
          v-model="form.name"
          label="Account name"
          readonly
          :loading="fetchingBankName"
        >
        </v-text-field>
      </v-col>
    </v-row>

    <v-row align="center">
      <v-col class="d-flex" cols="12" sm="6">
        <v-btn
          @click="submit"
          :loading="isSaving"
          elevation="2"
          outlined
          raised
          small
          >Save</v-btn
        >
      </v-col>
    </v-row>
  </div>
</template>

<script>
export default {
  middleware: "auth",
  name: "add-bank-account",
  data: () => ({
    fetchingBankName: false,
    isLoadingBanks: true,
    isSaving: false,
    banks: [],
    form: {
      nuban: "",
      cbn_code: "",
      name: "",
    },
  }),
  methods: {
    async submit() {
      this.isSaving = true;
      try {
        const selected_bank = this.fetchSelectedBankData(this.form.cbn_code);

        const response = await this.$axios.post("bank-account", {
          nuban: this.form.nuban,
          cbn_code: this.form.cbn_code,
          name: this.form.name,
          currency: selected_bank[0].currency,
          bank_name: selected_bank[0].name,
        });

        console.log(response.data);

        this.$store.commit(
          "createBankAccount",
          response.data.data.bank_account
        );

        this.$toast.success("Bank Account Added!");

        this.$router.push({
          name: "dashboard-bank-accounts",
          params: { dashboard: this.$auth.$state.user.msisdn },
        });
      } catch (error) {
        console.log(error);
      }
      this.isSaving = true;
    },
    async handleNubanChange(value) {
      this.fetchingBankName = true;

      try {
        const url = `misc/resolve-account-number?bank_code=${this.form.cbn_code}&account_number=${value}`;

        const response = await this.$axios.get(url);

        this.form.name = response.data.data.account_name;
      } catch (error) {
        console.log(error);
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
      const banks = await this.$axios.$get(process.env.paystackBanksEndpoint);

      let filtered = banks.data.filter((bank) => {
        return bank.code !== "";
      });
      this.banks = filtered;

      this.isLoadingBanks = false;
    } catch (error) {
      console.log(error);
    }
  },
};
</script>

<style>
</style>