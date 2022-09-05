<template>
  <div>
    <NuxtLink
      :to="{
        name: 'dashboard-cards-add',
        params: { dashboard: $auth.$state.user.msisdn },
      }"
      >Add New</NuxtLink
    >

    <hr />
    <br />

    <ul>
      <li v-for="(item, index) in cards" :key="item.ref">
        {{ index + 1 }}. Bank: {{ item.bank }} <br />
        Card Type: {{ item.card_type }} <br />
        Last4: {{ item.last4 }} <br />
        <v-btn depressed color="error" @click="deleteCard(item.ref)">
          Delete
        </v-btn>
      </li>
    </ul>

    <br />
    <hr />
  </div>
</template>

<script>
import { mapGetters } from "vuex";
export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "cards",
  layout: "dashboard",
  meta: {
    breadcrumbs: [
      {
        text: "Cards",
        disabled: true,
        help: true,
        href: "#",
      },
    ],
  },
  computed: mapGetters(["cards"]),
  methods: {
    async deleteCard(ref) {
      try {
        if (confirm("Delete card?")) {
          const response = await this.$axios.delete(`card/${ref}`);

          if (response.data.status) {
            // commit removal
            this.$store.commit("removeCard", ref);

            this.$toast.success("Card deleted!");
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