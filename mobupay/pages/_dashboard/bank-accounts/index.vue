<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12 flex--end">
        <NuxtLink
          class="text-decoration-none"
          :to="{
            name: 'dashboard-bank-accounts-add',
            params: { dashboard: $auth.$state.user.msisdn },
          }"
        >
          <v-btn class="btn--primary" tile> + Add Bank Account</v-btn>
        </NuxtLink>
      </v-col>
      <div>
        <ul>
          <li v-for="(item, index) in bankAccounts" :key="item.ref">
            {{ index + 1 }} : Name: {{ item.name }} - {{ item.bank_name }} -
            {{ item.nuban }} ->
            <v-btn depressed color="error" @click="deleteBankAccount(item.ref)">
              Delete
            </v-btn>
          </li>
        </ul>
      </div>
    </v-row>
  </v-container>
</template>

<script>
import { mapGetters } from "vuex";
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "bank-accounts",
  layout: "dashboard",
  meta: {
    breadcrumbs: [
      {
        text: "Bank Accounts",
        disabled: true,
        help: true,
        to: "#",
      },
    ],
  },
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

<style lang="scss" scoped>
.text-end {
  text-align: end !important;
}
</style>