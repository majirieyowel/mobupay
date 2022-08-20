function cleanMsisdn(msisdn) {
  var msisdn = msisdn.toString();
  var msisdn = decodeURIComponent(msisdn);
  var msisdn = msisdn.replace(/\s/g, "");

  if (msisdn.startsWith("+")) {
    var msisdn = msisdn.substring(1);
  }
  return msisdn;
}

export default function ({ route, store, redirect }) {
  let route_msisdn = cleanMsisdn(route.params.dashboard);

  let store_msisdn = store.state.auth.user.msisdn;

  if (route_msisdn !== store_msisdn) {
    return redirect("/invalid-path");
  }
}
