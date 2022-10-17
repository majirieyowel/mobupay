export default {
  bankAccounts(state) {
    return state.auth.user.bank_accounts;
  },
  cards(state) {
    return state.auth.user.cards;
  },
  transactions(state) {
    return state.transactions;
  },
  withdrawals(state) {
    return state.withdrawals;
  },
  breadcrumbs(state) {
    return state.breadcrumbs;
  },
  sendDialog(state) {
    return state.sendDialog;
  },
};
