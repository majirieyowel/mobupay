<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12" class="pa-0">
        <div class="dash--header">
          <div class="balance">
            <span style="position: relative">
              <span class="currency">{{
                $auth.$state.user.balance.currency
              }}</span>
              <span class="amount">{{
                $auth.$state.user.balance.amount | format_money
              }}</span>
              <v-icon class="help-icon">mdi-help-circle-outline</v-icon>
            </span>
          </div>
          <div class="transact">
            <v-btn color="blue-grey" small class="white--text">
              Withdraw
              <v-icon right> mdi-cash-plus </v-icon>
            </v-btn>

            <NuxtLink
              :to="{
                name: 'dashboard-funding-options',
                params: { dashboard: $auth.$state.user.msisdn },
              }"
            >
              <v-btn color="#36b26c" small class="send-btn white--text">
                Send
                <v-icon right class="send-icon"> mdi-send-outline</v-icon>
              </v-btn>
            </NuxtLink>
          </div>
        </div>
      </v-col>
    </v-row>
    <v-row>
      <v-col cols="12" class="pa-0">
        <div class="dash--tabs">
          <!-- fixed tabs on mobile and left above -->
          <v-tabs
            @change="handleTabChange"
            active-class="dash--tab--active"
            hide-slider
            mobile-breakpoint="600"
            v-model="tab"
            :fixed-tabs="fixedTabs"
            :left="leftTab"
          >
            <v-tab>Transactions</v-tab>
            <v-tab>Withdrawals</v-tab>
          </v-tabs>

          <v-tabs-items v-model="tab">
            <v-tab-item>
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
                      <th class="text-left">Action</th>
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
                      <td>{{ item.status }}</td>
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
                            : remove_wait(item.to_msisdn)
                        }}
                      </td>
                      <td>
                        {{
                          $auth.$state.user.msisdn == item.to_msisdn
                            ? "+"
                            : "-"
                        }}{{ item.amount | format_money }}
                      </td>

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
                          :loading="item.refuse_loading"
                          v-if="
                            item.status === 'floating' &&
                            $auth.$state.user.msisdn == item.to_msisdn
                          "
                          @click="handle(item.ref, 'refuse')"
                          outlined
                          x-small
                          color="error"
                          >Refuse</v-btn
                        >
                        <v-btn
                          v-if="
                            item.status === 'floating' &&
                            $auth.$state.user.msisdn == item.to_msisdn
                          "
                          :loading="item.accept_loading"
                          @click="handle(item.ref, 'accept')"
                          outlined
                          x-small
                          color="success"
                          >Accept</v-btn
                        >

                        <v-btn
                          :loading="item.reclaim_loading"
                          @click="confirmReclaim(item.ref)"
                          v-if="
                            item.status === 'floating' &&
                            $auth.$state.user.msisdn == item.from_msisdn
                          "
                          color="primary"
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
                        No Transactions
                      </td>
                    </tr>
                  </tbody>
                </template>
              </v-simple-table>
            </v-tab-item>
            <v-tab-item>
              <v-card flat>
                <v-card-text>
                  <v-simple-table fixed-header>
                    <template v-slot:default>
                      <thead>
                        <tr>
                          <th class="text-left">Status</th>
                          <th class="text-left">Amount</th>
                          <th class="text-left">Bank&nbsp;Name</th>
                          <th class="text-left">Bank&nbsp;Account</th>
                          <th class="text-left">Reference</th>
                          <th class="text-left">Date&nbsp;Created</th>
                        </tr>
                      </thead>
                      <tbody v-if="withdrawals.length">
                        <tr v-for="item in withdrawals" :key="item.ref">
                          <td>
                            {{ item.status }}
                          </td>
                          <td>
                            {{ item.amount | format_money }}
                          </td>

                          <td>
                            {{ item.bank_name }}
                          </td>
                          <td>
                            {{ item.bank_account_number }}
                          </td>
                          <td>
                            {{ item.customer_ref }}
                          </td>
                          <td>{{ $moment(item.inserted_at).calendar() }}</td>
                        </tr>
                      </tbody>

                      <tbody v-else>
                        <tr>
                          <td style="text-align: center" colspan="6">
                            No Withdrawals
                          </td>
                        </tr>
                      </tbody>
                    </template>
                  </v-simple-table>
                </v-card-text>
              </v-card>
            </v-tab-item>
          </v-tabs-items>
        </div>
      </v-col>
    </v-row>
  </v-container>

  <!-- <div>
    <h4>
      Balance: {{ $auth.$state.user.balance.currency
      }}{{ $auth.$state.user.balance.amount | format_money }}
    </h4>
    <hr />
    <br />

    <NuxtLink
      :to="{
        name: 'dashboard-funding-options',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Send</NuxtLink
    >
    |
    <NuxtLink
      :to="{
        name: 'dashboard-withdraw',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Withdraw</NuxtLink
    >
    <hr />
    <br />

    <p>Transactions: <span @click="refreshTransactions">Refresh</span></p>

    <v-simple-table height="300px">
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
            <th class="text-left">Action</th>
          </tr>
        </thead>
        <tbody v-if="transactions.length">
          <tr v-for="item in transactions" :key="item.ref">
            <td>
              {{
                $auth.$state.user.msisdn == item.to_msisdn ? "credit" : "debit"
              }}
            </td>
            <td>{{ item.status }}</td>
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
                  : remove_wait(item.to_msisdn)
              }}
            </td>
            <td>
              {{ $auth.$state.user.msisdn == item.to_msisdn ? "+" : "-"
              }}{{ item.amount | format_money }}
            </td>

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
                :loading="item.refuse_loading"
                v-if="
                  item.status === 'floating' &&
                  $auth.$state.user.msisdn == item.to_msisdn
                "
                @click="handle(item.ref, 'refuse')"
                outlined
                x-small
                color="error"
                >Refuse</v-btn
              >
              <v-btn
                v-if="
                  item.status === 'floating' &&
                  $auth.$state.user.msisdn == item.to_msisdn
                "
                :loading="item.accept_loading"
                @click="handle(item.ref, 'accept')"
                outlined
                x-small
                color="success"
                >Accept</v-btn
              >

              <v-btn
                :loading="item.reclaim_loading"
                @click="confirmReclaim(item.ref)"
                v-if="
                  item.status === 'floating' &&
                  $auth.$state.user.msisdn == item.from_msisdn
                "
                color="primary"
                outlined
                x-small
                >Reclaim</v-btn
              >
            </td>
          </tr>
        </tbody>
        <tbody v-else>
          <tr>
            <td style="text-align: center" colspan="8">No Transactions</td>
          </tr>
        </tbody>
      </template>
    </v-simple-table>

    <br />
    <br />

    <p>Withdrawals: <span @click="refreshWithdrawals">Refresh</span></p>

    <v-simple-table height="300px">
      <template v-slot:default>
        <thead>
          <tr>
            <th class="text-left">Status</th>
            <th class="text-left">Amount</th>
            <th class="text-left">Bank&nbsp;Name</th>
            <th class="text-left">Bank&nbsp;Account</th>
            <th class="text-left">Reference</th>
            <th class="text-left">Date&nbsp;Created</th>
          </tr>
        </thead>
        <tbody v-if="withdrawals.length">
          <tr v-for="item in withdrawals" :key="item.ref">
            <td>
              {{ item.status }}
            </td>
            <td>
              {{ item.amount | format_money }}
            </td>

            <td>
              {{ item.bank_name }}
            </td>
            <td>
              {{ item.bank_account_number }}
            </td>
            <td>
              {{ item.customer_ref }}
            </td>
            <td>{{ $moment(item.inserted_at).calendar() }}</td>
          </tr>
        </tbody>

        <tbody v-else>
          <tr>
            <td style="text-align: center" colspan="6">No Withdrawals</td>
          </tr>
        </tbody>
      </template>
    </v-simple-table>

    <Confirm
      :show="showConfirmReclaimUI"
      instruction="Are you sure you want to reclaim you funds? This will come with a charge of 2%"
      title="Reclaim Transaction"
      :param="reclaimRef"
      @yes="reclaim"
      @no="showConfirmReclaimUI = false"
    />
  </div> -->
</template>

<script>
import { mapGetters } from "vuex";

export default {
  middleware: ["auth", "verify_url_msisdn"],
  layout: "dashboard",
  name: "dashboard",
  data: () => ({
    fixedTabs: false,
    leftTab: true,
    tab: null,
    showConfirmReclaimUI: false,
    reclaimRef: "",
  }),
  computed: mapGetters(["transactions", "withdrawals", "breadcrumbs"]),

  methods: {
    handleTabChange(event) {
      console.log("Tab changed", event);
    },
    refreshTransactions() {
      this.loadTransactions();
    },
    refreshWithdrawals() {
      this.loadWithdrawals();
    },
    remove_wait(string) {
      return string.startsWith("wait_") ? string.split("_")[1] : string;
    },
    async loadTransactions() {
      let transactions = await this.$axios.$get("/transaction");

      transactions.data.transactions.forEach((i) => {
        i.accept_loading = false;
        i.refuse_loading = false;
        i.reclaim_loading = false;
      });
      this.$store.commit("pushTransactions", transactions.data.transactions);
    },
    async loadWithdrawals() {
      let withdrawals = await this.$axios.$get("/withdraw");

      this.$store.commit("pushWithdrawals", withdrawals.data.withdrawals);
    },

    confirmReclaim(ref) {
      this.reclaimRef = ref;
      this.showConfirmReclaimUI = true;
    },

    reclaim(ref) {
      this.showConfirmReclaimUI = false;
      this.handle(ref, "reclaim");
    },

    /**
     * Handles a floating transaction
     *
     * @param {String} ref The transaction reference
     * @param {String} type The action to handle
     */
    async handle(ref, type) {
      this.transactionButtonLoader(true, ref, type);
      try {
        const response = await this.$axios.$post(`/transfer/${type}/${ref}`);
        this.transactionButtonLoader(false, ref, type);
        this.$store.commit("updateBalance", response.data.new_balance);
        this.$store.commit(
          "updateTransactionStatus",
          response.data.transaction
        );
      } catch (error) {
        this.transactionButtonLoader(false, ref, type);
        if (error.response.status == 400) {
          this.$toast.error(error.response.data.message);
        } else if (error.response.status == 500) {
          console.log(error);
        }
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
  }

  .send-icon {
    font-size: 16px;
    position: relative;
    top: -3px;
    transform: rotate(-29deg);
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