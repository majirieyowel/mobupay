<template>
  <v-container fluid>
    <v-row>
      <v-col cols="12" class="pa-0">
        <div class="section">
          <div class="search">
            <v-text-field
              v-model="searchQuery"
              placeholder="Search contacts"
              solo
              clearable
            ></v-text-field>
          </div>
          <div class="add-buttons">
            <v-btn class="border-radius-none" tile> Import +</v-btn>
            <v-btn @click="launch" class="btn--primary border-radius-none" tile>
              New Contact +</v-btn
            >
          </div>
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
                        query: { contact: contact.msisdn },
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
                      <v-list-item-title @click="editContact(contact)"
                        >Edit</v-list-item-title
                      >
                    </v-list-item>

                    <v-list-item>
                      <v-list-item-icon>
                        <v-icon color="red">mdi-delete</v-icon>
                      </v-list-item-icon>
                      <v-list-item-title @click="deleteContact(contact.ref)"
                        >Delete</v-list-item-title
                      >
                    </v-list-item>
                  </v-list>
                </v-menu>
              </div>
            </div>

            <div
              v-if="contactsHydrated && contacts.length < 1"
              class="mt-10 text-center empty"
            >
              <h3 class="no-content">No contact found.</h3>
              <div>
                <v-btn
                  @click="launch"
                  class="btn--primary border-radius-none mt-5"
                  tile
                >
                  Add new +</v-btn
                >
              </div>
            </div>
          </div>
        </div>

        <div class="add-contact">
          <v-form ref="form">
            <v-dialog
              :value="addContactModal"
              :width="addModalWidth"
              persistent
            >
              <v-card>
                <v-card-title>
                  <span class="text-h5">Add New Contact </span>
                  <v-spacer></v-spacer>
                  <v-btn
                    class="mx-2"
                    fab
                    text
                    small
                    @click="addContactModal = false"
                  >
                    <v-icon dense>mdi-window-close</v-icon>
                  </v-btn>
                </v-card-title>
                <v-card-text>
                  <v-container>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          v-model="form.name"
                          ref="name"
                          label="Name"
                          :rules="rules.name"
                        ></v-text-field>
                      </v-col>
                      <v-col cols="12">
                        <v-text-field
                          v-model="form.msisdn"
                          ref="msisdn"
                          label="Phone Number"
                          :rules="rules.msisdn"
                        ></v-text-field>
                      </v-col>
                    </v-row>
                  </v-container>
                </v-card-text>
                <v-card-actions>
                  <v-spacer></v-spacer>

                  <v-btn
                    @click="presave"
                    :loading="saving"
                    class="button"
                    color="#0052ff"
                    tile
                    >Save</v-btn
                  >
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-form>
        </div>

        <div class="edit-contact">
          <v-form ref="form">
            <v-dialog
              :value="editContactModal"
              :width="addModalWidth"
              persistent
            >
              <v-card>
                <v-card-title>
                  <span class="text-h5">Edit Contact </span>
                  <v-spacer></v-spacer>
                  <v-btn
                    class="mx-2"
                    fab
                    text
                    small
                    @click="editContactModal = false"
                  >
                    <v-icon dense>mdi-window-close</v-icon>
                  </v-btn>
                </v-card-title>
                <v-card-text>
                  <v-container>
                    <v-row>
                      <v-col cols="12">
                        <v-text-field
                          v-model="form.name"
                          ref="name"
                          label="Name"
                          :rules="rules.name"
                          clearable
                        ></v-text-field>
                      </v-col>
                      <v-col cols="12">
                        <v-text-field
                          v-model="form.msisdn"
                          ref="msisdn"
                          label="Phone Number"
                          :rules="rules.msisdn"
                          clearable
                        ></v-text-field>
                      </v-col>
                    </v-row>
                  </v-container>
                </v-card-text>
                <v-card-actions>
                  <v-spacer></v-spacer>

                  <v-btn
                    @click="preupdate()"
                    :loading="saving"
                    class="button"
                    color="#0052ff"
                    tile
                    >Update</v-btn
                  >
                </v-card-actions>
              </v-card>
            </v-dialog>
          </v-form>
        </div>
      </v-col>
    </v-row>
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
    saving: false,
    addContactModal: false,
    editContactModal: false,
    currentlyEditingRef: "",
    addModalWidth: "30%",
    searchQuery: "",
    contacts: [],
    contactsDump: [],
    contactsHydrated: false,
    formHasErrors: false,
    form: {
      name: "",
      msisdn: "",
      country_code: "NGN",
    },
    rules: {},
  }),
  computed: {
    form_cast() {
      return {
        name: this.form.name,
        msisdn: this.form.msisdn,
      };
    },
  },
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
    launch() {
      this.$refs.form.reset();
      this.addContactModal = true;
      this.rules = {
        msisdn: [(v) => (v || "").length > 0 || "Phone number is required"],
        name: [(v) => (v || "").length > 0 || "Contact name is required"],
      };
    },
    validateForm() {
      this.formHasErrors = false;

      Object.keys(this.form_cast).forEach((f) => {
        if (!this.form_cast[f]) this.formHasErrors = true;

        this.$refs[f].validate(true);
      });
    },
    async presave() {
      this.validateForm();

      if (!this.formHasErrors) await this.saveContact();
    },
    async preupdate() {
      this.validateForm();

      if (!this.formHasErrors)
        await this.updateContact(this.currentlyEditingRef);
    },
    async saveContact() {
      this.saving = true;

      try {
        const response = await this.$axios.$post("/contact", this.form);

        this.$toast.success("Contact saved!");

        this.addContactModal = false;

        let contact = response.data;

        this.contacts.unshift(contact);
        this.contactsDump.unshift(contact);
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.saving = false;
      }
    },
    async deleteContact(ref) {
      try {
        const response = await this.$axios.$delete(`/contact/${ref}`);

        this.$toast.success("Contact deleted!");

        let newContacts = this.contacts.filter((item) => {
          return item.ref != response.data.ref;
        });

        this.contacts = newContacts;
        this.contactsDump = newContacts;
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.saving = false;
      }
    },
    editContact({ msisdn, name, ref }) {
      this.currentlyEditingRef = ref;
      this.form.msisdn = msisdn;
      this.form.name = name;
      this.editContactModal = true;
      this.rules = {
        msisdn: [(v) => (v || "").length > 0 || "Phone number is required"],
        name: [(v) => (v || "").length > 0 || "Contact name is required"],
      };
    },
    async updateContact(ref) {
      this.saving = true;
      try {
        const response = await this.$axios.$put(`/contact/${ref}`, this.form);

        this.$toast.success("Contact updated!");

        this.editContactModal = false;

        this.contacts.map((item) => {
          if (item.ref == response.data.ref) {
            item.name = this.form.name;
            item.msisdn = this.form.msisdn;
          }
        });
      } catch (error) {
        errorCatch(error, this);
      } finally {
        this.saving = false;
      }
    },
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
  beforeMount() {
    if (screen.width < 600) {
      this.addModalWidth = "90%";
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