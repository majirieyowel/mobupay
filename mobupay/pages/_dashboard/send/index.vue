<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12" class="pa-0 send">
        <div v-if="showTransferUI">
          <div class="col-12 col-sm-8 col-md-6 mt-sm-5 send-container">
            <div class="relative" v-if="step == 'fund'">
              <h3 class="balance" v-if="showBalance">
                Balance: {{ $auth.$state.user.balance.currency
                }}{{ $auth.$state.user.balance.amount | format_money }}
              </h3>

              <v-row align="center">
                <v-col class="" cols="12">
                  <v-tabs
                    @change="form.to_msisdn = ''"
                    active-class="send--tab--active"
                    v-model="tab"
                    hide-slider
                    :centered="tabCentered"
                    :left="tabLeft"
                    background-color="#eee"
                  >
                    <v-tab>New Number</v-tab>
                    <v-tab>Contacts</v-tab>
                  </v-tabs>

                  <v-tabs-items v-model="tab">
                    <v-tab-item>
                      <v-text-field
                        v-model="form.to_msisdn"
                        label="Phone Number"
                        hint="International format e.g 2348108125270"
                        persistent-hint
                        type="number"
                        clearable
                      >
                      </v-text-field>
                    </v-tab-item>
                    <v-tab-item>
                      <v-autocomplete
                        v-model="form.to_msisdn"
                        :items="contacts"
                        item-text="name"
                        item-value="msisdn"
                        label="Phone number"
                        :loading="isLoadingContacts"
                        clearable
                      ></v-autocomplete
                    ></v-tab-item>
                  </v-tabs-items>
                </v-col>
              </v-row>

              <!--
                <v-row align="center">
                  <v-col class="d-flex" cols="12">
                    <v-autocomplete
                      :items="contacts"
                      item-text="name"
                      item-value="msisdn"
                      label="Phone number"
                      :loading="isLoadingContacts"
                      clearable
                    ></v-autocomplete>
                  </v-col>
                </v-row>
  
                <v-row align="center">
                  <v-col class="d-flex" cols="12">
                    <v-text-field
                      autofocus
                      v-model="form.to_msisdn"
                      label="Phone Number"
                      hint="International format e.g 2348108125270"
                      persistent-hint
                      type="number"
                    >
                    </v-text-field>
                  </v-col>
                </v-row>
              
              -->

              <v-row align="center">
                <v-col class="d-flex" cols="12">
                  <v-text-field
                    v-model="form.amount"
                    label="Amount"
                    type="number"
                  >
                  </v-text-field>
                </v-col>
              </v-row>

              <v-row align="center" v-if="showPaymentChannels">
                <v-col class="d-flex" cols="12">
                  <v-select
                    v-model="form.funding_channel"
                    :items="funding_channels"
                    item-text="label"
                    item-value="ref"
                    label="Payment Channel"
                  >
                  </v-select>
                </v-col>
              </v-row>

              <v-row align="center" v-if="showCards">
                <v-col class="d-flex" cols="12">
                  <v-select
                    v-model="form.card"
                    :items="cards"
                    item-text="label"
                    item-value="ref"
                    persistent-hint
                    label="Select Card"
                    hint="You will be prompted to enter your password"
                    clearable
                  >
                  </v-select>
                </v-col>
              </v-row>

              <v-row align="center">
                <v-col class="d-flex" cols="12">
                  <v-text-field
                    v-model="form.narration"
                    label="Narration (optional)"
                    clearable
                  >
                  </v-text-field>
                </v-col>
              </v-row>

              <v-row align="center">
                <v-col class="d-flex justify-center" cols="12">
                  <v-btn
                    @click="prePaymentCheck"
                    :loading="submitting"
                    class="button"
                    color="#0052ff"
                    tile
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

            <div v-if="step == 'email'">
              <p>ADD YOUR EMAIL</p>

              <p>
                Before creating your first transaction please add your email
                address
              </p>
              <p>This is for transactions notifications only</p>

              <v-row align="center">
                <v-col class="d-flex" cols="12" sm="6">
                  <v-text-field
                    v-model="email_form.email"
                    label="Email Address"
                  >
                  </v-text-field>
                </v-col>
              </v-row>

              <v-row align="center">
                <v-col class="d-flex" cols="12" sm="6">
                  <v-btn @click="add_email" elevation="2" outlined raised small
                    >Proceed</v-btn
                  >
                </v-col>
              </v-row>
            </div>
          </div>

          <VerifyPassword
            :show="showVerifyPasswordUI"
            @close="showVerifyPasswordUI = false"
            @successful="verifiedPassword"
          />
        </div>
      </v-col>
    </v-row>

    <div class="text-center">
      <v-dialog persistent v-model="successModal" width="500px">
        <v-card>
          <Success
            @close="successModal = false"
            class="pt-15"
            title="Payment Successful"
          >
            <p class="my-5 sent-summary">
              You have sent {{ transactionCurrency
              }}{{ transactionAmount | format_money }} to
              <b>{{ toMsisdn }}</b>
              <br />
            </p>
            <v-alert class="mt-10 mb-0" color="orange" text>
              <v-icon color="orange">mdi-information-outline</v-icon>
              <small class="ma-0 pa-0">
                You can retrieve your money back by clicking the "reclaim"
                button, in your transactions history.
              </small>
            </v-alert>
          </Success>
        </v-card>
      </v-dialog>
    </div>
  </v-container>
</template>

<script>
import { mapGetters } from "vuex";
import VerifyPassword from "../../../components/VerifyPassword.vue";
import Confirm from "../../../components/Confirm.vue";
import errorCatch from "../../../functions/catchError";

export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "send",
  layout: "dashboard",
  head: {
    script: [{ src: "https://js.paystack.co/v2/inline.js" }],
  },
  meta: {
    breadcrumbs: [
      {
        text: "Send",
        disabled: true,
        help: true,
        to: "#",
      },
    ],
  },
  computed: mapGetters(["cards"]),
  data: () => ({
    submitting: false,
    successModal: false,
    showTransferUI: true,
    showVerifyPasswordUI: false,
    verifyingTransaction: true,
    showEmailUI: false,
    step: "fund",
    showCards: false,
    showBalance: false,
    showPaymentChannels: false,
    transactionAmount: "",
    toMsisdn: "",
    transactionCurrency: "",
    funding_channels: [],
    isLoadingContacts: true,
    contacts: [],
    tab: 0,
    tabCentered: true,
    tabLeft: false,
    email_form: {
      email: "",
    },
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
      // check for email added

      if (!this.$auth.$state.user.email) {
        this.step = "email";
        return;
      }

      this.submitting = true;
      let ip = await this.$axios.$get(process.env.ipURL);
      this.form.ip_address = ip.origin;
      this.form.device = window.navigator.userAgent;
      try {
        const response = await this.$axios.$post("/transfer", this.form);
        switch (response.data.funding_channel) {
          case "Default":
            this.handleDefaultPayment(response.data);
            break;
          // case "Existing Card":
          //   this.paymentSuccess(response.data);
          // case "Balance":
          //   this.$store.commit("updateBalance", response.data.new_balance);
          //   this.paymentSuccess(response.data);
          //   break;
        }
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.submitting = false;
      }
    },
    async add_email() {
      try {
        await this.$axios.$post("user/add-email", this.email_form);

        this.$store.commit("addEmail", this.email_form.email);

        this.$toast.success("Email added succcessfully!");

        this.step = "fund";

        this.initiatePayment();
      } catch (error) {
        errorCatch(error);
      }
    },
    async handleDefaultPayment({ email, paystack_pk, channels, amount, ref }) {
      try {
        const paystack = new PaystackPop();

        paystack.newTransaction({
          key: paystack_pk,
          email: email,
          amount: amount,
          channels: channels,
          reference: ref,
          onSuccess: (transaction) => {
            if (transaction.status == "success") {
              this.verifyDefaultPayment(transaction.reference);
            } else {
              this.$toast.error("Payment was not successful!");
            }
          },
          onCancel: () => {
            this.$toast.info(
              "You cancelled the payment widget. No money was transfered."
            );
          },
        });
      } catch (error) {
        this.$toast.error("Cannot load widget");
      }
    },

    async verifyDefaultPayment(ref) {
      this.verifyingTransaction = true;

      try {
        const response = await this.$axios.post("/transfer/verify", { ref });
        this.paymentSuccess(response.data.data);
      } catch (error) {
        errorCatch(error, this);
      }
    },
    async verifyTransaction(payload) {
      this.verifyingTransaction = true;
      try {
        const response = await this.$axios.post("/transfer/verify", payload);
        this.paymentSuccess(response.data.data);
      } catch (error) {
        errorCatch(error, this);
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
    maybeLoadQueryContact() {
      // Grab msisdn from query params if exist
      let query = this.$route.query;
      if (query.contact) {
        this.tab = 1;
        this.form.to_msisdn = query.contact;
      }
      console.log(query);
    },
  },
  mounted() {
    this.setupCards();
    this.setupPaymentChannels();
  },
  async fetch() {
    try {
      const contacts = await this.$axios.$get("/contact");

      contacts.data.map((item) => {
        item.name = `${item.name} (${item.msisdn})`;
      });

      this.contacts = contacts.data;

      this.isLoadingContacts = false;

      this.maybeLoadQueryContact();
    } catch (error) {
      errorCatch(error, this);
    }
  },
  components: { VerifyPassword, Confirm },
};
</script>

<style lang="scss" scoped>
.v-tabs-items {
  background: #eee;
}
.send {
  .send-container {
    margin-top: 10%;
  }

  .balance {
    position: absolute;
    top: -24px;
    text-align: center;
    width: 100%;
  }
}

.sent-summary {
  font-size: 15px;
}

// tablet
@media (min-width: 600px) and (max-width: 960px) {
  .send {
    .send-container {
      margin: 0 auto;
    }
  }
}

//large tablet to laptop
@media (min-width: 960px) {
  /* CSS */
  .send {
    .send-container {
      margin-left: 38px;
    }
  }
}
</style>