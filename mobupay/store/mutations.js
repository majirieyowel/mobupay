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
  updateBalance(state, newbalance) {
    state.auth.user.balance.amount = newbalance;
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
};
