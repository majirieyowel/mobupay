<template>
  <v-container fluid>
    <div class="section">
      <div class="search">
        <v-text-field
          v-model="searchQuery"
          placeholder="Search contacts"
          solo
          clearable
        ></v-text-field>
      </div>
      <!--
        <div class="add-buttons">
          <v-btn class="btn--primary border-radius-none" tile> Contact +</v-btn>
        </div>
      -->
    </div>

    <div class="section">
      <div class="contacts">
        <div class="contact" v-for="contact in contacts" :key="contact.ref">
          <div class="contact-info">
            <div class="name">{{ contact.name }}</div>
            <div class="msisdn">{{ contact.msisdn }}</div>
          </div>
          <div class="dots">
            <v-menu left tile>
              <template v-slot:activator="{ on, attrs }">
                <v-btn icon dark v-bind="attrs" v-on="on">
                  <v-icon color="#757575" class="dot-item">
                    mdi-dots-vertical
                  </v-icon>
                </v-btn>
              </template>
              <v-list dense>
                <NuxtLink
                  no-prefetch
                  class="text-decoration-none"
                  :to="{
                    name: 'dashboard-send',
                    params: { dashboard: $auth.$state.user.msisdn },
                    query: { contact: 2348108125272 },
                  }"
                >
                  <v-list-item>
                    <v-list-item-icon>
                      <v-icon color="green">mdi-send-outline</v-icon>
                    </v-list-item-icon>
                    <v-list-item-title>Send Money</v-list-item-title>
                  </v-list-item>
                </NuxtLink>

                <v-list-item>
                  <v-list-item-icon>
                    <v-icon>mdi-receipt-text-plus-outline</v-icon>
                  </v-list-item-icon>
                  <v-list-item-title>Send Invoice</v-list-item-title>
                </v-list-item>
                <v-divider></v-divider>
                <v-list-item>
                  <v-list-item-icon>
                    <v-icon color="blue">mdi-pencil</v-icon>
                  </v-list-item-icon>
                  <v-list-item-title>Edit</v-list-item-title>
                </v-list-item>

                <v-list-item>
                  <v-list-item-icon>
                    <v-icon color="red">mdi-delete</v-icon>
                  </v-list-item-icon>
                  <v-list-item-title>Delete</v-list-item-title>
                </v-list-item>
              </v-list>
            </v-menu>
          </div>
        </div>

        <div></div>

        <div
          v-if="contactsHydrated && contacts.length < 1"
          class="mt-10 text-center empty"
        >
          <v-icon color="rgb(209 208 208)">mdi-archive-outline</v-icon>
          <h3 class="no-content">No contact found.</h3>
          <div>
            <v-btn class="btn--primary border-radius-none mt-5" tile>
              Add new +</v-btn
            >
          </div>
        </div>
      </div>
    </div>
  </v-container>
</template>

<script>
import errorCatch from "../../../functions/catchError";

export default {
  middleware: ["auth", "verify_url_msisdn"],
  name: "contacts",
  layout: "dashboard",
  meta: {
    breadcrumbs: [
      {
        text: "Contacts",
        disabled: true,
        help: true,
        to: "#",
      },
    ],
  },
  data: () => ({
    searchQuery: "",
    contacts: [],
    contactsDump: [],
    contactsHydrated: false,
  }),
  watch: {
    searchQuery(newValue, oldValue) {
      let contactsList = [...this.contactsDump];
      if (newValue) {
        this.contacts = contactsList.filter((item) => {
          let search_query = newValue.toLowerCase();
          let name = item.name.toLowerCase();
          return (
            name.includes(search_query) || item.msisdn.includes(search_query)
          );
        });
      } else {
        this.contacts = this.contactsDump;
      }
    },
  },
  methods: {
    sendMoney(msisdn) {
      let url = `/${this.$auth.$state.user.msisdn}/send?contact=${msisdn}`;
      window.location.href = url;
    },
  },
  async fetch() {
    try {
      const contacts = await this.$axios.$get("/contact");

      this.contacts = contacts.data;
      this.contactsDump = contacts.data;

      this.contactsHydrated = true;
    } catch (error) {
      errorCatch(error, this);
    }
  },
  mounted() {},
};
</script>

<style lang="scss" scoped>
.section {
  display: grid;

  // div:nth-of-type(1) {
  //   order: 2;
  // }

  // div:nth-of-type(2) {
  //   order: 1;
  // }

  .add-buttons {
    display: flex;
    justify-content: flex-end;
  }

  .contact {
    width: 100%;
    background: $white;
    margin-bottom: 5px;
    padding: 10px 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .empty {
    display: flex;
    justify-content: center;
    flex-direction: column;
    align-content: center;
    .v-icon {
      font-size: 100px;
    }
  }
}

.dot-item,
.v-list-item {
  cursor: pointer;
}

// tablet
@media (min-width: 600px) and (max-width: 960px) {
}

//large tablet to laptop
@media (min-width: 960px) {
  .section {
    display: grid;
    grid-template-columns: 1fr 1fr;

    .add-buttons {
    }
  }
}
</style>