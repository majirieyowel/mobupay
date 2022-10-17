<template>
  <v-container class="accounts">
    <v-row class="mt-1">
      <v-col cols="12" class="pa-0">
        <div class="col-12 pa-0 flex--end">
          <NuxtLink
            class="text-decoration-none"
            :to="{
              name: 'dashboard-bank-accounts-add',
              params: { dashboard: $auth.$state.user.msisdn },
            }"
          >
            <v-btn class="btn--primary border-radius-none" tile> Add +</v-btn>
          </NuxtLink>
        </div>
      </v-col>
    </v-row>
    <v-row class="">
      <v-col cols="12" class="pa-0 pb-10">
        <div class="grid--wrap mt-10">
          <div
            v-for="item in bankAccounts"
            :key="item.ref"
            class="item"
            :class="{ deleting: processingAccount.ref == item.ref }"
          >
            <div class="contents">
              <p>
                <span class="v-list-item__title">Name:</span>
                <span class="item--value"> {{ item.name }}</span>
              </p>
              <p>
                <span class="v-list-item__title">Bank:</span>
                <span class="item--value">{{ item.bank_name }}</span>
              </p>
              <p>
                <span class="v-list-item__title">Number:</span>
                <span class="item--value">{{ item.nuban }}</span>
              </p>
              <p>
                <span class="v-list-item__title">Added:</span>
                <span class="item--value">{{
                  $moment(item.inserted_at).format("ll")
                }}</span>
              </p>
            </div>
            <div class="item-footer">
              {{ item.is_deleting }}
              <v-btn
                v-if="processingAccount.ref == item.ref"
                :loading="processingAccount.ref == item.ref"
                class="delete-loader"
                fab
              >
              </v-btn>
              <v-icon
                v-else
                @click="displayDeleteDialogue(item)"
                class="delete-icon"
                >mdi-trash-can-outline</v-icon
              >
            </div>
          </div>
        </div>

        <div v-if="bankAccounts.length < 1" class="mt-10 text-center empty">
          <v-icon color="rgb(209 208 208)">mdi-archive-outline</v-icon>
          <h3 class="no-content">No bank account added.</h3>
        </div>
      </v-col>
    </v-row>

    <Confirm
      :show="setDeleteDialogue"
      title="Delete Confirmation"
      :item_ref="processingAccount.ref"
      @yes="deleteBankAccount"
      @no="closeDeleteDialogue"
    >
      <p>Click 'YES' below to delete your bank account.</p>
      <p class="mb-0">{{ processingAccount.name }}</p>
      <p class="mb-0">{{ processingAccount.bank_name }}</p>
      <p class="mb-0">{{ processingAccount.nuban }}</p>
    </Confirm>
  </v-container>
</template>

<script>
import { mapGetters } from "vuex";
import catchError from "../../../functions/catchError";
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
  data: () => ({
    processingAccount: {},
    setDeleteDialogue: false,
  }),
  computed: mapGetters(["bankAccounts"]),

  methods: {
    displayDeleteDialogue(account) {
      this.processingAccount = account;
      this.setDeleteDialogue = true;
    },
    closeDeleteDialogue() {
      this.setDeleteDialogue = false;
      this.processingAccount = {};
    },
    async deleteBankAccount(ref) {
      this.setDeleteDialogue = false;
      try {
        const response = await this.$axios.delete(`bank-account/${ref}`);

        if (response.data.status) {
          // commit removal
          this.$store.commit("removeBankAccount", ref);

          this.$toast.success("Bank account deleted!");
        } else {
          this.$toast.error(response.data.message);
        }
      } catch (error) {
        errorCa;
      } finally {
        this.setDeleteDialogue = false;
        this.processingAccount = {};
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

.delete-loader {
  position: absolute;
  right: 20px;
  box-shadow: none;
  color: red;
  background: #fff;
  bottom: 24px;
  width: 15px;
  height: 15px;
}

.deleting {
  opacity: 0.4;
}

.accounts {
  .item {
    position: relative;
    padding: 15px;
    border-radius: 5px;
    background: $white;
    box-shadow: 0px 3px 1px 3px rgb(0 0 0 / 4%), 0px 2px 2px 0px rgb(0 0 0 / 0%),
      0px 1px 5px 0px rgb(0 0 0 / 25%);
  }
  .contents {
    p {
      margin: 0;

      .item--title {
        font-weight: 500;
      }
      .item--value {
        color: rgba(0, 0, 0, 0.38);
        font-size: 14px;
      }
    }
  }

  .grid--wrap {
    display: grid;
    grid-template-columns: repeat(1, 1fr);
    grid-gap: 12px;
  }

  .empty {
    .v-icon {
      font-size: 100px;
    }
  }

  .delete-icon {
    color: red;
    position: absolute;
    right: 15px;
    bottom: 20px;
  }

  .item-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;

    .date {
      color: #807e7e;
      font-style: italic;
      font-size: 14px;
      font-weight: 400;
    }
  }
}

// tablet
@media (min-width: 600px) and (max-width: 960px) {
  .accounts {
    .grid--wrap {
      grid-template-columns: repeat(2, 1fr);
    }
  }
}

//large tablet to laptop
@media (min-width: 960px) {
  .accounts {
    .grid--wrap {
      grid-template-columns: repeat(3, 1fr);
    }
  }
}
</style>