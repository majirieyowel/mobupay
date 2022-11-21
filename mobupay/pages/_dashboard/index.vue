<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12" class="pa-0">
        <div class="dash--header">
          <div class="balance">
            <span style="position: relative">
              <!--
                <span class="currency">{{ $auth.$state.user.currency }}</span>
              -->
              <span class="amount">
                Account Balance:
                {{ $auth.$state.user.account_balance | format_money }}</span
              >
              <br />
              <span class="amount">
                Book Balance:
                {{ $auth.$state.user.book_balance | format_money }}</span
              >
              <!--
                <v-icon class="help-icon">mdi-help-circle-outline</v-icon>
              -->
            </span>
          </div>
          <div class="transact">
            <v-btn color="blue-grey" small class="white--text">
              Withdraw
              <v-icon right> mdi-cash-plus </v-icon>
            </v-btn>

            <v-btn
              @click="$store.commit('setSendDialog', true)"
              color="#36b26c"
              small
              class="send-btn white--text"
            >
              Send
              <v-icon right class="send-icon"> mdi-send-outline</v-icon>
            </v-btn>
          </div>
        </div>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" class="pa-0 transaction">
        <v-card elevation="2">
          <v-card-title
            >Transactions
            <span @click="refreshTransactions" class="refresh-transaction">
              <v-icon color="blue">mdi-refresh</v-icon>
            </span>
          </v-card-title>
          <v-simple-table fixed-header>
            <template v-slot:default>
              <thead>
                <tr>
                  <th class="text-left">Type</th>
                  <th class="text-left">Status</th>
                  <th class="text-left">Sender</th>
                  <th class="text-left">Receiver</th>
                  <th class="text-left">Amount</th>

                  <th class="text-left">Reference</th>
                  <th class="text-left">Date&nbsp;Created</th>
                  <th class="text-left table--action">Action</th>
                </tr>
              </thead>
              <tbody v-if="transactions.length">
                <tr v-for="item in transactions" :key="item.ref">
                  <td>
                    {{
                      $auth.$state.user.msisdn == item.to_msisdn
                        ? "credit"
                        : "debit"
                    }}
                  </td>
                  <td>
                    {{ item.status }}
                    <v-icon
                      @click="showHelper(item.status)"
                      small
                      class="help-icon"
                      >mdi-help-circle-outline</v-icon
                    >
                  </td>
                  <td>
                    {{
                      $auth.$state.user.msisdn == item.from_msisdn
                        ? "You"
                        : item.from_msisdn
                    }}
                  </td>
                  <td>
                    {{
                      $auth.$state.user.msisdn == item.to_msisdn
                        ? "You"
                        : item.to_msisdn
                    }}
                  </td>
                  <td
                    v-html="
                      displayTransactionAmount(
                        item.status,
                        item.amount,
                        item.to_msisdn
                      )
                    "
                  ></td>
                  <!-- 
                    <td>
                      {{ displayTransactionAmount }}
                      {{ $auth.$state.user.msisdn == item.to_msisdn ? "+" : "-"
                      }}{{ item.amount | format_money }}
                    </td>
                  -->

                  <td>
                    {{
                      $auth.$state.user.msisdn == item.from_msisdn
                        ? item.from_ref
                        : item.to_ref
                    }}
                  </td>
                  <td>{{ $moment(item.inserted_at).calendar() }}</td>
                  <td>
                    <v-btn
                      :loading="item.reject_loading"
                      v-if="
                        item.status === 'floating' &&
                        $auth.$state.user.msisdn == item.to_msisdn
                      "
                      @click="rejectDialogue(item)"
                      outlined
                      x-small
                      color="error"
                      >Reject</v-btn
                    >
                    &nbsp;
                    <v-btn
                      @click="triggerTransactionDialogue(item)"
                      color="primary"
                      outlined
                      x-small
                      >View</v-btn
                    >
                    &nbsp;
                    <v-btn
                      v-if="
                        item.status === 'floating' &&
                        $auth.$state.user.msisdn == item.to_msisdn
                      "
                      :loading="item.accept_loading"
                      @click="acceptDialogue(item)"
                      outlined
                      x-small
                      color="success"
                      >Accept</v-btn
                    >
                    &nbsp;

                    <v-btn
                      :loading="item.reclaim_loading"
                      @click="reclaimDialogue(item)"
                      v-if="
                        item.status === 'floating' &&
                        $auth.$state.user.msisdn == item.from_msisdn
                      "
                      color="warning"
                      outlined
                      x-small
                      >Reclaim</v-btn
                    >
                  </td>
                </tr>
              </tbody>
              <tbody v-else>
                <tr>
                  <td style="text-align: center" colspan="8">
                    <div class="mt-5">
                      <v-icon x-large color="rgb(209 208 208)"
                        >mdi-archive-outline</v-icon
                      >
                      <h3 class="no-content">
                        Your transactions will show here.
                      </h3>
                    </div>
                  </td>
                </tr>
              </tbody>
            </template>
          </v-simple-table>
        </v-card>
      </v-col>
    </v-row>

    <Confirm
      :show="showAcceptDialogue"
      title="Accept"
      :item_ref="processingTransaction.ref"
      @yes="acceptMoney"
      @no="showAcceptDialogue = false"
    >
      <p>
        Click 'YES' below to accept
        {{ processingTransaction.amount | format_money }} from
        {{ processingTransaction.from_msisdn }}
      </p>
    </Confirm>

    <Confirm
      :show="showRejectDialogue"
      title="Reject"
      :item_ref="processingTransaction.ref"
      @yes="rejectMoney"
      @no="showRejectDialogue = false"
    >
      <p>
        Click 'YES' below to reject
        {{ processingTransaction.amount | format_money }} from
        {{ processingTransaction.from_msisdn }}
      </p>
    </Confirm>

    <Confirm
      :show="showReclaimDialogue"
      title="Reclaim"
      :item_ref="processingTransaction.ref"
      @yes="reclaimMoney"
      @no="showReclaimDialogue = false"
    >
      <p>
        Click 'YES' below to reclaim
        {{ processingTransaction.amount | format_money }} you sent to
        {{ processingTransaction.to_msisdn }}
      </p>
      <small
        >Reclaiming will cost you N10. You will receive
        {{ (processingTransaction.amount - 1000) | format_money }}</small
      >
    </Confirm>

    <v-dialog
      v-model="showTransactionDialogue"
      max-width="600px"
      content-class="transaction--dialogue"
    >
      <v-card>
        <v-card-title>
          <span class="text-h5"
            >Transaction -
            {{
              $auth.$state.user.msisdn == displayedTransaction.from_msisdn
                ? displayedTransaction.from_ref
                : displayedTransaction.to_ref
            }}
          </span>
        </v-card-title>
        <v-divider></v-divider>
        <v-card-text>
          <v-container>
            <v-row>
              <v-col cols="12">
                <div class="item">
                  <div class="left">Date:</div>
                  <div class="right">
                    {{ displayedTransaction.inserted_at }}
                  </div>
                </div>
              </v-col>
              <v-col cols="12">
                <div class="item">
                  <div class="left">Type:</div>
                  <div class="right">Self Funding</div>
                </div>
              </v-col>
              <v-col cols="12">
                <div class="item">
                  <div class="left">Amount:</div>
                  <div class="right">
                    {{ displayedTransaction.amount | format_money }}
                  </div>
                </div>
              </v-col>
              <v-col cols="12">
                <div class="item">
                  <div class="left">Status:</div>
                  <div class="right">
                    {{ displayedTransaction.status }}
                  </div>
                </div>
              </v-col>
              <v-col cols="12">
                <div class="item">
                  <div class="left">From:</div>
                  <div class="right">
                    {{ displayedTransaction.from_msisdn }}
                  </div>
                </div>
              </v-col>
              <v-col cols="12">
                <div class="item">
                  <div class="left">To:</div>
                  <div class="right">
                    {{ displayedTransaction.to_msisdn }}
                  </div>
                </div>
              </v-col>
              <v-col cols="12">
                <div class="item">
                  <div class="left">Narration:</div>
                  <div class="right">
                    {{ displayedTransaction.narration }}
                  </div>
                </div>
              </v-col>
              <v-col cols="12">
                <div class="item">
                  <div class="left">Summary:</div>
                  <div class="right">
                    You transfered NGN 5,000 to 2348573483743
                  </div>
                </div>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="blue darken-1"
            text
            @click="showTransactionDialogue = false"
          >
            Download
          </v-btn>
          <v-btn color="blue darken-1" text @click="showSupportDialogue = true">
            Support
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!--  Support Dialogue  -->
    <v-dialog
      v-model="showSupportDialogue"
      overlay-opacity="0.8"
      max-width="400px"
    >
      <v-card>
        <v-card-title>
          <span>Support</span>
        </v-card-title>
        <v-card-actions>
          <v-btn color="primary" text @click="showSupportDialogue = false">
            Close
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-container>
</template>

<script>
import { mapGetters } from "vuex";

import errorCatch from "../../functions/catchError";
export default {
  middleware: ["auth", "verify_url_msisdn"],
  layout: "dashboard",
  name: "dashboard",
  data: () => ({
    fixedTabs: false,
    leftTab: true,
    tab: null,

    /** Transaction actions */
    processingTransaction: {},
    showAcceptDialogue: false,
    showRejectDialogue: false,
    showReclaimDialogue: false,

    /** Transaction display */
    showTransactionDialogue: false,
    displayedTransaction: {},

    /** Support */
    showSupportDialogue: false,
  }),
  computed: {
    ...mapGetters(["transactions", "withdrawals", "breadcrumbs"]),
  },

  methods: {
    displayTransactionAmount(status, amount, to_msisdn) {
      let amount_formatted = this.$options.filters.format_money(amount);
      switch (status) {
        case "floating":
          return amount_formatted;
          break;
        case "rejected":
          return `<span style="text-decoration: line-through;">${amount_formatted}<span>`;

          break;
        case "accepted":
          return `<span">${
            this.$auth.$state.user.msisdn == to_msisdn ? "+" : "-"
          }${amount_formatted}<span>`;

          break;

        default:
          return "--";
          break;
      }
      return `<b>100 ${status}</b>`;
    },
    handleTabChange(event) {
      console.log("Tab changed", event);
    },
    refreshTransactions() {
      this.loadTransactions();
    },
    refreshWithdrawals() {
      this.loadWithdrawals();
    },
    async loadTransactions() {
      let transactions = await this.$axios.$get("/transaction");

      transactions.data.transactions.forEach((i) => {
        i.accept_loading = false;
        i.reject_loading = false;
        i.reclaim_loading = false;
      });
      this.$store.commit("pushTransactions", transactions.data.transactions);
    },
    async loadWithdrawals() {
      let withdrawals = await this.$axios.$get("/withdraw");

      this.$store.commit("pushWithdrawals", withdrawals.data.withdrawals);
    },

    /**
     * Transactions Actions start here
     */
    acceptDialogue(item) {
      this.processingTransaction = item;
      this.showAcceptDialogue = true;
    },
    rejectDialogue(item) {
      this.processingTransaction = item;
      this.showRejectDialogue = true;
    },
    reclaimDialogue(item) {
      this.processingTransaction = item;
      this.showReclaimDialogue = true;
    },

    acceptMoney(item_ref) {
      this.showAcceptDialogue = false;

      this.handle(item_ref, "accept", ({ amount }) => {
        this.$toast.success(
          `${
            this.$auth.$state.user.currency
          }${this.$options.filters.format_money(amount)} accepted successfully`
        );
      });
    },
    rejectMoney(item_ref) {
      this.showRejectDialogue = false;

      this.handle(item_ref, "reject", () => {
        this.$toast.success(
          `${
            this.$auth.$state.user.currency
          }${this.$options.filters.format_money(amount)} rejected successfully`
        );
      });
    },
    reclaimMoney(item_ref) {
      this.showReclaimDialogue = false;

      this.handle(item_ref, "reclaim", () => {
        this.$toast.success(
          `${this.processingTransaction.amount} has been reclaimed`
        );
      });
    },

    /** Transactions Actions end here */

    triggerTransactionDialogue(tranx) {
      this.showTransactionDialogue = true;
      this.displayedTransaction = tranx;
    },

    showHelper(feature) {
      console.log(feature);
    },

    /**
     * Handles a floating transaction
     *
     * @param {String} ref The transaction reference
     * @param {String} type The action to handle
     * @param {Function} callback A callback function that handles the success event
     */
    async handle(ref, type, callback) {
      this.transactionButtonLoader(true, ref, type);
      try {
        const response = await this.$axios.$post(`/transfer/${type}/${ref}`);
        this.transactionButtonLoader(false, ref, type);
        this.$store.commit("updateBalance", response.data.balance);
        this.$store.commit("updateTransactionStatus", {
          status: response.data.status,
          ref: response.data.ref,
        });
        callback(response.data);
      } catch (error) {
        errorCatch(error, this);
      }
    },

    /**
     * Manages the loading state of transaction buttons
     *
     * @param {Boolean} status
     * @param {String} ref The transaction reference
     * @param {String} producer The caller function
     * @return void
     */
    transactionButtonLoader(status, ref, producer) {
      this.$store.commit("transactionButtonLoadingStatus", {
        status,
        ref,
        producer,
      });
    },
  },
  mounted() {
    this.loadTransactions();
    this.loadWithdrawals();
  },
};
</script>

<style lang="scss" scoped>
.dash--header {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  padding-bottom: 30px;

  .balance,
  .transact {
    width: 100%;
  }

  .balance {
    text-align: center;
    padding: 12px 0px 35px 0px;

    .currency {
      position: absolute;
      font-size: 12px;
      left: -27px;
      top: -10px;
    }

    .amount {
      font-size: 30px;
      font-weight: 600;
    }

    .help-icon {
      font-size: 15px;
      position: absolute;
      top: 2px;
      right: -16px;
    }
  }

  .transact {
    display: flex;
    justify-content: space-around;

    button {
      text-transform: capitalize;
    }

    .table--action {
      min-width: 228px;
    }
  }

  .send-icon {
    font-size: 16px;
    position: relative;
    top: -3px;
    transform: rotate(-29deg);
  }
}

.transaction {
  .refresh-transaction {
    display: inline-block;
    margin-left: 10px;
    cursor: pointer;
  }
}

.dash--tabs {
  .dash--tab--active {
  }
}

//Small to medium tablet
@media (min-width: 600px) and (max-width: 960px) {
  .r {
    background-color: green !important;
  }

  .dash--header {
    flex-direction: row;
    padding-bottom: 0px;

    .balance {
      text-align: left;
      padding: 0;
      flex: 1;
    }

    .transact {
      width: 260px;
    }
  }
}

.transaction--dialogue {
  .item {
    display: flex;
  }
  .left {
    font-weight: 700;
    margin-right: 14px;
  }
  .right {
  }
}

//large tablet to laptop
@media (min-width: 960px) and (max-width: 1264px) {
  /* CSS */
}

//large tablet to laptop
@media (max-width: 1264px) {
  /* CSS */
}

// .dash--card {
//   .amount {
//     font-size: 30px;
//   }

//   .balance {
//     // font-weight: 700;
//     text-align: center;
//     width: 100%;
//     margin-bottom: 16px;

//     .help-icon {
//       font-size: 15px;
//       position: absolute;
//       top: 2px;
//       right: -16px;
//     }
//   }
//   .transfers button {
//     text-transform: capitalize;
//   }

//   .send-btn {
//     .send-icon {
//       font-size: 16px;
//       position: relative;
//       top: -3px;
//       transform: rotate(-29deg);
//     }
//   }

//   .currency {
//     position: absolute;
//     font-size: 12px;
//     left: -27px;
//     top: -10px;
//   }
// }
</style>