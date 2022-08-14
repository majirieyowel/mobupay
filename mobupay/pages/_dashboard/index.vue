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
        name: 'dashboard-send',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Send</NuxtLink
    >
    |
    <NuxtLink
      :to="{
        name: 'dashboard-bank-accounts',
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
            name: 'dashboard-settings',
            params: { dashboard: $auth.$state.user.msisdn },
          }"
          >Help Center</NuxtLink
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
    </ul>

    <br />
    <hr />
    <br />
    <p>Transactions:</p>

    <v-simple-table height="300px">
      <template v-slot:default>
        <thead>
          <tr>
            <th class="text-left">Type</th>
            <th class="text-left">Amount</th>
            <th class="text-left">Status</th>
            <th class="text-left">Reference</th>
            <th class="text-left">Date</th>
          </tr>
        </thead>
        <tbody>
          <tr></tr>
          <tr v-for="item in transactions" :key="item.ref">
            <td>{{ item.type }}</td>
            <td>{{ item.amount | format_money }}</td>
            <td>{{ item.status }}</td>
            <td>{{ item.ref }}</td>
            <td>{{ $moment(item.inserted_at).calendar() }}</td>
          </tr>
        </tbody>
      </template>
    </v-simple-table>

    <br />
    <br />
    <button @click="$auth.logout()">Logout</button>
  </div>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  middleware: "auth",
  name: "dashboard",
  data: () => ({}),
  computed: mapGetters(["transactions"]),
  // async fetch() {
  //   // let transactions = await this.$axios.$get("/transaction");
  //   // this.$store.commit("pushTransactions", transactions.data.transactions);
  // },
  methods: {
    async load() {
      let transactions = await this.$axios.$get("/transaction");
      this.$store.commit("pushTransactions", transactions.data.transactions);
    },
  },
  // fetchOnServer: false,
  mounted() {
    this.load();
  },
};
</script>

<style>
</style>