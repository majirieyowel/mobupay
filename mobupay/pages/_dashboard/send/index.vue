<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12" class="pa-0 send">
        <div v-if="showTransferUI">
          <div class="col-12 col-sm-8 col-md-6 send-container">
            <div class="relative" v-if="step == 'fund'">
              <v-alert color="primary" text type="info">
                <p class="ma-0 pa-0 text-caption">
                  Send money to any valid phone number even if it's not
                  registered with Mobupay.
                  <br />
                  You can also retrieve your money back before it's claimed.
                </p>
              </v-alert>
              <v-row align="center">
                <v-col class="" cols="12">
                  <v-tabs
                    @change="form.to_msisdn = ''"
                    active-class="send--tab--active"
                    v-model="tab"
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
                        label=""
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
                        label=""
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
                    item-text="key"
                    item-value="value"
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

            <!--
            
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
            -->
          </div>

          <!--Verify Email Modal-->

          <template>
            <div class="text-center">
              <v-dialog v-model="showEmailModal" width="500">
                <v-card>
                  <v-card-title class="text-h6 lighten-2">
                    ADD YOUR EMAIL
                  </v-card-title>

                  <v-card-text class="mt-7 mb-0 pb-0">
                    <p>
                      Before creating your first transaction, please add your
                      email address.
                      <br />
                      This will be used for notifications only.
                    </p>
                  </v-card-text>

                  <v-container>
                    <v-row align="center">
                      <v-col class="d-flex mx-auto email-padding" cols="12">
                        <v-text-field
                          autofocus
                          placeholder="john.doe@gmail.com"
                          v-model="email_form.email"
                          label="Email Address"
                        >
                        </v-text-field>
                      </v-col>
                    </v-row>
                  </v-container>

                  <v-card-actions class="pb-5">
                    <v-spacer></v-spacer>
                    <v-btn
                      :loading="submittingEmail"
                      class="button"
                      color="#0052ff"
                      tile
                      @click="add_email"
                    >
                      Save Email
                    </v-btn>
                  </v-card-actions>
                </v-card>
              </v-dialog>
            </div>
          </template>

          <!--Verify Email Modal ends-->

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
  // meta: {
  //   breadcrumbs: [
  //     {
  //       text: "Send Money",
  //       disabled: true,
  //       help: true,
  //       to: "#",
  //     },
  //   ],
  // },
  computed: mapGetters(["cards"]),
  data: () => ({
    submitting: false,
    successModal: false,
    showTransferUI: true,
    showEmailModal: false,
    submittingEmail: false,
    showVerifyPasswordUI: false,
    verifyingTransaction: true,
    showEmailUI: false,
    step: "fund",
    showCards: false,

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

          break;
        case "Existing Card":
          if (this.cards.length == 0) {
            this.form.funding_channel = "Default";
            this.$toast.error("You don't have any existing cards");
          } else {
            this.showCards = true;
          }
          break;
        case "Balance":
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
        this.showEmailModal = true;
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
      this.submittingEmail = true;
      try {
        await this.$axios.$post("user/add-email", this.email_form);

        this.$store.commit("addEmail", this.email_form.email);

        this.$toast.success("Email added succcessfully!");

        this.showEmailModal = false;

        this.step = "fund";

        this.initiatePayment();
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.submittingEmail = false;
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
      const allowed_payment_channels = [
        {
          key: "Default",
          value: "Default",
        },
      ];
      if (this.$auth.$state.user.account_balance >= minimumBalance) {
        let key = `Balance (${
          this.$auth.$state.user.currency
        } ${this.$options.filters.format_money(
          this.$auth.$state.user.account_balance
        )})`;
        allowed_payment_channels.push({
          key,
          value: "Balance",
        });
      }
      if (this.cards.length > 0) {
        allowed_payment_channels.push({
          key: "Existing Card",
          value: "Existing Card",
        });
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
  mounted() {
    this.setupCards();
    this.setupPaymentChannels();
    console.log(this.$options.filters.format_money("4000"));
  },
};
</script>

<style lang="scss" scoped>
.v-application .text-caption {
  font-size: 0.85rem !important;
}
.email-padding {
  padding: 0px 24px;
}
.v-text-field {
  // padding-top: 12px;
  // margin-top: 4px; s
}
.v-tab {
  font-size: 0.725rem;
}
.v-tabs-items {
  background: #eee;
}
.send {
  .send-container {
    margin-top: 0%;
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