<template>
  <div v-if="showTransferUI">
    <div>
      <p>Send Money To Phone Number</p>

      <NuxtLink
        :to="{
          name: 'dashboard',
          params: { dashboard: $auth.$state.user.msisdn },
        }"
        >Dashboard</NuxtLink
      >

      <NuxtLink
        :to="{
          name: 'dashboard-send',
          params: { dashboard: $auth.$state.user.msisdn },
        }"
      >
        &lt;&lt; Send Options</NuxtLink
      >
      <hr />
      <br />

      <div v-if="step == 'fund'">
        <h2 v-if="showBalance">
          Balance: {{ $auth.$state.user.balance.currency
          }}{{ $auth.$state.user.balance.amount | format_money }}
        </h2>

        <v-row align="center" v-if="showPaymentChannels">
          <v-col class="d-flex" cols="12" sm="6">
            <v-select
              v-model="form.funding_channel"
              :items="funding_channels"
              item-text="label"
              item-value="ref"
              persistent-hint
              label="Payment Channel"
            >
            </v-select>
          </v-col>
        </v-row>

        <v-row align="center">
          <v-col class="d-flex" cols="12" sm="6">
            <v-text-field
              autofocus
              v-model="form.to_msisdn"
              label="Phone Number"
            >
            </v-text-field>
          </v-col>
        </v-row>

        <v-row align="center">
          <v-col class="d-flex" cols="12" sm="6">
            <v-text-field v-model="form.amount" label="Amount"> </v-text-field>
          </v-col>
        </v-row>

        <v-row align="center" v-if="showCards">
          <v-col class="d-flex" cols="12" sm="6">
            <v-select
              v-model="form.card"
              :items="cards"
              item-text="label"
              item-value="ref"
              persistent-hint
              label="Select Card"
              clearable
            >
            </v-select>
          </v-col>
        </v-row>

        <v-row align="center">
          <v-col class="d-flex" cols="12" sm="6">
            <v-text-field
              v-model="form.narration"
              label="Narration (optional)"
              clearable
            >
            </v-text-field>
          </v-col>
        </v-row>

        <v-row align="center">
          <v-col class="d-flex" cols="12" sm="6">
            <v-btn @click="prePaymentCheck" elevation="2" outlined raised small
              >Proceed</v-btn
            >
          </v-col>
        </v-row>
      </div>

      <div v-if="step == 'verify'">
        <div v-if="verifyingTransaction">Verifying...</div>
        <Success v-else title="Payment Successful">
          <p>
            You have sent {{ transactionCurrency
            }}{{ transactionAmount | format_money }} to
            <b>{{ toMsisdn }}</b>
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

    <VerifyPassword
      :show="showVerifyPasswordUI"
      @close="showVerifyPasswordUI = false"
      @successful="verifiedPassword"
    />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import VerifyPassword from "../../../components/VerifyPassword.vue";
import Confirm from "../../../components/Confirm.vue";

export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "transfer",
  layout: "dashboard",
  computed: mapGetters(["cards"]),
  data: () => ({
    showTransferUI: false,
    showVerifyPasswordUI: false,
    verifyingTransaction: true,
    step: "fund",
    showCards: false,
    showBalance: false,
    showPaymentChannels: false,
    transactionAmount: "",
    toMsisdn: "",
    transactionCurrency: "",
    funding_channels: [],
    form: {
      card: "",
      to_msisdn: "2348108125270",
      amount: "",
      narration: "",
      ip_address: "",
      device: "",
      funding_channel: "Default",
    },
  }),
  watch: {
    "form.funding_channel"(newValue, oldValue) {
      switch (newValue) {
        case "Default":
          this.showCards = false;
          this.showBalance = false;
          break;
        case "Existing Card":
          if (this.cards.length == 0) {
            this.form.funding_channel = "Default";
            this.$toast.error("You don't have any existing cards");
          } else {
            this.showCards = true;
            this.showBalance = false;
          }
          break;
        case "Balance":
          this.showBalance = true;
          this.showCards = false;
          break;
        default:
          break;
      }
    },
  },
  methods: {
    async prePaymentCheck() {
      if (
        this.form.funding_channel == "Existing Card" &&
        this.cards.length > 0
      ) {
        this.showVerifyPasswordUI = true;
      } else {
        this.initiatePayment();
      }
    },
    async verifiedPassword() {
      this.showVerifyPasswordUI = false;
      this.initiatePayment();
    },
    async initiatePayment() {
      let ip = await this.$axios.$get(process.env.ipURL);
      this.form.ip_address = ip.origin;
      this.form.device = window.navigator.userAgent;
      try {
        const response = await this.$axios.$post("/transfer", this.form);
        switch (response.data.funding_channel) {
          case "Default":
            window.location.href = response.data.transaction.authorization_url;
            break;
          case "Existing Card":
            this.paymentSuccess(response.data);
          case "Balance":
            this.$store.commit("updateBalance", response.data.new_balance);
            this.paymentSuccess(response.data);
            break;
        }
      } catch (error) {
        if (error.response.status == 400) {
          this.$toast.error(error.response.data.message);
        } else if (error.response.status == 422) {
          this.$toast.error(error.response.data.message);
          console.log(error.response.data.error);
        }
      }
    },
    async verifyTransaction(payload) {
      this.verifyingTransaction = true;
      try {
        const response = await this.$axios.post("/transfer/verify", payload);
        this.paymentSuccess(response.data.data);
      } catch (error) {
        console.log(error);
      }
    },
    setupCards() {
      if (this.cards.length > 0) {
        for (let index = 0; index < this.cards.length; index++) {
          const element = this.cards[index];
          element.label = `${element.bank} (${element.card_type})`;
        }
      }
    },
    setupPaymentChannels() {
      const minimumBalance = 10000; //kobo
      const allowed_payment_channels = ["Default"];
      if (this.$auth.$state.user.balance.amount >= minimumBalance) {
        allowed_payment_channels.push("Balance");
      }
      if (this.cards.length > 0) {
        allowed_payment_channels.push("Existing Card");
      }
      if (allowed_payment_channels.length !== 1) {
        this.showPaymentChannels = true;
        this.funding_channels = allowed_payment_channels;
      }
    },
    paymentSuccess(data) {
      this.step = "verify";
      this.transactionAmount = data.transaction_amount;
      this.transactionCurrency = data.transaction_currency;
      this.toMsisdn = data.to_msisdn;
      this.$store.commit("mayBeAddCard", data.card);
      this.verifyingTransaction = false;
    },
  },
  mounted() {
    this.setupCards();
    this.setupPaymentChannels();
    let route_params = this.$route.query;
    if (route_params.consolidator && route_params.reference) {
      this.step = "verify";
      this.showTransferUI = true;
      this.verifyTransaction({
        consolidator: route_params.consolidator,
        ref: route_params.reference,
      });
    } else {
      this.step = "fund";
      this.showTransferUI = true;
    }
  },
  components: { VerifyPassword, Confirm },
};
</script>

<style scoped>
</style>