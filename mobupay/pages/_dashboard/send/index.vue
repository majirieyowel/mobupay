<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12" class="pa-0 send">
        <div v-if="showTransferUI">
          <div class="col-12 col-sm-8 col-md-6 send-container">
            <div class="relative" v-if="step == 'fund'">
              <!-- 
                <v-alert color="primary" text type="info">
                  <p class="ma-0 pa-0 text-caption">
                    Send money to any valid phone number even if it's not
                    registered with Mobupay.
                    <br />
                    You can also retrieve your money back before it's claimed.
                  </p>
                </v-alert>
              -->

              <v-form ref="form">
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
                          autofocus
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
              </v-form>
            </div>

            <div v-if="verifyingTransaction">Verifying...</div>

            <div v-if="step == 'success'">
              <div v-if="!verifiedTranxResp.metadata.receiver_registered">
                <v-alert outlined color="orange" border="left" text>
                  You've sent money to
                  <b>{{ verifiedTranxResp.transaction.to_msisdn }}</b> which is
                  not registered with Mobupay. We will attempt to notify them to
                  signup and claim their money.
                </v-alert>
              </div>
              <div class="transfer-success">
                <div class="success-image">
                  <img src="~/assets/img/check.png" />
                </div>
                <div class="success-content">
                  <p class="success-title">Transfer successful</p>

                  <div class="success-breakdown">
                    <p>
                      <span>Amount: </span
                      ><b
                        >{{ $auth.$state.user.currency
                        }}{{
                          verifiedTranxResp.transaction.amount | format_money
                        }}</b
                      >
                    </p>
                    <p>
                      <span>Phone Number: </span
                      ><b>{{ verifiedTranxResp.transaction.to_msisdn }}</b>
                    </p>
                    <p><span>Fee: </span> <b>NGN0.00</b></p>
                    <p>
                      <span> Transaction ID: </span
                      ><b>{{ verifiedTranxResp.transaction.to_ref }}</b>
                    </p>
                    <p>
                      <span> Payment Method: </span
                      ><b>{{
                        verifiedTranxResp.transaction.payment_channel
                      }}</b>
                    </p>
                  </div>
                </div>
                <div class="success-actions">
                  <v-btn class="button" color="error" tile>RECLAIM</v-btn>

                  <v-btn
                    @click="resetPayment"
                    class="button"
                    color="#0052ff"
                    tile
                    >CLOSE</v-btn
                  >
                </div>
                <div class="success-help">
                  <small>
                    <v-icon> mdi-chat-question-outline </v-icon> Need help with
                    this transaction?</small
                  >
                </div>
              </div>
            </div>
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
                      Save Email & Proceed
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
  computed: mapGetters(["cards"]),
  data() {
    const defaultForm = Object.freeze({
      card: "",
      to_msisdn: "",
      amount: "",
      narration: "",
      ip_address: "",
      device: "",
      funding_channel: "Default",
    });

    return {
      submitting: false,
      successModal: false,
      showTransferUI: true,
      showEmailModal: false,
      submittingEmail: false,
      showVerifyPasswordUI: false,
      verifyingTransaction: false,
      showEmailUI: false,
      step: "fund",
      showCards: false,
      showPaymentChannels: false,
      funding_channels: [],
      isLoadingContacts: true,
      contacts: [],
      tab: 0,
      tabCentered: false,
      tabLeft: true,
      email_form: {
        email: "",
      },
      form: Object.assign({}, defaultForm),
      verifiedTranxResp: {},
      defaultForm,
    };
  },
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
      if (!this.$auth.$state.user.email) {
        this.showEmailModal = true;
        return;
      }

      this.submitting = true;
      let ip = await this.$axios.$get(process.env.ipInfo);
      this.form.ip_address = ip.ip;
      this.form.device = window.navigator.userAgent;
      try {
        const response = await this.$axios.$post("/transfer", this.form);
        switch (response.data.payment_status) {
          case "INCOMPLETE":
            this.handleIncompletePayment(response.data);
            break;
          case "COMPLETE":
            this.handleCompletePayment(response.data);
            break;
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
    handleCompletePayment(data) {
      this.step = "success";
      this.verifiedTranxResp = data;
      this.$store.commit("updateBalance", data.balance);
    },
    async handleIncompletePayment(data) {
      switch (data.merchant.title) {
        case "paystack":
          this.handleWithPaystack(data);

          break;
        case "stripe":
          break;
      }
    },
    async handleWithPaystack({ customer, merchant, transaction, ref }) {
      try {
        const paystack = new PaystackPop();

        paystack.newTransaction({
          key: merchant.key,
          email: customer.email,
          amount: transaction.amount,
          channels: ["card"],
          reference: transaction.ref,
          onSuccess: (resp) => {
            if (resp.status == "success") {
              this.verifyPaystackPayment(resp.reference);
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

    async verifyPaystackPayment(ref) {
      this.verifyingTransaction = true;

      // TODO: figure out why the verification loader does not work and also handle failed verification

      try {
        const response = await this.$axios.post("/transfer/verify", { ref });
        let data = response.data.data;

        this.step = "success";
        this.verifiedTranxResp = data;
        this.$store.commit("mayBeAddCard", data.card);
        this.verifyingTransaction = false;
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
          key: "Card (Default)",
          value: "Default",
        },
      ];
      // if (this.$auth.$state.user.account_balance >= minimumBalance) {
      let key = `Balance (${
        this.$auth.$state.user.currency
      } ${this.$options.filters.format_money(
        this.$auth.$state.user.account_balance
      )})`;
      allowed_payment_channels.push({
        key,
        value: "Balance",
      });
      // }
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

    maybeLoadQueryContact() {
      // Grab msisdn from query params if exist
      let query = this.$route.query;
      if (query.contact) {
        this.tab = 1;
        this.form.to_msisdn = query.contact;
      }
      console.log(query);
    },
    resetPayment() {
      this.step = "fund";
      this.form = Object.assign({}, this.defaultForm);
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
  },
};
</script>

<style lang="scss" scoped>
.v-application .text-caption {
  font-size: 0.85rem !important;
}
.transfer-success {
  // margin-top: 10%;
  .success-image {
    height: 85px;
    display: flex;
    justify-content: center;
    align-content: center;
    background: #3ab54ba8;
    padding: 8px 0px;
  }
  .success-content {
    padding: 10px;
  }
  .success-title {
    font-weight: 800;
    font-size: 24px;
    text-align: center;
    margin: 20px 0px;
    color: #3ab54b;
  }

  .success-breakdown {
    p {
      margin-bottom: 10px;
      display: flex;
      justify-content: space-between;
      border-bottom: 0.5px dashed #a49e9e;
    }
  }

  .success-actions {
    text-align: center;
    padding: 30px 0;
  }
  img {
    width: 70px;
  }
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