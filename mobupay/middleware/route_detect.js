export default function ({ store, route }) {

  // sets if to display login link in auth header
  if (route.name == "login") {
    store.commit('setDisplayHeaderLogin', false)
  } else {
    store.commit('setDisplayHeaderLogin', true)
  }

  // sets if to display balance in header
  if (route.name == "dashboard") {
    store.commit('setDisplayHeaderBalance', false)
  } else {
    store.commit('setDisplayHeaderBalance', true)
  }

  // set breadcrumbs
  if (route.params && route.params.dashboard) {
    let { dashboard } = { ...route.params };
    if (Object.keys(route.meta[0]).length !== 0) {
      let breadcrumbs = route.meta[0].breadcrumbs;
      breadcrumbs.map((item) => {
        if (item.to && item.to.params) {
          item.to.params = dashboard;
          item.exact = true;
        }
      });
      store.commit("setBreadcrumb", [...breadcrumbs]);
    } else {
      store.commit("setBreadcrumb", []);
    }
  }
}
