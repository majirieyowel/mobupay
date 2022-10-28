export default {
  onboardingHash(state, value) {
    state.onboarding._hash = value;
  },
  createBankAccount(state, payload) {
    state.auth.user.bank_accounts.push(payload);
  },

  addEmail(state, email) {
    state.auth.user.email = email;
  },
  removeBankAccount(state, ref) {
    state.auth.user.bank_accounts = state.auth.user.bank_accounts.filter(
      (account) => {
        return account.ref !== ref;
      }
    );
  },

  removeCard(state, ref) {
    state.auth.user.cards = state.auth.user.cards.filter((card) => {
      return card.ref !== ref;
    });
  },
  updateBalance(state, { account_balance, book_balance }) {
    state.auth.user.account_balance = account_balance;
    state.auth.user.book_balance = book_balance;
  },
  mayBeAddCard(state, payload) {
    if (Object.keys(payload).length !== 0) {
      state.auth.user.cards.push(payload);
    } else {
      state;
    }
  },
  pushTransactions(state, transactions_list) {
    state.transactions = transactions_list;
  },
  pushWithdrawals(state, withdrawals_list) {
    state.withdrawals = withdrawals_list;
  },
  updateTransactionStatus(state, { ref, status }) {
    state.transactions.map((item, index) => {
      if (item.ref === ref) {
        state.transactions[index].status = status;
      }
    });
  },

  transactionButtonLoadingStatus(state, { status, ref, producer }) {
    state.transactions.map((item) => {
      if (item.ref == ref) {
        switch (producer) {
          case "accept":
            item.accept_loading = status;
            break;
          case "refuse":
            item.refuse_loading = status;
            break;
          case "reclaim":
            item.reclaim_loading = status;
            break;
        }
      }
    });
  },
  setBreadcrumb(state, data) {
    state.breadcrumbs = data;
  },
  setSendDialog(state, status) {
    state.sendDialog = status;
  },
};
