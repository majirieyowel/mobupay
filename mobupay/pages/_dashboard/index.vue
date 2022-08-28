<template>
  <div>
    <p>Dashboard</p>

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

    <ul>
      <li>
        <NuxtLink
          :to="{
            name: 'dashboard-invoice',
            params: { dashboard: $auth.$state.user.msisdn },
          }"
          >Invoice</NuxtLink
        >
      </li>
      <li>
        <NuxtLink
          :to="{
            name: 'dashboard-contacts',
            params: { dashboard: $auth.$state.user.msisdn },
          }"
          >Contacts</NuxtLink
        >
      </li>
      <li>
        <NuxtLink
          :to="{
            name: 'dashboard-bank-accounts',
            params: { dashboard: $auth.$state.user.msisdn },
          }"
          >Bank Accounts</NuxtLink
        >
      </li>

      <li>
        <NuxtLink
          :to="{
            name: 'dashboard-cards',
            params: { dashboard: $auth.$state.user.msisdn },
          }"
          >Cards</NuxtLink
        >
      </li>
      <li>
        <NuxtLink
          :to="{
            name: 'dashboard-activity',
            params: { dashboard: $auth.$state.user.msisdn },
          }"
          >Activity</NuxtLink
        >
      </li>
      <li>
        <NuxtLink
          :to="{
            name: 'dashboard-settings',
            params: { dashboard: $auth.$state.user.msisdn },
          }"
          >Settings</NuxtLink
        >
      </li>
      <li>
        <NuxtLink
          :to="{
            name: 'dashboard-settings',
            params: { dashboard: $auth.$state.user.msisdn },
          }"
          >Help Center</NuxtLink
        >
      </li>
    </ul>

    <br />
    <hr />
    <br />
    <p>Transactions: <span @click="refresh_transactions">Refresh</span></p>

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

    <p>Withdrawals: <span @click="refresh_withdrawals">Refresh</span></p>

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
  </div>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  middleware: ["auth", "verify_url_msisdn"],
  layout: "dashboard",
  name: "dashboard",
  data: () => ({
    showConfirmReclaimUI: false,
    reclaimRef: "",
  }),
  computed: mapGetters(["transactions", "withdrawals"]),

  methods: {
    refresh_transactions() {
      this.loadTransactions();
    },
    refresh_withdrawals() {
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

<style>
</style>