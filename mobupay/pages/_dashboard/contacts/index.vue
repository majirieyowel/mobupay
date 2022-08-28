<template>
  <div>
    <p>Contacts</p>

    <NuxtLink
      :to="{
        name: 'dashboard',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Dashboard</NuxtLink
    >
    |

    <NuxtLink
      :to="{
        name: 'dashboard-contacts-add',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Add contacts</NuxtLink
    >

    <hr />
    <br />

    <!--
    <ul>
      <li v-for="(item, index) in bankAccounts" :key="item.ref">
        {{ index + 1 }} : Name: {{ item.name }} - {{ item.bank_name }} -
        {{ item.nuban }} ->
        <v-btn depressed color="error" @click="deleteBankAccount(item.ref)">
          Delete
        </v-btn>
      </li>
    </ul>

    -->

    <br />
    <hr />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "contacts",
  layout: "dashboard",
  computed: mapGetters(["bankAccounts"]),
  methods: {
    async deleteBankAccount(ref) {
      try {
        if (confirm("Delete account")) {
          const response = await this.$axios.delete(`bank-account/${ref}`);

          if (response.data.status) {
            // commit removal
            this.$store.commit("removeBankAccount", ref);

            this.$toast.success("Bank account deleted!");
          } else {
            this.$toast.error(response.data.message);
          }
        }
      } catch (error) {
        console.log(error);
      }
    },
  },
  mounted() {},
};
</script>

<style>
</style>